#!/usr/bin/env bash
# Get PR info for current branch
# Usage: pr-info.sh [PR_NUMBER]
set -uo pipefail

PR_NUMBER="${1:-}"

if [[ -z "$PR_NUMBER" ]]; then
  PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null || true)
  if [[ -z "$PR_NUMBER" ]]; then
    echo "No PR found for current branch"
    exit 0
  fi
fi

PR_INFO=$(gh pr view "$PR_NUMBER" --json number,url,title,state,headRefName,baseRefName,additions,deletions,changedFiles 2>/dev/null)
if [[ -z "$PR_INFO" ]]; then
  echo "Failed to fetch PR #$PR_NUMBER"
  exit 0
fi

echo "## PR Info"
echo "$PR_INFO" | jq -r '"PR #\(.number): \(.title)
URL: \(.url)
State: \(.state)
Branch: \(.headRefName) -> \(.baseRefName)
Changes: +\(.additions) -\(.deletions) (\(.changedFiles) files)"'
