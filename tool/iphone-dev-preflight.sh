#!/bin/bash
# jara iphone-dev pre-flight (portal action step 0).
# Makes the iPhone reachable + DDI-staged before flutter touches it, with
# self-healing for the known failure modes and actionable errors otherwise.
#
# Failure modes handled:
#  1. Lazy CoreDeviceService after tunnel drop -> bounce bridge (off-LAN)
#     or just force rediscovery (on-LAN).
#  2. DDI not staged -> mount it (needs unlocked phone), retry 3x.
#  3. Missing pair record (empty /var/db/lockdown + phone unreachable)
#     -> say "plug USB + Trust" instead of burning the wait loop.
set -u

CDID="74CDE8DE-2013-5E95-A0F2-7207A669166D"          # CoreDevice ID
BRIDGE_LABEL="com.jara.coredevice-tailnet"
BRIDGE_PLIST="/Users/jakob/Repos/jara/tool/com.jara.coredevice-tailnet.plist"

dstate() {
  xcrun devicectl list devices 2>/dev/null \
    | grep -F "$CDID" \
    | sed -E "s/.*$CDID[[:space:]]+([^[:space:]]+).*/\1/" \
    | head -1
}
reachable() { [ "$(dstate)" = "connected" ] || [ "$(dstate)" = "available" ]; }

# --- 1. reachability -------------------------------------------------------
if ! reachable; then
  echo "device not reachable — attempting recovery"
  if launchctl print "gui/$(id -u)/$BRIDGE_LABEL" >/dev/null 2>&1; then
    echo "- bridge loaded: bouncing it (lazy-discovery repair)"
    launchctl bootout "gui/$(id -u)/$BRIDGE_LABEL" 2>/dev/null
    pkill -f '[c]oredevice_bridge.py --mode host' 2>/dev/null
    sleep 2
    launchctl bootstrap "gui/$(id -u)" "$BRIDGE_PLIST" 2>/dev/null
  fi
  # Force CoreDeviceService to rediscover either way (user-owned XPC,
  # respawns fresh on next devicectl call).
  pkill -f CoreDeviceService 2>/dev/null
  for _i in $(seq 1 12); do
    reachable && break
    sleep 5
  done
fi

if ! reachable; then
  LOCKDOWN_KNOWN="unknown"
  if ls /var/db/lockdown/ >/dev/null 2>&1; then
    [ -n "$(ls /var/db/lockdown/ 2>/dev/null)" ] && LOCKDOWN_KNOWN="present" || LOCKDOWN_KNOWN="empty"
  fi
  echo "PREFLIGHT FAILED — iPhone not reachable after recovery (state=$(dstate))"
  if [ "$LOCKDOWN_KNOWN" = "empty" ]; then
    echo "-> Pair record MISSING. Plug the iPhone into the Mac mini via USB,"
    echo "   unlock it and tap Trust (one-time; cannot be done over the air)."
  else
    echo "-> Unlock the phone and keep the screen ON (auto-lock drops the tunnel)."
    echo "-> Phone away from home? Start the 'iPhone Bridge' action first."
    echo "-> On cellular only? Not possible — associate any Wi-Fi network."
  fi
  exit 1
fi
echo "PREFLIGHT: device reachable (state=$(dstate))"

# --- 2. DDI staged? (mounting needs the phone UNLOCKED) --------------------
ddi_ok() {
  xcrun devicectl device info details --device "$CDID" 2>/dev/null \
    | grep -q 'ddiServicesAvailable: true'
}
if ! ddi_ok; then
  echo "DDI not staged — mounting developer services (phone must be UNLOCKED)"
  for _i in 1 2 3; do
    xcrun devicectl device info ddiServices --device "$CDID" >/dev/null 2>&1
    ddi_ok && break
    echo "  attempt $_i failed — unlock the phone screen and keep it awake"
    sleep 8
  done
fi
if ddi_ok; then
  echo "PREFLIGHT OK: reachable + DDI staged"
  exit 0
else
  echo "PREFLIGHT FAILED: DDI would not stage — is the phone locked?"
  exit 1
fi
