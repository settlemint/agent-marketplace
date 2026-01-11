#!/bin/bash
# Resolve a review thread on GitHub
# Usage: ./gh-pr-resolve-thread.sh <THREAD_ID> [REPLY_MESSAGE]
# THREAD_ID: The GraphQL node ID of the review thread
# REPLY_MESSAGE: Optional message to reply before resolving

set -euo pipefail

THREAD_ID="${1:-}"
REPLY_MESSAGE="${2:-Fixed.}"

if [ -z "$THREAD_ID" ]; then
	echo "ERROR: THREAD_ID is required" >&2
	echo "Usage: $0 <THREAD_ID> [REPLY_MESSAGE]" >&2
	exit 1
fi

# Reply to the thread
REPLY_MUTATION='
mutation($threadId: ID!, $body: String!) {
  addPullRequestReviewThreadReply(input: {pullRequestReviewThreadId: $threadId, body: $body}) {
    comment { id }
  }
}
'

gh api graphql \
	-F threadId="$THREAD_ID" \
	-F body="$REPLY_MESSAGE" \
	-f query="$REPLY_MUTATION" >/dev/null 2>&1 || {
	echo "WARNING: Failed to reply to thread (may already have reply)" >&2
}

# Resolve the thread
RESOLVE_MUTATION='
mutation($threadId: ID!) {
  resolveReviewThread(input: {threadId: $threadId}) {
    thread { isResolved }
  }
}
'

RESULT=$(gh api graphql \
	-F threadId="$THREAD_ID" \
	-f query="$RESOLVE_MUTATION" 2>/dev/null) || {
	echo "ERROR: Failed to resolve thread $THREAD_ID" >&2
	exit 1
}

IS_RESOLVED=$(echo "$RESULT" | jq -r '.data.resolveReviewThread.thread.isResolved')
if [ "$IS_RESOLVED" = "true" ]; then
	echo "RESOLVED: $THREAD_ID"
else
	echo "ERROR: Thread not marked as resolved" >&2
	exit 1
fi
