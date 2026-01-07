#!/usr/bin/env bash
#
# Provides git worktree context for commands
# Detects if current directory is a worktree and shows related info
#
set -euo pipefail

# Check if in a git repo
if ! git rev-parse --git-dir &>/dev/null; then
	echo "## Worktree Status"
	echo "Not in a git repository"
	exit 0
fi

branch=$(git branch --show-current 2>/dev/null || echo "(detached)")
git_dir=$(git rev-parse --git-dir)
git_common_dir=$(git rev-parse --git-common-dir)

echo "## Worktree Status"
echo

# Determine if this is a worktree
if [[ "$git_dir" != "$git_common_dir" ]]; then
	echo "**Type:** Worktree (not main checkout)"
	echo "**Current branch:** \`$branch\`"
	echo "**Git dir:** \`$git_dir\`"
	echo "**Common dir:** \`$git_common_dir\`"
	echo
	echo "### Worktree Safety"
	echo "⚠️ **Branch-switching commands are dangerous in worktrees!**"
	echo
	echo "**Safe commands:**"
	echo "- \`git machete update\` - rebase current branch onto parent"
	echo "- \`git machete status\` - view stack status"
	echo "- \`git machete show up/down\` - view parent/child"
	echo
	echo "**Dangerous commands (will break worktree):**"
	echo "- \`git machete traverse\` - switches between branches"
	echo "- \`git machete go up/down\` - switches to parent/child"
	echo "- \`git checkout <other-branch>\` - defeats worktree purpose"
	IS_WORKTREE="true"
else
	echo "**Type:** Main checkout (not a worktree)"
	echo "**Current branch:** \`$branch\`"
	IS_WORKTREE="false"
fi

echo

# List all worktrees
echo "### All Worktrees"
echo '```'
git worktree list 2>/dev/null || echo "(unable to list worktrees)"
echo '```'

# Export for use in conditionals (when sourced)
export IS_WORKTREE
