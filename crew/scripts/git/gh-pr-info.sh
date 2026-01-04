#!/bin/bash
# Get GitHub Pull Request information
# Usage: ./gh-pr-info.sh [PR_NUMBER] [--json]
# If PR_NUMBER is omitted, uses current branch's PR
# Output: KEY=VALUE pairs (or JSON with --json flag)
# Exits gracefully with message if no PR found (for use in dynamic patterns)

set -uo pipefail

PR_NUMBER=""
JSON_MODE=""

# Parse arguments
for arg in "$@"; do
	case $arg in
	--json)
		JSON_MODE="--json"
		;;
	*)
		if [[ "$arg" =~ ^[0-9]+$ ]]; then
			PR_NUMBER="$arg"
		fi
		;;
	esac
done

# Build gh pr view command
if [ -n "$PR_NUMBER" ]; then
	PR_CMD="gh pr view $PR_NUMBER"
else
	PR_CMD="gh pr view"
fi

# Fetch PR info
PR_INFO=$($PR_CMD --json number,url,title,state,headRefName,baseRefName,additions,deletions,changedFiles 2>/dev/null)
if [ -z "$PR_INFO" ]; then
	echo "No PR found for current branch"
	exit 0
fi

NUMBER=$(echo "$PR_INFO" | jq -r '.number')
URL=$(echo "$PR_INFO" | jq -r '.url')
TITLE=$(echo "$PR_INFO" | jq -r '.title')
STATE=$(echo "$PR_INFO" | jq -r '.state')
HEAD_BRANCH=$(echo "$PR_INFO" | jq -r '.headRefName')
BASE_BRANCH=$(echo "$PR_INFO" | jq -r '.baseRefName')
ADDITIONS=$(echo "$PR_INFO" | jq -r '.additions')
DELETIONS=$(echo "$PR_INFO" | jq -r '.deletions')
CHANGED_FILES=$(echo "$PR_INFO" | jq -r '.changedFiles')

if [ "$JSON_MODE" = "--json" ]; then
	echo "$PR_INFO"
else
	cat <<EOF
PR_NUMBER=$NUMBER
PR_URL=$URL
PR_TITLE=$TITLE
PR_STATE=$STATE
HEAD_BRANCH=$HEAD_BRANCH
BASE_BRANCH=$BASE_BRANCH
ADDITIONS=$ADDITIONS
DELETIONS=$DELETIONS
CHANGED_FILES=$CHANGED_FILES
EOF
fi
