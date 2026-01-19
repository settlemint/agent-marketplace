#!/usr/bin/env bash
# Resolve a PR review thread with educational feedback
# Usage: pr-resolve.sh <THREAD_ID> [REPLY_MESSAGE]
set -euo pipefail

THREAD_ID="${1:-}"
REPLY_MESSAGE="${2:-Fixed.}"

if [[ -z "$THREAD_ID" ]]; then
  echo "ERROR: THREAD_ID required" >&2
  echo "Usage: $0 <THREAD_ID> [REPLY_MESSAGE]" >&2
  exit 1
fi

# Reply to thread
# shellcheck disable=SC2016 # GraphQL variables, not shell
REPLY_MUTATION='
mutation($threadId: ID!, $body: String!) {
  addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $threadId, body: $body}) {
    comment { id }
  }
}'

gh api graphql \
  -F threadId="$THREAD_ID" \
  -F body="$REPLY_MESSAGE" \
  -f query="$REPLY_MUTATION" >/dev/null 2>&1 || true

# Resolve thread
# shellcheck disable=SC2016 # GraphQL variables, not shell
RESOLVE_MUTATION='
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread { isResolved }
  }
}'

RESULT=$(gh api graphql \
  -F threadId="$THREAD_ID" \
  -f query="$RESOLVE_MUTATION" 2>/dev/null) || {
  echo "ERROR: Failed to resolve thread $THREAD_ID" >&2
  exit 1
}

IS_RESOLVED=$(echo "$RESULT" | jq -r '.data.resolveReviewThread.thread.isResolved')
if [[ "$IS_RESOLVED" == "true" ]]; then
  echo "RESOLVED: $THREAD_ID"
else
  echo "ERROR: Thread not resolved" >&2
  exit 1
fi
