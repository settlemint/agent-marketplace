#!/usr/bin/env bash
# Full PR status dashboard: CI checks, reviews, threads, mergeable state
# Usage: pr-status.sh [--json] [owner/repo#pr]
# Exit codes: 0 = ready to merge, 1 = blocked, 2 = no PR found

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
JSON_MODE=false
PR_REF=""

for arg in "$@"; do
  case "$arg" in
    --json) JSON_MODE=true ;;
    */*#*) PR_REF="$arg" ;;
  esac
done

# Resolve PR number and repo
if [[ -n "$PR_REF" ]]; then
  OWNER=$(echo "$PR_REF" | cut -d'/' -f1)
  REPO=$(echo "$PR_REF" | cut -d'/' -f2 | cut -d'#' -f1)
  PR_NUM=$(echo "$PR_REF" | cut -d'#' -f2)
  GH_REPO="$OWNER/$REPO"
else
  PR_JSON=$(gh pr view --json number,url 2>/dev/null) || {
    echo "No PR found for current branch" >&2
    exit 2
  }
  PR_NUM=$(echo "$PR_JSON" | jq -r '.number')
  PR_URL=$(echo "$PR_JSON" | jq -r '.url')
  OWNER=$(echo "$PR_URL" | sed -n 's|.*github.com/\([^/]*\)/.*|\1|p')
  REPO=$(echo "$PR_URL" | sed -n 's|.*github.com/[^/]*/\([^/]*\)/.*|\1|p')
  GH_REPO="$OWNER/$REPO"
fi

# Single gh pr view call for CI, reviews, mergeable state
PR_DATA=$(gh pr view "$PR_NUM" --repo "$GH_REPO" --json \
  "statusCheckRollup,reviews,reviewDecision,mergeStateStatus,mergeable,title,state,headRefName" 2>/dev/null) || {
  echo "Failed to fetch PR #$PR_NUM" >&2
  exit 2
}

TITLE=$(echo "$PR_DATA" | jq -r '.title')
STATE=$(echo "$PR_DATA" | jq -r '.state')
BRANCH=$(echo "$PR_DATA" | jq -r '.headRefName')
MERGEABLE=$(echo "$PR_DATA" | jq -r '.mergeable')
MERGE_STATE=$(echo "$PR_DATA" | jq -r '.mergeStateStatus')
REVIEW_DECISION=$(echo "$PR_DATA" | jq -r '.reviewDecision // ""')

