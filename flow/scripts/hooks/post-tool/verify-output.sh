#!/usr/bin/env bash
# Verify tool output after file operations
# Runs on: PostToolUse (Edit|MultiEdit|Write)

set -euo pipefail

# Read tool output from stdin
TOOL_OUTPUT=$(cat)

# Check for tool success
TOOL_RESULT=$(echo "$TOOL_OUTPUT" | jq -r '.tool_result // ""')

# Extract file path
FILE_PATH=$(echo "$TOOL_OUTPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# Skip if no file path
if [[ -z "$FILE_PATH" ]]; then
	exit 0
fi

# Check if file exists and was modified recently
if [[ -f "$FILE_PATH" ]]; then
	# File exists, operation likely succeeded
	:
else
	echo '{"feedback": "Warning: File may not have been created successfully."}' >&2
fi

exit 0
