#!/bin/bash
# One-shot GUI-context build+sign helper for JARA iOS device builds.
# Runs as a LaunchAgent (user Aqua session) so it has login-keychain access
# for codesign — SSH sessions cannot sign on this Mac (errSecInternalComponent).
# Triggered by the Portal "iPhone Dev Build" action; writes a log with a
# HELPER_DONE marker so callers can wait for completion.
set -u
cd /Users/jakob/Repos/jara || exit 1
export PATH=/opt/homebrew/bin:$PATH
LOG=/tmp/jara-build-helper.log
rm -f "$LOG"
echo "HELPER_START $(date +%H:%M:%S)" > "$LOG"
flutter build ios --debug >> "$LOG" 2>&1
RC=$?
echo "HELPER_DONE rc=$RC" >> "$LOG"
exit $RC