# Parse CI checks
CI_CHECKS=$(echo "$PR_DATA" | jq -c '[
  (.statusCheckRollup // [])[] |
  {name: (.name // .context // "unknown"), status: (.status // "UNKNOWN"), conclusion: (.conclusion // "PENDING")}
]')
CI_TOTAL=$(echo "$CI_CHECKS" | jq 'length')
CI_PASS=$(echo "$CI_CHECKS" | jq '[.[] | select(.conclusion == "SUCCESS")] | length')
CI_FAIL=$(echo "$CI_CHECKS" | jq '[.[] | select(.conclusion == "FAILURE" or .conclusion == "ERROR")] | length')
CI_PENDING=$(echo "$CI_CHECKS" | jq '[.[] | select(.conclusion == "PENDING" or .conclusion == null or .conclusion == "")] | length')

# Parse reviews
REVIEWS=$(echo "$PR_DATA" | jq -c '[
  (.reviews // [])[] |
  {author: .author.login, state: .state}
] | group_by(.author) | map(sort_by(.state) | last)')

# Unresolved threads
THREAD_COUNT=$("$SCRIPT_DIR/count-unresolved-threads.sh" ${PR_REF:+"$PR_REF"} 2>/dev/null) || THREAD_COUNT="?"

# Determine verdict
BLOCKED_REASONS=()

if [[ "$STATE" != "OPEN" ]]; then
  BLOCKED_REASONS+=("PR is $STATE")
fi

if [[ "$CI_FAIL" -gt 0 ]]; then
  BLOCKED_REASONS+=("$CI_FAIL CI check(s) failing")
fi

if [[ "$CI_PENDING" -gt 0 ]]; then
  BLOCKED_REASONS+=("$CI_PENDING CI check(s) pending")
fi

if [[ "$REVIEW_DECISION" != "APPROVED" && "$REVIEW_DECISION" != "" ]]; then
  BLOCKED_REASONS+=("Review decision: $REVIEW_DECISION")
fi

if [[ "$THREAD_COUNT" == "?" ]]; then
  BLOCKED_REASONS+=("Thread count unknown (API error)")
elif [[ "$THREAD_COUNT" != "0" ]]; then
  BLOCKED_REASONS+=("$THREAD_COUNT unresolved thread(s)")
fi

if [[ "$MERGEABLE" == "CONFLICTING" ]]; then
  BLOCKED_REASONS+=("Merge conflicts")
fi

if [[ "$MERGE_STATE" == "BLOCKED" ]]; then
  BLOCKED_REASONS+=("Merge state: BLOCKED")
fi

READY=true
if [[ ${#BLOCKED_REASONS[@]} -gt 0 ]]; then
  READY=false
fi

# Output
if $JSON_MODE; then
  THREAD_DETAILS="[]"
  if [[ "$THREAD_COUNT" != "0" && "$THREAD_COUNT" != "?" ]]; then
    THREAD_DETAILS=$("$SCRIPT_DIR/get-unresolved-threads.sh" ${PR_REF:+"$PR_REF"} 2>/dev/null | jq -s '.' 2>/dev/null) || THREAD_DETAILS="[]"
  fi

  jq -n \
    --arg title "$TITLE" \
    --arg branch "$BRANCH" \
    --arg state "$STATE" \
    --arg mergeable "$MERGEABLE" \
    --arg mergeState "$MERGE_STATE" \
    --arg reviewDecision "$REVIEW_DECISION" \
    --argjson ciChecks "$CI_CHECKS" \
    --argjson reviews "$REVIEWS" \
    --arg threadCount "$THREAD_COUNT" \
    --argjson threadDetails "$THREAD_DETAILS" \
    --argjson ready "$READY" \
    --argjson blockedReasons "$(printf '%s\n' "${BLOCKED_REASONS[@]+"${BLOCKED_REASONS[@]}"}" | jq -R . | jq -s '.')" \
    '{
      title: $title,
      branch: $branch,
      state: $state,
      mergeable: $mergeable,
      mergeState: $mergeState,
      reviewDecision: $reviewDecision,
      ci: {checks: $ciChecks, pass: ($ciChecks | map(select(.conclusion == "SUCCESS")) | length), fail: ($ciChecks | map(select(.conclusion == "FAILURE" or .conclusion == "ERROR")) | length), pending: ($ciChecks | map(select(.conclusion == "PENDING" or .conclusion == null or .conclusion == "")) | length), total: ($ciChecks | length)},
      reviews: $reviews,
      threads: {count: ($threadCount | tonumber? // 0), details: $threadDetails},
      ready: $ready,
      blockedReasons: $blockedReasons
    }'
  if $READY; then exit 0; else exit 1; fi
fi

# Human-readable output
echo "━━━ PR #$PR_NUM: $TITLE ━━━"
echo "Branch: $BRANCH | State: $STATE | Mergeable: $MERGEABLE"
echo ""

# CI Checks
echo "CI Checks ($CI_PASS/$CI_TOTAL passed):"
echo "$CI_CHECKS" | jq -r '.[] | "  " + (if .conclusion == "SUCCESS" then "✓" elif .conclusion == "FAILURE" or .conclusion == "ERROR" then "✗" else "◌" end) + " " + .name'
echo ""

# Reviews
echo "Reviews (decision: $REVIEW_DECISION):"
echo "$REVIEWS" | jq -r '.[] | "  " + (if .state == "APPROVED" then "✓" elif .state == "CHANGES_REQUESTED" then "✗" elif .state == "COMMENTED" then "◌" else "—" end) + " " + .author + " (" + .state + ")"'
echo ""

# Threads
echo "Unresolved Threads: $THREAD_COUNT"
if [[ "$THREAD_COUNT" != "0" && "$THREAD_COUNT" != "?" ]]; then
  "$SCRIPT_DIR/get-unresolved-threads.sh" ${PR_REF:+"$PR_REF"} 2>/dev/null | jq -r '"  " + .path + ":" + (.line | tostring) + " — " + .author + ": " + .body[0:80]' 2>/dev/null || true
fi
echo ""

# Verdict
if $READY; then
  echo "✓ READY TO MERGE"
  exit 0
else
  echo "✗ BLOCKED:"
  for reason in "${BLOCKED_REASONS[@]}"; do
    echo "  - $reason"
  done
  exit 1
fi
