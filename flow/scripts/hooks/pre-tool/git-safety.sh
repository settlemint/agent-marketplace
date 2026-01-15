#!/usr/bin/env bash
# Git safety hook for multi-agent environments
# Runs on: PreToolUse (Bash)

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="git-safety"
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

# Skip if not a git command
if [[ "$COMMAND" != *"git "* ]]; then
	exit 0
fi

# Check for destructive git operations
DESTRUCTIVE_WARNING=""

case "$COMMAND" in
*"git reset --hard"*)
	DESTRUCTIVE_WARNING="git reset --hard discards uncommitted changes. In multi-agent environments, this may delete work from other agents."
	;;
*"git clean -fd"* | *"git clean -f"*)
	DESTRUCTIVE_WARNING="git clean -fd removes untracked files. Other agents may have created files not yet committed."
	;;
*"git push --force"* | *"git push -f"*)
	DESTRUCTIVE_WARNING="Force push overwrites remote history. Use --force-with-lease for safer alternative."
	;;
*"git checkout -- ."* | *"git restore ."*)
	DESTRUCTIVE_WARNING="This discards all local changes. Check git status first to avoid losing work."
	;;
*"git stash drop"* | *"git stash clear"*)
	DESTRUCTIVE_WARNING="Dropping stash permanently deletes changes. Verify stash contents first."
	;;
*"git branch -D"* | *"git branch --delete --force"*)
	DESTRUCTIVE_WARNING="Force deleting branch. Ensure no unmerged work exists."
	;;
esac

if [[ -n "$DESTRUCTIVE_WARNING" ]]; then
	log_warn "event=DESTRUCTIVE_GIT_COMMAND" "command=$COMMAND"
	echo "Multi-Agent Safety Warning: $DESTRUCTIVE_WARNING"
	echo 'Load skill: Skill({ skill: "devtools:git" }) for safe alternatives'

	# Check for concurrent agent sessions
	if [[ -d ".claude/branches" ]]; then
		ACTIVE_SESSIONS=$(find .claude/branches -maxdepth 1 -mindepth 1 -type d 2>/dev/null | wc -l | tr -d ' ')
		if [[ "$ACTIVE_SESSIONS" -gt 0 ]]; then
			echo "Note: Found $ACTIVE_SESSIONS branch state file(s) in .claude/branches/"
		fi
	fi
fi

# Suggest granular commits for large git add
case "$COMMAND" in
*"git add ."* | *"git add -A"* | *"git add --all"*)
	echo "Tip: Consider staging files individually for granular commits. Run 'git status' first."
	;;
esac

exit 0
