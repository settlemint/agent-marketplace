#!/usr/bin/env bash
# Track file modification progress
# Runs on: PostToolUse (Edit|MultiEdit|Write)

set -euo pipefail

# Read tool output from stdin
TOOL_OUTPUT=$(cat)

# Extract file path
FILE_PATH=$(echo "$TOOL_OUTPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""')

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
	jq --arg ts "$TIMESTAMP" --arg fp "$FILE_PATH" '
    .lastActivity = $ts |
    .recentFiles = ((.recentFiles // []) + [$fp] | .[-10:])
  ' "$STATE_FILE" >"$TMP_FILE" && mv "$TMP_FILE" "$STATE_FILE"
fi

exit 0
