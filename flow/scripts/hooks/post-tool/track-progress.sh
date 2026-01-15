#!/usr/bin/env bash
# Track file modification progress
# Runs on: PostToolUse (Edit|MultiEdit|Write)

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="track-progress"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read tool output from stdin
TOOL_OUTPUT=$(cat)

# Extract file path
FILE_PATH=$(echo "$TOOL_OUTPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null || echo "")

# Skip if no file path
if [[ -z "$FILE_PATH" ]]; then
	exit 0
fi

# Check if flow is initialized
STATE_FILE=".claude/flow/state.json"
if [[ ! -f "$STATE_FILE" ]]; then
	exit 0
fi

# Update last activity timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Update state file (if jq is available)
if command -v jq &>/dev/null; then
	TMP_FILE=$(mktemp)
	if jq --arg ts "$TIMESTAMP" --arg fp "$FILE_PATH" '
    .lastActivity = $ts |
    .recentFiles = ((.recentFiles // []) + [$fp] | .[-10:])
  ' "$STATE_FILE" >"$TMP_FILE" && mv "$TMP_FILE" "$STATE_FILE"; then
		log_debug "event=FILE_TRACKED" "file=$FILE_PATH"
	else
		log_warn "event=STATE_UPDATE_FAILED" "file=$FILE_PATH"
	fi
fi

exit 0
