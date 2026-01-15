#!/usr/bin/env bash
# Suggest flow skills based on command patterns
# Runs on: PreToolUse (Bash)

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="suggest-flow-skill"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read tool input from stdin
TOOL_INPUT=$(cat)
COMMAND=$(echo "$TOOL_INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

# Skip if no command
if [[ -z "$COMMAND" ]]; then
	exit 0
fi

# No suggestions currently - flow uses hook-based agent enhancement
# rather than explicit skill suggestions for bash commands

exit 0
