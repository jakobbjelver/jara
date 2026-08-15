#!/usr/bin/env python3
"""CoreDevice Tailnet Bridge — dual-mode TCP/UDP port-range relay.

Lets Xcode's CoreDevice stack (remotepairingd / remoted) reach an iPhone that
is NOT on the Mac's LAN, via a two-hop tunnel over the Tailscale container:

  Mac host (remotepairingd, scoped to the LAN interface)
    -> host mode:   bind MAC_LAN_IP:49152 + [RANGE], forward to CONTAINER_UPSTREAM
    -> container mode (coredns, netns of the tailscale container):
                    bind 0.0.0.0:49152 + [RANGE], forward to IPHONE_TAILNET_IP
    -> iPhone on the tailnet.

Design per: dev.to/kvnpt "How to remotely iterate & deploy your sideloaded
iOS-apps over tailnet" (May 2026). One process per side instead of hundreds
of socat instances. TCP + UDP (the trusted tunnel is QUIC over UDP).

Modes:
  --mode host       (runs on the Mac, under a LaunchAgent)
  --mode container  (runs inside the coredns container, shares tailscale netns)

If a conf file is missing, defaults below apply (container mode needs the
phone's tailnet IP — normally provided by the conf).
"""
import argparse
import asyncio
import configparser
import os
import resource
import socket
import subprocess
import sys
import time

# The bridge holds ~1400 sockets (702 ports x TCP+UDP). Default soft limits
# (256, or the SSH-spawned launchd context's cap) are far too small.
try:
    resource.setrlimit(resource.RLIMIT_NOFILE, (8192, 8192))
except (ValueError, PermissionError) as e:
    print(f"[coredevice-bridge] WARN setrlimit NOFILE failed: {e}", flush=True)

CONF_DEFAULT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "coredevice-bridge.conf")

FRONT_DOOR_PORT = 49152
RANGE_START = 54900
RANGE_END = 55600
UDP_IDLE_TIMEOUT = 120.0

log = lambda *a: print(f"[coredevice-bridge] {time.strftime('%H:%M:%S')} {' '.join(str(x) for x in a)}", flush=True)


def load_conf(path):
    c = configparser.ConfigParser()
    if path and os.path.exists(path):
        c.read(path)

    def get(section, key, default):
        return c.get(section, key) if c.has_option(section, key) else default

    return {
        "front_door": int(get("bridge", "front_door_port", FRONT_DOOR_PORT)),
        "range_start": int(get("bridge", "range_start", RANGE_START)),
        "range_end": int(get("bridge", "range_end", RANGE_END)),
        # host mode
        "bind_host": get("host", "bind_host", "").strip(),          # empty -> auto-detect default iface
        "upstream_host": get("host", "upstream_host", "").strip(),  # usually the tailscale container IP
        # container mode
        "phone_tailnet_ip": get("container", "phone_tailnet_ip", "").strip(),
        # Bonjour spoof (host mode only; captured one-time over USB)
        "rp_instance": get("bonjour", "rp_instance", "").strip(),
        "rp_authtag": get("bonjour", "rp_authtag", "").strip(),
        "rp_ver": get("bonjour", "ver", "24").strip(),
        "rp_minver": get("bonjour", "minver", "8").strip(),
        "rp_flags": get("bonjour", "flags", "0").strip(),
        "spoof_hostname": get("bonjour", "spoof_hostname", "").strip(),
    }


def default_interface_ip():
    """IP of the default-route interface (the link mDNS/CoreDevice considers local)."""
    try:
        iface = subprocess.check_output(
            ["route", "-n", "get", "default"], text=True, stderr=subprocess.DEVNULL
        ).split("interface: ")[1].splitlines()[0].strip()
        out = subprocess.check_output(["ifconfig", iface], text=True, stderr=subprocess.DEVNULL)
        for line in out.splitlines():
            line = line.strip()
            if line.startswith("inet ") and not line.startswith("inet6"):
                ip = line.split()[1]
                if not ip.startswith("127."):
                    return ip, iface
    except Exception as e:
        log("WARN auto-detect failed:", e)
    return "127.0.0.1", "?"


