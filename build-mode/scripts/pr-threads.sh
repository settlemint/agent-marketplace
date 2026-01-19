#!/usr/bin/env bash
# Get unresolved review threads for PR
# Usage: pr-threads.sh [PR_NUMBER]
set -uo pipefail

PR_NUMBER="${1:-}"

if [[ -z "$PR_NUMBER" ]]; then
  PR_NUMBER=$(gh pr view --json number -q '.number' 2>/dev/null || true)
  if [[ -z "$PR_NUMBER" ]]; then
    echo "No PR found for current branch"
    exit 0
  fi
fi

OWNER=$(gh repo view --json owner -q '.owner.login')
REPO=$(gh repo view --json name -q '.name')

# shellcheck disable=SC2016
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
}'

RESULT=$(gh api graphql \
  -F owner="$OWNER" \
  -F repo="$REPO" \
  -F pr="$PR_NUMBER" \
  -f query="$QUERY" 2>/dev/null)

if [[ -z "$RESULT" ]]; then
  echo "Failed to fetch review threads"
  exit 0
fi

THREADS=$(echo "$RESULT" | jq -r '
  .data.repository.pullRequest.reviewThreads.nodes[]
  | select(.isResolved == false)
  | "- \(.path):\(.line // "?") [@\(.comments.nodes[0].author.login)]: \(.comments.nodes[0].body | split("\n")[0])\n  THREAD_ID=\(.id)"
' 2>/dev/null)

if [[ -z "$THREADS" ]]; then
  echo "No unresolved threads"
else
  echo "## Unresolved Threads"
  echo "$THREADS"
fi
