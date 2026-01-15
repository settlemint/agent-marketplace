#!/usr/bin/env bash
# Save flow state before session compaction
# Runs on: PreCompact

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="save-flow-state"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

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
	if jq --arg ts "$TIMESTAMP" '
    .lastCompaction = $ts |
    .compactionCount = ((.compactionCount // 0) + 1)
  ' "$STATE_FILE" >"$TMP_FILE" && mv "$TMP_FILE" "$STATE_FILE"; then
		COMPACTION_COUNT=$(jq -r '.compactionCount // 0' "$STATE_FILE" 2>/dev/null || echo "0")
		log_info "event=STATE_SAVED" "compaction_count=$COMPACTION_COUNT"
		echo "Flow: State saved before compaction"
	else
		log_error "event=STATE_SAVE_FAILED"
	fi
fi

exit 0