# ───────────────────────────── TCP relay ─────────────────────────────
async def _pipe(reader, writer):
    try:
        while True:
            data = await reader.read(65536)
            if not data:
                break
            writer.write(data)
            await writer.drain()
    except (ConnectionError, asyncio.CancelledError, OSError):
        pass
    finally:
        try:
            writer.close()
        except Exception:
            pass


async def tcp_handle(reader, writer, upstream, port):
    try:
        ur, uw = await asyncio.open_connection(upstream, port)
    except OSError as e:
        log(f"TCP upstream connect {upstream}:{port} failed: {e}")
        writer.close()
        return
    await asyncio.gather(_pipe(reader, uw), _pipe(ur, writer))


async def start_tcp(host, port, upstream):
    srv = await asyncio.start_server(
        lambda r, w: tcp_handle(r, w, upstream, port), host, port, reuse_address=True
    )
    log(f"TCP {host}:{port} -> {upstream}:{port}")


# ───────────────────────────── UDP relay ─────────────────────────────
class UpstreamUdp(asyncio.DatagramProtocol):
    """A dedicated upstream socket per client flow (stable source port)."""

    def __init__(self, client_addr, relay_transport, upstream, port, relay):
        self.client_addr = client_addr
        self.relay_transport = relay_transport
        self.upstream = upstream
        self.port = port
        self.relay = relay
        self.transport = None
        self.last = time.monotonic()

    def connection_made(self, transport):
        self.transport = transport

    def datagram_received(self, data, addr):
        self.last = time.monotonic()
        try:
            self.relay_transport.sendto(data, self.client_addr)
        except OSError:
            pass

    def error_received(self, exc):
        log(f"UDP upstream error {self.upstream}:{self.port}: {exc}")

    def connection_lost(self, exc):
        self.relay.drop_flow(self)


class UdpRelay(asyncio.DatagramProtocol):
    def __init__(self, upstream, port):
        self.upstream = upstream
        self.port = port
        self.flows = {}
        self.loop = None

    def connection_made(self, transport):
        self.loop = asyncio.get_event_loop()
        self.transport = transport

    def datagram_received(self, data, addr):
        flow = self.flows.get(addr)
        if flow is None:
            self.loop.create_task(self._new_flow(addr))
            return  # drop the first packet until the flow is up (QUIC retries)
        flow.last = time.monotonic()
        try:
            flow.transport.sendto(data, (self.upstream, self.port))
        except (OSError, AttributeError):
            self.drop_flow(flow)

    async def _new_flow(self, client_addr):
        _, proto = await self.loop.create_datagram_endpoint(
            lambda: UpstreamUdp(client_addr, self.transport, self.upstream, self.port, self),
            remote_addr=(self.upstream, self.port),
        )
        self.flows[client_addr] = proto
        proto.last = time.monotonic()
        self.loop.create_task(self._expire(client_addr, proto))

    def drop_flow(self, flow):
        self.flows.pop(flow.client_addr, None)
        if flow.transport:
            flow.transport.close()

    async def _expire(self, addr, flow):
        while True:
            await asyncio.sleep(30)
            if time.monotonic() - flow.last > UDP_IDLE_TIMEOUT:
                self.drop_flow(flow)
                return
            if self.flows.get(addr) is not flow:
                return


async def start_udp(host, port, upstream):
    transport, _ = await asyncio.get_event_loop().create_datagram_endpoint(
        lambda: UdpRelay(upstream, port), local_addr=(host, port)
    )
    log(f"UDP {host}:{port} -> {upstream}:{port}")


