#!/usr/bin/env bash
#
# Provides git-machete context for commands
# Outputs machete status if available
#
# NOTE: Supports worktrees - uses git-common-dir for machete file location
#
set -euo pipefail

# Check if git-machete is installed
if ! command -v git-machete &>/dev/null; then
	echo "## Git Machete"
	echo "⚠️ git-machete is not installed."
	echo "Install with: \`brew install git-machete\` or \`pip install git-machete\`"
	echo
	exit 0
fi

# Ensure optimal machete configuration
# prDescriptionIntroStyle=full: Required for update-pr-descriptions --related
# squashMergeDetection=simple: Detect squash-merged PRs as merged
# annotateWithUrls=true: Include full PR URLs in annotations
configure_machete_setting() {
	local key="$1"
	local value="$2"
	local current
	current=$(git config --get "$key" 2>/dev/null || echo "")
	if [[ "$current" != "$value" ]]; then
		git config "$key" "$value"
	fi
}

configure_machete_setting "machete.github.prDescriptionIntroStyle" "full"
configure_machete_setting "machete.squashMergeDetection" "simple"
configure_machete_setting "machete.github.annotateWithUrls" "true"

# Check if in a git repo
if ! git rev-parse --git-dir &>/dev/null; then
	exit 0
fi

branch=$(git branch --show-current 2>/dev/null || echo "")

# Get the correct machete file path (supports worktrees)
# git-common-dir returns the main .git directory even in worktrees
git_common_dir=$(git rev-parse --git-common-dir 2>/dev/null)
machete_file="${git_common_dir}/machete"

echo "## Git Machete Status"
echo

# Check if machete file exists
if [[ -f "$machete_file" ]]; then
	echo "**Layout file:** \`${machete_file}\`"
	echo

	# Check if current branch is in machete layout
	if git machete is-managed "$branch" 2>/dev/null; then
		echo "**Current branch:** \`$branch\` is in machete layout"

		# Get parent branch
		parent=$(git machete show up 2>/dev/null || echo "")
		if [[ -n "$parent" ]]; then
			echo "**Parent branch:** \`$parent\`"
		else
			echo "**Parent branch:** (root branch)"
		fi

		# Get child branches
		children=$(git machete show down 2>/dev/null || echo "")
		if [[ -n "$children" ]]; then
			echo "**Child branches:** \`$children\`"
		fi

		# Check sync status
		echo
		echo "### Sync Status"
		echo '```'
		status_output=$(git machete status 2>/dev/null | head -25 || echo "(unable to get status)")
		echo "$status_output"
		echo '```'

		# Detect merged branches (gray edges indicated by 'o' prefix in status)
		merged_count=$(echo "$status_output" | grep -cE "^\s*o\s" 2>/dev/null || echo "0")
		if [[ "$merged_count" -gt 0 ]]; then
			echo
			echo "🔀 **$merged_count merged branch(es) detected** — run \`Skill({ skill: \"crew:git:slide-out\" })\` to clean up"
		fi

		# Check if out of sync with parent
		if [[ -n "$parent" ]]; then
			if ! git machete is-ancestor "$parent" "$branch" 2>/dev/null; then
				echo
				echo "⚠️ **Out of sync with parent** — run \`Skill({ skill: \"crew:git:sync\" })\` or \`git machete update\`"
			fi
		fi

		# Edge coloring legend
		echo
		echo "### Edge Colors"
		echo "- 🟢 **Green**: In sync with parent"
		echo "- 🟡 **Yellow**: In sync but fork point differs (hidden commits)"
		echo "- 🔴 **Red**: Out of sync, needs rebase"
		echo "- ⚫ **Gray (o)**: Merged into parent, can be slid out"

		# Suggest next steps based on state
		echo
		echo "### Suggested Next Steps"

		# Check if current branch has children
		if [[ -n "$children" ]]; then
			# Check if current branch's PR is merged or approved
			pr_state=$(gh pr view --json state,reviewDecision -q '.state + ":" + (.reviewDecision // "NONE")' 2>/dev/null || echo "")
			if [[ "$pr_state" == "MERGED:"* ]]; then
				echo "✅ **PR merged** — run \`Skill({ skill: \"crew:git:slide-out\" })\` then work on child"
			elif [[ "$pr_state" == *":APPROVED" ]]; then
				echo "✅ **PR approved** — consider moving to child: \`Skill({ skill: \"crew:git:go\", args: \"down\" })\`"
			elif [[ "$pr_state" == "OPEN:"* ]]; then
				echo "⏳ **PR open** — awaiting review. Can work on child: \`Skill({ skill: \"crew:git:go\", args: \"down\" })\`"
			fi
		fi

		# Check if there's a sibling to work on
		next_sibling=$(git machete show next 2>/dev/null || echo "")
		if [[ -n "$next_sibling" ]]; then
			echo "➡️ **Sibling branch available:** \`$next_sibling\` — \`Skill({ skill: \"crew:git:go\", args: \"next\" })\`"
		fi

		# Check if we're on a leaf (no children) and PR is open
		if [[ -z "$children" ]]; then
			pr_url=$(gh pr view --json url -q '.url' 2>/dev/null || echo "")
			if [[ -n "$pr_url" ]]; then
				echo "🍃 **Leaf branch with PR** — waiting for review or ready to extend stack"
			fi
		fi
	else
		echo "**Current branch:** \`$branch\` is NOT in machete layout"
		echo
		echo "To add to stack: \`git machete add --onto <parent-branch>\`"
		echo
		echo "### Current Layout"
		echo '```'
		cat "$machete_file" 2>/dev/null | head -20 || echo "(unable to read)"
		echo '```'
		echo
		echo "### Available Parent Branches"
		echo "Use these to populate stacking question options:"
		echo '```json'
		echo "["
		echo '  { "branch": "main", "description": "Main branch" }'

		# Get open PRs that could be parent branches
		if command -v gh &>/dev/null; then
			gh pr list --state open --json number,headRefName,title --limit 10 2>/dev/null | jq -r '.[] | ",  { \"branch\": \"\(.headRefName)\", \"description\": \"PR #\(.number): \(.title | .[0:50])\" }"' 2>/dev/null || true
		fi

		echo "]"
		echo '```'
	fi
else
	echo "**No machete layout** - \`${machete_file}\` does not exist"
	echo
	echo "To set up stacked branches, run \`Skill({ skill: \"crew:git:discover\" })\` or:"
	echo "1. \`git machete discover\` - auto-detect layout from reflog"
	echo "2. \`git machete edit\` - manually define layout"
	echo
	echo "**Note:** In worktrees, the machete file is shared with the main repo."
	echo
	echo "### Available Parent Branches"
	echo "Use these to populate stacking question options:"
	echo '```json'
	echo "["
	echo '  { "branch": "main", "description": "Main branch" }'

	# Get open PRs that could be parent branches
	if command -v gh &>/dev/null; then
		gh pr list --state open --json number,headRefName,title --limit 10 2>/dev/null | jq -r '.[] | ",  { \"branch\": \"\(.headRefName)\", \"description\": \"PR #\(.number): \(.title | .[0:50])\" }"' 2>/dev/null || true
	fi

	echo "]"
	echo '```'
fi

echo
