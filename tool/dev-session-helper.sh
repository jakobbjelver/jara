#!/bin/bash
# jara iPhone dev-session helper — runs `flutter run --use-application-binary`
# in the GUI (Aqua) LaunchAgent session so macOS attributes Local Network /
# mDNS access to a user-context process (SSH-daemon orphans get it denied ->
# "Flutter could not access the local network", errno 65 on the VM-service
# discovery). Mirror of the build-ios-helper pattern: bootstrap this agent to
# start the session, bootout to stop it.
#
# The helper owns the whole session lifecycle:
#   - FIFO stdin (hot reload/restart) is created under /tmp for cross-step access
#   - PID + ready-marker written so the portal status probe is correct
#   - flutter run is a LONG-LIVED foreground process of this agent; bootout kills it
set -u
cd /Users/jakob/Repos/jara || exit 1
export PATH=/opt/homebrew/bin:$PATH

LOG=/tmp/jara-dev.log
PIDFILE=/tmp/jara-dev.pid
FIFO=/tmp/jara-attach.fifo
UDID="00008140-000A41000A06801C"

# Reset per-run state.
rm -f "$LOG" "$PIDFILE" "$FIFO" /tmp/jara-dev.ready
mkfifo "$FIFO"
echo "DEV-SESSION: helper start $(date +%H:%M:%S)" > "$LOG"

# Keep the FIFO write-end open so the portal's `echo r > fifo` (a write-only
# open, which blocks until a READER appears) never blocks before flutter opens
# it. This holder is a child of this agent, so bootout cleans it up too.
( exec 3>"$FIFO"; sleep 86400 ) 2>/dev/null &

# Write our own PID (the agent's long-lived process). The portal status probe
# reads this file and kill -0's it.
echo $$ > "$PIDFILE"

flutter run --use-application-binary build/ios/iphoneos/Runner.app \
  -d "$UDID" --device-timeout 60 < "$FIFO" >> "$LOG" 2>&1
RC=$?

# Session ended (quit/detach/crash). Leave an unambiguous marker.
echo "DEV-SESSION: ended rc=$RC $(date +%H:%M:%S)" >> "$LOG"
rm -f "$PIDFILE" "$FIFO"
exit $RC