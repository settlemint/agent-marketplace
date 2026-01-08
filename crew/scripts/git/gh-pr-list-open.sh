#!/bin/bash
# List open PRs for a repository (excludes your own PRs by default)
# Usage: ./gh-pr-list-open.sh [--json] [--include-mine]
# Output: Human-readable list or JSON for programmatic use

set -uo pipefail

JSON_MODE=""
INCLUDE_MINE=""

# Parse arguments
for arg in "$@"; do
	case $arg in
	--json)
		JSON_MODE="true"
		;;
	--include-mine)
		INCLUDE_MINE="true"
		;;
	esac
done

# Get current GitHub user
CURRENT_USER=$(gh api user --jq '.login' 2>/dev/null || echo "")

# Fetch open PRs
PRS=$(gh pr list --state open --json number,title,headRefName,author,createdAt,additions,deletions,changedFiles --limit 50 2>/dev/null)
if [ -z "$PRS" ] || [ "$PRS" = "[]" ]; then
	echo "No open PRs found"
	exit 0
fi

# Filter out current user's PRs unless --include-mine is set
if [ -n "$CURRENT_USER" ] && [ "$INCLUDE_MINE" != "true" ]; then
	PRS=$(echo "$PRS" | jq --arg user "$CURRENT_USER" '[.[] | select(.author.login != $user)]')
	if [ "$PRS" = "[]" ]; then
		echo "No open PRs from other authors found"
		exit 0
	fi
fi

if [ "$JSON_MODE" = "true" ]; then
	echo "$PRS"
else
	echo "## Open Pull Requests (excluding yours)"
	echo ""
	echo "$PRS" | jq -r '.[] | "- #\(.number): \(.title) [\(.headRefName)] by @\(.author.login) (+\(.additions)/-\(.deletions), \(.changedFiles) files)"'
fi
