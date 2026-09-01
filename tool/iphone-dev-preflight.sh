#!/bin/bash
# jara iphone-dev pre-flight (portal action step 0).
# Makes the iPhone reachable + DDI-staged before flutter touches it, with
# self-healing for the known local failure modes and actionable errors otherwise.
# Local-only: works over USB or when the iPhone is on the same (home) Wi-Fi.
#
# Failure modes handled:
#  1. Lazy CoreDeviceService after tunnel drop -> force rediscovery.
#  2. DDI not staged -> mount it (needs unlocked phone), retry 3x.
#  3. Missing pair record (empty /var/db/lockdown + phone unreachable)
#     -> say "plug USB + Trust" instead of burning the wait loop.
set -u

CDID="74CDE8DE-2013-5E95-A0F2-7207A669166D"          # CoreDevice ID

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
  # Force CoreDeviceService to rediscover (user-owned XPC, respawns fresh on
  # next devicectl call). Local link only — no bridge needed.
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
    echo "-> Make sure the iPhone is on the SAME home Wi-Fi as the Mac mini"
    echo "   (or USB-tethered) — remote/off-LAN development is not supported."
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