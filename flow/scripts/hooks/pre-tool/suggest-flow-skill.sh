#!/usr/bin/env bash
# Suggest flow skills based on command patterns
# Runs on: PreToolUse (Bash)

set -euo pipefail

# Read tool input from stdin
TOOL_INPUT=$(cat)
COMMAND=$(echo "$TOOL_INPUT" | jq -r '.tool_input.command // ""')

# Skip if no command
if [[ -z "$COMMAND" ]]; then
	exit 0
fi

# Pattern matching for skill suggestions
case "$COMMAND" in
*workflow* | *process* | *pipeline*)
	echo "Tip: Consider using flow:flow-patterns skill for workflow design"
	;;
*analyze* | *audit* | *review*)
	echo "Tip: Consider using flow:flow-analysis skill for structured analysis"
	;;
*optimize* | *refactor* | *improve*)
	echo "Tip: Consider using flow:flow-optimization skill for optimization patterns"
	;;
esac

exit 0
