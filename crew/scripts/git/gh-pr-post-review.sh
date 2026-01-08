#!/bin/bash
# Post a review with file-level comments to a GitHub PR
# Usage: ./gh-pr-post-review.sh <PR_NUMBER> <REVIEW_EVENT> <BODY_FILE> [COMMENTS_JSON_FILE]
# REVIEW_EVENT: APPROVE, REQUEST_CHANGES, COMMENT
# BODY_FILE: File containing the overall review body
# COMMENTS_JSON_FILE: Optional JSON file with array of {path, line, body} comments

set -euo pipefail

PR_NUMBER="${1:-}"
REVIEW_EVENT="${2:-COMMENT}"
BODY_FILE="${3:-}"
COMMENTS_FILE="${4:-}"

if [ -z "$PR_NUMBER" ] || [ -z "$BODY_FILE" ]; then
  echo "ERROR: PR_NUMBER and BODY_FILE are required" >&2
  echo "Usage: $0 <PR_NUMBER> <REVIEW_EVENT> <BODY_FILE> [COMMENTS_JSON_FILE]" >&2
  exit 1
fi

if [ ! -f "$BODY_FILE" ]; then
  echo "ERROR: Body file not found: $BODY_FILE" >&2
  exit 1
fi

# Validate REVIEW_EVENT
case "$REVIEW_EVENT" in
  APPROVE | REQUEST_CHANGES | COMMENT) ;;
  *)
    echo "ERROR: Invalid REVIEW_EVENT. Use APPROVE, REQUEST_CHANGES, or COMMENT" >&2
    exit 1
    ;;
esac

# Get repo info
OWNER=$(gh repo view --json owner -q '.owner.login')
REPO=$(gh repo view --json name -q '.name')

# Get PR head SHA (required for review comments)
HEAD_SHA=$(gh pr view "$PR_NUMBER" --json headRefOid -q '.headRefOid')
if [ -z "$HEAD_SHA" ]; then
  echo "ERROR: Could not get head SHA for PR #$PR_NUMBER" >&2
  exit 1
fi

# Read body
BODY=$(cat "$BODY_FILE")

# Build comments array
if [ -n "$COMMENTS_FILE" ] && [ -f "$COMMENTS_FILE" ]; then
  COMMENTS=$(cat "$COMMENTS_FILE")
else
  COMMENTS="[]"
fi

# GraphQL mutation for creating a review with comments
# shellcheck disable=SC2016 # Single quotes intentional - GraphQL variables
MUTATION='
mutation($input: AddPullRequestReviewInput!) {
  addPullRequestReview(input: $input) {
    pullRequestReview {
      id
      state
      url
    }
  }
}
'

# Get PR node ID
PR_NODE_ID=$(gh api "repos/$OWNER/$REPO/pulls/$PR_NUMBER" --jq '.node_id')
if [ -z "$PR_NODE_ID" ]; then
  echo "ERROR: Could not get PR node ID" >&2
  exit 1
fi

# Build input JSON
INPUT=$(jq -n \
  --arg prId "$PR_NODE_ID" \
  --arg body "$BODY" \
  --arg event "$REVIEW_EVENT" \
  --arg sha "$HEAD_SHA" \
  --argjson comments "$COMMENTS" \
  '{
    pullRequestId: $prId,
    body: $body,
    event: $event,
    commitOID: $sha,
    comments: ($comments | map({
      path: .path,
      body: .body,
      line: .line
    }) | if length == 0 then null else . end)
  } | with_entries(select(.value != null))')

# Submit review
RESULT=$(
  gh api graphql \
    -f query="$MUTATION" \
    --input - <<EOF
{"input": $INPUT}
EOF
) || {
  echo "ERROR: Failed to submit review" >&2
  exit 1
}

# Output result
REVIEW_URL=$(echo "$RESULT" | jq -r '.data.addPullRequestReview.pullRequestReview.url')
REVIEW_STATE=$(echo "$RESULT" | jq -r '.data.addPullRequestReview.pullRequestReview.state')

echo "REVIEW_SUBMITTED=true"
echo "REVIEW_STATE=$REVIEW_STATE"
echo "REVIEW_URL=$REVIEW_URL"
