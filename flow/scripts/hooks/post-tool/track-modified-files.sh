#!/usr/bin/env bash
# Track files modified during session for incremental doc updates
# Hook: PostToolUse (Edit|MultiEdit|Write)

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="track-modified-files"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read tool input from stdin
TOOL_INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null)

if [[ -z "$FILE_PATH" ]]; then
	exit 0
fi

# Normalize to relative path
if [[ "$FILE_PATH" == /* ]]; then
	REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
	FILE_PATH="${FILE_PATH#"$REPO_ROOT/"}"
fi

# State file for tracking modified files this session
STATE_DIR=".claude/flow"
STATE_FILE="$STATE_DIR/session-modified-files.json"

# Ensure state directory exists
mkdir -p "$STATE_DIR"

# Initialize or load existing state
if [[ -f "$STATE_FILE" ]]; then
	CURRENT_FILES=$(jq -r '.files // []' "$STATE_FILE" 2>/dev/null || echo '[]')
else
	CURRENT_FILES='[]'
fi

# Add file if not already tracked
UPDATED_FILES=$(echo "$CURRENT_FILES" | jq --arg file "$FILE_PATH" '
  if . | index($file) then . else . + [$file] end
')

# Save updated state
if echo "{\"files\": $UPDATED_FILES, \"updated\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" >"$STATE_FILE"; then
	FILE_COUNT=$(echo "$UPDATED_FILES" | jq 'length' 2>/dev/null || echo "0")
	log_debug "event=FILE_MODIFIED_TRACKED" "file=$FILE_PATH" "total_tracked=$FILE_COUNT"
else
	log_warn "event=TRACK_FAILED" "file=$FILE_PATH"
fi

exit 0
