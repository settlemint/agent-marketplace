#!/usr/bin/env bash
#
# Provides phantom worktree context for commands
# Outputs worktree status and available worktrees
#
set -euo pipefail

# Check if phantom is installed
if ! command -v phantom &>/dev/null; then
	echo "## Phantom Worktrees"
	echo "Phantom is not installed."
	echo "Install with: \`brew install phantom\`"
	echo
	exit 0
fi

# Ensure optimal phantom configuration
configure_phantom_setting() {
	local key="$1"
	local value="$2"
	local current
	current=$(phantom preferences get "$key" 2>/dev/null || echo "")
	if [[ -z "$current" ]]; then
		phantom preferences set "$key" "$value" 2>/dev/null || true
	fi
}

# Configure defaults if not set
configure_phantom_setting "editor" "code --reuse-window"
configure_phantom_setting "ai" "claude"

# Check if in a git repo
if ! git rev-parse --git-dir &>/dev/null; then
	exit 0
fi

branch=$(git branch --show-current 2>/dev/null || echo "")
git_dir=$(git rev-parse --git-dir 2>/dev/null)
git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)

echo "## Phantom Worktrees"
echo

# Determine if this is a worktree
IS_WORKTREE="false"
if [[ "$git_dir" != "$git_common_dir" ]]; then
	IS_WORKTREE="true"
fi

# Get worktree list
worktrees=$(phantom list --names 2>/dev/null || echo "")
worktree_count=$(echo "$worktrees" | grep -c . 2>/dev/null || echo "0")

if [[ $IS_WORKTREE == "true" ]]; then
	echo "**Current location:** Phantom worktree"
	echo "**Branch:** \`$branch\`"
	echo "**Path:** \`$(pwd)\`"
	echo
	echo "### Worktree Constraints"
	echo "- Cannot switch branches (use \`phantom create\` for new work)"
	echo "- Use \`phantom exec <name> <cmd>\` to run commands in other worktrees"
	echo "- Use \`phantom shell <name>\` to enter another worktree"
else
	echo "**Current location:** Main checkout"
	echo "**Branch:** \`$branch\`"
fi

echo

# List all worktrees
if [[ "$worktree_count" -gt 0 ]]; then
	echo "### Active Worktrees ($worktree_count)"
	echo '```'
	phantom list 2>/dev/null || echo "(unable to list worktrees)"
	echo '```'
	echo
	echo "### Available Actions"
	echo "| Action | Command |"
	echo "|--------|---------|"
	echo "| Create worktree | \`phantom create <name>\` |"
	echo "| Enter worktree | \`phantom shell <name>\` |"
	echo "| Run in worktree | \`phantom exec <name> <cmd>\` |"
	echo "| Delete worktree | \`phantom delete <name>\` |"
	echo "| Open editor | \`phantom edit <name>\` |"
	echo "| Checkout PR | \`phantom gh checkout <num>\` |"
else
	echo "**No worktrees** - use \`phantom create <name>\` to create one"
	echo
	echo "### Quick Start"
	echo '```bash'
	echo "# Create new worktree for a feature"
	echo "phantom create feat/my-feature --shell"
	echo ""
	echo "# Or checkout a GitHub PR"
	echo "phantom gh checkout 123"
	echo '```'
fi

echo

# Show worktree directory configuration
wt_dir=$(phantom preferences get worktreesDirectory 2>/dev/null || echo ".git/phantom/worktrees")
echo "**Worktree directory:** \`$wt_dir\`"

# Export for use in conditionals (when sourced)
export IS_WORKTREE
