#!/usr/bin/env bash
# Save flow state before session compaction
# Runs on: PreCompact

set -euo pipefail

# Read event data from stdin
EVENT_DATA=$(cat)

# Check if flow is initialized
STATE_FILE=".claude/flow/state.json"
if [[ ! -f "$STATE_FILE" ]]; then
	exit 0
fi

# Update state with compaction marker
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if command -v jq &>/dev/null; then
	TMP_FILE=$(mktemp)
	jq --arg ts "$TIMESTAMP" '
    .lastCompaction = $ts |
    .compactionCount = ((.compactionCount // 0) + 1)
  ' "$STATE_FILE" >"$TMP_FILE" && mv "$TMP_FILE" "$STATE_FILE"

	echo "Flow: State saved before compaction"
fi

exit 0
