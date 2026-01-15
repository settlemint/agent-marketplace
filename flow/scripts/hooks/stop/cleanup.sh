#!/usr/bin/env bash
# Cleanup and save state on session stop
# Runs on: Stop

set -euo pipefail

# Read event data from stdin
EVENT_DATA=$(cat)

# Check if flow is initialized
STATE_FILE=".claude/flow/state.json"
if [[ ! -f "$STATE_FILE" ]]; then
	exit 0
fi

# Update state with stop marker
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if command -v jq &>/dev/null; then
	TMP_FILE=$(mktemp)
	jq --arg ts "$TIMESTAMP" '
    .lastSession = $ts
  ' "$STATE_FILE" >"$TMP_FILE" && mv "$TMP_FILE" "$STATE_FILE"
fi

exit 0
