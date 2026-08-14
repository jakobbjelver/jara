#!/usr/bin/env bash
# JARA triage API helper — used by the Hermes daily triage cron.
#
# Maintainer tooling for the self-improvement loop (GOAL.md §8). Talks to the
# Cloudflare Worker's authenticated read/patch API. Requires the triage secret
# at ~/.config/jara/triage.env (JARA_TRIAGE_SECRET, chmod 600) — never committed.
#
# Usage:
#   triage.sh fetch [since_iso] [limit]     → prints JSON rows to stdout
#   triage.sh patch <id> <status> [issue_number] [issue_url]
#   triage.sh state-get | state-set <iso>   → last-run state file helpers
set -euo pipefail

API="https://api.jara.messerstudios.dev"
STATE_FILE="$HOME/.config/jara/last_triage_run.txt"
SECRET_FILE="$HOME/.config/jara/triage.env"

# shellcheck disable=SC1090
source "$SECRET_FILE" # exports JARA_TRIAGE_SECRET

case "${1:-}" in
  fetch)
    since="${2:-1970-01-01T00:00:00Z}"
    limit="${3:-500}"
    curl -sS -H "Authorization: Bearer ${JARA_TRIAGE_SECRET}" \
      "${API}/change-requests?since=${since}&limit=${limit}"
    ;;
  patch)
    id="${2:?id required}"
    status="${3:?status required}"
    issue_number="${4:-}"
    issue_url="${5:-}"
    payload=$(printf '{"status":"%s"' "$status")
    if [ -n "$issue_number" ]; then payload="${payload},\"github_issue_number\":${issue_number}"; fi
    if [ -n "$issue_url" ]; then
      json_url=$(printf '%s' "$issue_url" | sed 's/"/\\"/g')
      payload="${payload},\"github_issue_url\":\"${json_url}\""
    fi
    payload="${payload}}"
    curl -sS -X PATCH -H "Authorization: Bearer ${JARA_TRIAGE_SECRET}" \
      -H 'Content-Type: application/json' -d "$payload" \
      "${API}/change-requests/${id}"
    ;;
  state-get)
    cat "$STATE_FILE" 2>/dev/null || echo "1970-01-01T00:00:00Z"
    ;;
  state-set)
    iso="${2:?iso timestamp required}"
    mkdir -p "$(dirname "$STATE_FILE")"
    printf '%s\n' "$iso" > "$STATE_FILE"
    ;;
  *)
    echo "usage: triage.sh fetch|patch|state-get|state-set" >&2
    exit 2
    ;;
esac
