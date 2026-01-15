#!/usr/bin/env bash
# Cleanup and save state on session stop
# Runs on: Stop

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="cleanup"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read event data from stdin
EVENT_DATA=$(cat)

# Get project directory
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Check if flow is initialized
STATE_FILE="$PROJECT_DIR/.claude/flow/state.json"
if [[ ! -f "$STATE_FILE" ]]; then
	exit 0
fi

# Update state with stop marker
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

if command -v jq &>/dev/null; then
	TMP_FILE=$(mktemp)
	if jq --arg ts "$TIMESTAMP" '
    .lastSession = $ts
  ' "$STATE_FILE" >"$TMP_FILE" 2>/dev/null && mv "$TMP_FILE" "$STATE_FILE"; then
		log_info "event=SESSION_STOPPED" "timestamp=$TIMESTAMP"
	fi
fi

# Expire old history files (older than 30 days)
HISTORY_DIR="$PROJECT_DIR/.claude/flow/history"
if [[ -d "$HISTORY_DIR" ]]; then
	EXPIRED_COUNT=$(find "$HISTORY_DIR" -name "*.json" -mtime +30 2>/dev/null | wc -l | tr -d ' ')
	if [[ "$EXPIRED_COUNT" -gt 0 ]]; then
		find "$HISTORY_DIR" -name "*.json" -mtime +30 -delete 2>/dev/null
		log_debug "event=HISTORY_CLEANED" "expired_files=$EXPIRED_COUNT"
	fi
fi

exit 0
