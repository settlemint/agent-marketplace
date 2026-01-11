#!/usr/bin/env bash
#
# Provides git worktree context for commands
# Detects if current directory is a worktree and analyzes machete safety
#
set -euo pipefail

# Check if in a git repo
if ! git rev-parse --git-dir &>/dev/null; then
	echo "## Worktree Status"
	echo "Not in a git repository"
	# Use return when sourced, exit when executed directly
	# shellcheck disable=SC2317
	return 0 2>/dev/null || exit 0
fi

branch=$(git branch --show-current 2>/dev/null || echo "(detached)")
git_dir=$(git rev-parse --git-dir)
git_common_dir=$(git rev-parse --git-common-dir)
machete_file="${git_common_dir}/machete"

echo "## Worktree Status"
echo

# Determine if this is a worktree
if [[ "$git_dir" != "$git_common_dir" ]]; then
	echo "**Type:** Worktree (not main checkout)"
	echo "**Current branch:** \`$branch\`"
	echo "**Git dir:** \`$git_dir\`"
	echo "**Common dir:** \`$git_common_dir\`"
	IS_WORKTREE="true"

	# Analyze machete layout to determine safety
	echo
	if [[ -f "$machete_file" ]]; then
		# Count root branches (lines without leading whitespace, excluding main/master)
		root_branches=$(grep -cE "^[a-zA-Z]" "$machete_file" 2>/dev/null || echo "0")
		# Get all branches in layout
		all_branches=$(grep -oE "[a-zA-Z][a-zA-Z0-9/_-]*" "$machete_file" 2>/dev/null | sort -u)
		branch_count=$(echo "$all_branches" | wc -l | tr -d ' ')

		# Check if current branch is in the layout
		if echo "$all_branches" | grep -qxF "$branch"; then
			in_layout="true"
		else
			in_layout="false"
		fi

		echo "### Machete Analysis"

		if [[ "$root_branches" -le 2 && "$in_layout" == "true" ]]; then
			# Single stack pattern: main + one feature branch tree
			echo "✅ **Safe pattern detected:** Single stack in this worktree"
			echo
			echo "All machete commands work normally:"
			echo "- \`git machete traverse -W -y\` — sync entire stack"
			echo "- \`git machete go up/down\` — navigate stack"
			echo "- \`git machete update\` — rebase current branch"
			WORKTREE_MACHETE_SAFE="true"
		elif [[ "$branch_count" -gt 5 || "$root_branches" -gt 2 ]]; then
			# Multi-stack pattern: multiple independent feature branches
			echo "⚠️ **Shared layout detected:** Machete file has multiple stacks"
			echo
			echo "**Recommendation:** Use main checkout for \`traverse\`/\`go\`, or:"
			echo "1. Create separate worktrees per independent stack"
			echo "2. Edit machete layout to only include this worktree's branches"
			echo
			echo "**Safe in this worktree:**"
			echo "- \`git machete update\` — rebase current branch only"
			echo "- \`git machete status\` — view (read-only)"
			echo
			echo "**Potentially unsafe (may switch to wrong branch):**"
			echo "- \`git machete traverse\` — walks ALL branches in layout"
			echo "- \`git machete go up/down\` — may switch to unrelated branch"
			WORKTREE_MACHETE_SAFE="false"
		else
			echo "ℹ️ **Small layout:** Machete commands likely safe"
			WORKTREE_MACHETE_SAFE="true"
		fi
	else
		echo "ℹ️ No machete layout — worktree is independent"
		WORKTREE_MACHETE_SAFE="true"
	fi
else
	echo "**Type:** Main checkout (not a worktree)"
	echo "**Current branch:** \`$branch\`"
	echo
	echo "✅ All machete commands work normally in main checkout."
	IS_WORKTREE="false"
	WORKTREE_MACHETE_SAFE="true"
fi

echo

# List all worktrees
echo "### All Worktrees"
echo '```'
git worktree list 2>/dev/null || echo "(unable to list worktrees)"
echo '```'

# Best practice hint
worktree_count=$(git worktree list 2>/dev/null | wc -l | tr -d ' ')
if [[ "$worktree_count" -gt 1 ]]; then
	echo
	echo "### Best Practice"
	echo "- **Main checkout**: Primary stack, full \`traverse\` support"
	echo "- **Worktrees**: Independent features/hotfixes, isolated context"
	echo "- **One stack per worktree**: Keeps machete commands safe"
fi

# Export for use in conditionals (when sourced)
export IS_WORKTREE
export WORKTREE_MACHETE_SAFE
