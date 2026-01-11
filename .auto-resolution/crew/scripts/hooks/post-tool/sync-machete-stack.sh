#!/usr/bin/env bash
#
# PostToolUse hook: Sync machete stack after git commits
# Only runs after git commit commands succeed
#
# PERFORMANCE: Only runs when Bash command contains "git commit"
# This prevents unnecessary git calls on every Bash invocation
#
set -euo pipefail

# Read hook input from stdin
INPUT=$(cat)

# FAST PATH: Only run on git commit commands
# Check tool_input.command for "git commit" pattern
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null)
if [[ ! $COMMAND =~ git[[:space:]]+commit ]]; then
  exit 0
fi

# Only proceed if git-machete is installed
command -v git-machete &>/dev/null || exit 0

# Only proceed if in a git repo
git rev-parse --git-dir &>/dev/null 2>&1 || exit 0

# Only proceed if machete layout exists
machete_file=".git/machete"
if [[ ! -f "$machete_file" ]]; then
  exit 0
fi

# Get current branch
branch=$(git branch --show-current 2>/dev/null || echo "")
if [[ -z "$branch" ]]; then
  exit 0
fi

# Only proceed if current branch is in machete layout
if ! git machete is-managed "$branch" 2>/dev/null; then
  exit 0
fi

# Check if branch is out of sync with parent
parent=$(git machete show up 2>/dev/null || echo "")
if [[ -z "$parent" ]]; then
  # Root branch, no sync needed
  exit 0
fi

# Check sync status - if out of sync, notify user
if ! git merge-base --is-ancestor "$parent" HEAD 2>/dev/null; then
  echo ""
  echo "⚠️ **STACK OUT OF SYNC**"
  echo "Branch \`$branch\` is behind parent \`$parent\`"
  echo ""
  echo "**ACTION REQUIRED:** Use Skill(skill: \"crew:git:sync\") to rebase on parent"
  echo "Or use Skill(skill: \"crew:git:stacked:traverse\") to sync entire stack"
fi

exit 0
