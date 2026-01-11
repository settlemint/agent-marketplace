#!/bin/bash
# Get GitHub repository information
# Usage: ./gh-repo-info.sh [--json]
# Output: KEY=VALUE pairs (or JSON with --json flag)
# Exits gracefully with message if not in repo (for use in dynamic patterns)

set -uo pipefail

JSON_MODE="${1:-}"

# Fetch repo info
REPO_INFO=$(gh repo view --json nameWithOwner,defaultBranchRef,url 2>/dev/null)
if [ -z "$REPO_INFO" ]; then
	echo "Not in a GitHub repository"
	exit 0
fi

NAME_WITH_OWNER=$(echo "$REPO_INFO" | jq -r '.nameWithOwner')
DEFAULT_BRANCH=$(echo "$REPO_INFO" | jq -r '.defaultBranchRef.name')
REPO_URL=$(echo "$REPO_INFO" | jq -r '.url')
OWNER=$(echo "$NAME_WITH_OWNER" | cut -d'/' -f1)
REPO=$(echo "$NAME_WITH_OWNER" | cut -d'/' -f2)

if [ "$JSON_MODE" = "--json" ]; then
	jq -n \
		--arg nwo "$NAME_WITH_OWNER" \
		--arg owner "$OWNER" \
		--arg repo "$REPO" \
		--arg branch "$DEFAULT_BRANCH" \
		--arg url "$REPO_URL" \
		'{nameWithOwner: $nwo, owner: $owner, repo: $repo, defaultBranch: $branch, url: $url}'
else
	cat <<EOF
NAME_WITH_OWNER=$NAME_WITH_OWNER
OWNER=$OWNER
REPO=$REPO
DEFAULT_BRANCH=$DEFAULT_BRANCH
REPO_URL=$REPO_URL
EOF
fi