# ───────────────────────────── Bonjour spoof ─────────────────────────────
def is_armed(cfg):
    p = "PLACEHOLDER"
    return bool(cfg["rp_instance"]) and bool(cfg["rp_authtag"]) and p.upper() not in (cfg["rp_instance"] + cfg["rp_authtag"]).upper()


def spawn_dns_sd(cfg, lan_ip):
    """Register spoofed CoreDevice Bonjour records into the Mac's mDNSResponder."""
    host = cfg["spoof_hostname"] or "iphone-bridge.local"
    front = cfg["front_door"]
    procs = []
    # Primary: CoreDevice front door (RemotePairing)
    cmd = [
        "dns-sd", "-P", cfg["rp_instance"], "_remotepairing._tcp", "local", str(front),
        host, lan_ip,
        f"identifier={cfg['rp_instance']}",
        f"authTag={cfg['rp_authtag']}",
        f"ver={cfg['rp_ver']}",
        f"minVer={cfg['rp_minver']}",
        f"flags={cfg['rp_flags']}",
    ]
    procs.append(subprocess.Popen(cmd, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
    # Secondary: remoted XPC + legacy wireless usbmux — same front door
    procs.append(subprocess.Popen(
        ["dns-sd", "-P", cfg["rp_instance"], "_remoted._tcp", "local", str(front), host, lan_ip, "flags=0"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
    procs.append(subprocess.Popen(
        ["dns-sd", "-P", cfg["rp_instance"], "_apple-mobdev2._tcp", "local", str(front), host, lan_ip, "flags=0"],
        stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL))
    log(f"Bonjour spoof registered: {host} -> {lan_ip} (instance {cfg['rp_instance'][:8]}…)")
    return procs


# ───────────────────────────── main ─────────────────────────────
async def run(cfg, mode):
    if mode == "host":
        bind = cfg["bind_host"] or ""
        upstream = cfg["upstream_host"]
        if not bind:
            bind, iface = default_interface_ip()
            log(f"auto-detected LAN interface {iface} -> {bind}")
        if not upstream:
            log("FATAL: host.upstream_host missing in conf")
            return 1
        log(f"HOST mode: {bind} -> {upstream} (tailscale container)")
        if is_armed(cfg):
            spawn_dns_sd(cfg, bind)
        else:
            log("NOT ARMED: Bonjour TXT placeholders present — capture over USB on return day "
                "(dns-sd -B _remotepairing._tcp local. + dns-sd -L). Forwarders still running.")
    else:
        bind = "0.0.0.0"
        upstream = cfg["phone_tailnet_ip"]
        if not upstream:
            log("FATAL: container.phone_tailnet_ip missing in conf")
            return 1
        log(f"CONTAINER mode: 0.0.0.0 -> {upstream} (iPhone tailnet)")

    ports = [cfg["front_door"]] + list(range(cfg["range_start"], cfg["range_end"] + 1))
    failures = 0
    for port in ports:
        for start in (start_tcp, start_udp):
            bound = False
            for attempt in range(10):
                try:
                    await start(bind, port, upstream)
                    bound = True
                    break
                except OSError as e:
                    if e.errno == 48 and attempt < 9:  # EADDRINUSE — old agent still tearing down
                        await asyncio.sleep(3)
                        continue
                    failures += 1
                    log(f"WARN bind failed {start.__name__} {bind}:{port}: {e}")
                    break
    if failures:
        log(f"bridge up with {failures} bind failure(s) — check for port conflicts")
    else:
        log(f"bridge up: {len(ports)} ports x TCP+UDP")
    while True:
        await asyncio.sleep(3600)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", choices=["host", "container"], required=True)
    ap.add_argument("--conf", default=CONF_DEFAULT)
    args = ap.parse_args()
    cfg = load_conf(args.conf)
    try:
        sys.exit(asyncio.run(run(cfg, args.mode)))
    except KeyboardInterrupt:
        pass


if __name__ == "__main__":
    main()
