#!/usr/bin/env bash
# Count unresolved PR review threads via GitHub GraphQL API
# Usage: count-unresolved-threads.sh [owner/repo#pr]
# Examples:
#   count-unresolved-threads.sh                    # Use current branch's PR
#   count-unresolved-threads.sh settlemint/dalp#5473  # Specify PR directly
# Output: Number of unresolved threads (0 = all resolved)

set -euo pipefail

PR_REF="${1:-}"

if [[ -n "$PR_REF" && "$PR_REF" == */*#* ]]; then
  # Parse owner/repo#pr format
  OWNER=$(echo "$PR_REF" | cut -d'/' -f1)
  REPO=$(echo "$PR_REF" | cut -d'/' -f2 | cut -d'#' -f1)
  PR_NUM=$(echo "$PR_REF" | cut -d'#' -f2)
else
  # Get PR info from current branch
  PR_URL=$(gh pr view --json url -q '.url' 2>/dev/null) || {
    echo "No PR found for current branch. Use: $0 owner/repo#pr" >&2
    exit 1
  }
  OWNER=$(echo "$PR_URL" | sed -n 's|.*github.com/\([^/]*\)/.*|\1|p')
  REPO=$(echo "$PR_URL" | sed -n 's|.*github.com/[^/]*/\([^/]*\)/.*|\1|p')
  PR_NUM=$(gh pr view --json number -q '.number')
fi

QUERY='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviewThreads(first: 100) {
        nodes { isResolved }
      }
    }
  }
}
'

gh api graphql -f query="$QUERY" -F owner="$OWNER" -F repo="$REPO" -F pr="$PR_NUM" \
  --jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)] | length'
