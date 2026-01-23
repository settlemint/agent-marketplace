#!/usr/bin/env bash
# Get unresolved PR review threads via GitHub GraphQL API
# Usage: get-unresolved-threads.sh [--full] [owner/repo#pr]
# Examples:
#   get-unresolved-threads.sh                    # Use current branch's PR
#   get-unresolved-threads.sh settlemint/dalp#5473  # Specify PR directly
#   get-unresolved-threads.sh --full             # Full comment body
# Output: JSON objects with id, path, line, author, body

set -euo pipefail

FULL_BODY=false
PR_REF=""

for arg in "$@"; do
  case "$arg" in
    --full) FULL_BODY=true ;;
    */*#*) PR_REF="$arg" ;;
  esac
done

if [[ -n "$PR_REF" ]]; then
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
        nodes {
          id
          isResolved
          path
          line
          comments(first: 1) {
            nodes {
              body
              author { login }
            }
          }
        }
      }
    }
  }
}
'

if $FULL_BODY; then
  JQ_FILTER='.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | {id: .id, path: .path, line: .line, author: .comments.nodes[0].author.login, body: .comments.nodes[0].body}'
else
  JQ_FILTER='.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | {id: .id, path: .path, line: .line, author: .comments.nodes[0].author.login, body: .comments.nodes[0].body[0:200]}'
fi

gh api graphql -f query="$QUERY" -F owner="$OWNER" -F repo="$REPO" -F pr="$PR_NUM" --jq "$JQ_FILTER"
