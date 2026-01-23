#!/usr/bin/env bash
# Resolve a PR review thread via GitHub GraphQL API
# Usage: resolve-thread.sh <thread-id>

set -euo pipefail

THREAD_ID="${1:-}"

if [[ -z "$THREAD_ID" ]]; then
  echo "Usage: resolve-thread.sh <thread-id>" >&2
  echo "Get thread IDs from: get-unresolved-threads.sh" >&2
  exit 1
fi

QUERY='
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread { isResolved }
  }
}
'

gh api graphql -f query="$QUERY" -F threadId="$THREAD_ID" --jq '.data.resolveReviewThread.thread.isResolved'
