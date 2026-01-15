#!/usr/bin/env bash
# Validate file edit actions
# Runs on: PreToolUse (Edit|MultiEdit|Write)

set -euo pipefail

# Read tool input from stdin
TOOL_INPUT=$(cat)

# Extract file path
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

# Skip if no file path
if [[ -z "$FILE_PATH" ]]; then
	exit 0
fi

# Check for protected paths
case "$FILE_PATH" in
*.env | *.env.* | *credentials* | *secret* | *.pem | *.key)
	echo '{"feedback": "Warning: Editing sensitive file. Ensure no secrets are committed."}' >&2
	;;
esac

exit 0
