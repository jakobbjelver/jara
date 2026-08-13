#!/usr/bin/env bash
# JARA smoketest — the dev→main gate (AGENTS.md §8, SELF-IMPROVEMENT.md §7).
#
# Boots the iPhone 17 Pro simulator, builds a debug app, installs it, starts a
# simulated-GPS route, runs the Maestro flows in smoketest/flows/, and
# collects evidence into smoketest/output/<timestamp>/.
#
# Deterministic only — vision never gates. Requires Maestro on PATH:
#   curl -fsSL "https://get.maestro.mobile.dev" | bash
set -euo pipefail
cd "$(dirname "$0")/.."

UDID="094D4A15-891A-4E86-9C8F-1AC2CAB460B3"
APP_ID="com.jara.jara"
TS="$(date +%s)"
OUT="smoketest/output/${TS}"
mkdir -p "$OUT"
export SMOKE_TS="$TS" # used by flow 03 for a unique report title

log() { printf '▶ %s\n' "$*"; }

log "booting simulator $UDID"
xcrun simctl boot "$UDID" 2>/dev/null || true

log "building debug app for simulator"
flutter build ios --simulator --debug

log "installing $APP_ID"
xcrun simctl install "$UDID" build/ios/iphonesimulator/Runner.app

log "granting location permission"
xcrun simctl privacy "$UDID" grant location "$APP_ID" || true

log "starting simulated-GPS waypoint playback"
xcrun simctl location "$UDID" start --speed=5 --interval=5 \
  - < "smoketest/fixtures/copenhagen_loop.waypoints"

log "running Maestro flows"
if maestro test smoketest/flows/; then
  log "smoketest green"
else
  xcrun simctl io "$UDID" screenshot "$OUT/failure.png" >/dev/null 2>&1 || true
  cp -R "$HOME/.maestro/tests" "$OUT/maestro-tests" 2>/dev/null || true
  log "smoketest FAILED — evidence in $OUT"
  exit 1
fi
