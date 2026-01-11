#!/usr/bin/env bash
#
# PostToolUse hook: Check PR scope after git push
# Suggests updating PR title/body if scope has expanded
#
# PERFORMANCE: Only runs when Bash command contains "git push"
#
set +e # Hooks must never fail

# Read hook input from stdin
INPUT=$(cat)

# FAST PATH: Only run on git push commands
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)
if [[ ! $COMMAND =~ git[[:space:]]+push ]]; then
	exit 0
fi

# Check if tool succeeded
TOOL_RESULT=$(echo "$INPUT" | jq -r '.tool_result // ""' 2>/dev/null)
# If push failed (rejected, error), skip the check
if [[ $TOOL_RESULT =~ "rejected" ]] || [[ $TOOL_RESULT =~ "error:" ]] || [[ $TOOL_RESULT =~ "fatal:" ]]; then
	exit 0
fi

# Only proceed if gh is available
command -v gh &>/dev/null || exit 0

# Only proceed if in a git repo
git rev-parse --git-dir &>/dev/null 2>&1 || exit 0

# Run the scope check script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="$(dirname "$(dirname "$SCRIPT_DIR")")"

if [[ -x "$PLUGIN_ROOT/scripts/git/gh-pr-scope-check.sh" ]]; then
	"$PLUGIN_ROOT/scripts/git/gh-pr-scope-check.sh"
fi

exit 0
