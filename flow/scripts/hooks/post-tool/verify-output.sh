#!/usr/bin/env bash
# Verify tool output after file operations
# Runs on: PostToolUse (Edit|MultiEdit|Write)

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="verify-output"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read tool output from stdin
TOOL_OUTPUT=$(cat)

# Check for tool success
TOOL_RESULT=$(echo "$TOOL_OUTPUT" | jq -r '.tool_result // ""' 2>/dev/null || echo "")

# Extract file path
FILE_PATH=$(echo "$TOOL_OUTPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null || echo "")

# Skip if no file path
if [[ -z "$FILE_PATH" ]]; then
	exit 0
fi

# Check if file exists and was modified recently
if [[ -f "$FILE_PATH" ]]; then
	log_debug "event=FILE_VERIFIED" "file=$FILE_PATH" "exists=true"
else
	log_warn "event=FILE_MISSING" "file=$FILE_PATH"
	echo '{"feedback": "Warning: File may not have been created successfully."}' >&2
fi

exit 0
