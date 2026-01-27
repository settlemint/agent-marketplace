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
  GH_REPO=$(gh repo view --json nameWithOwner -q '.nameWithOwner' 2>/dev/null) || {
    echo "Not in a GitHub repository" >&2
    exit 2
  }
  PR_NUM=$(gh pr view --json number -q '.number' 2>/dev/null) || {
    echo "No PR found for current branch" >&2
    exit 2
  }
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

# Parse CI checks — handle both check runs (.conclusion) and commit statuses (.state)
CI_CHECKS=$(echo "$PR_DATA" | jq -c '[
  (.statusCheckRollup // [])[] |
  {
    name: (.name // .context // "unknown"),
    conclusion: (
      if .conclusion and .conclusion != "" and .conclusion != null then .conclusion
      elif .state == "SUCCESS" or .state == "EXPECTED" then "SUCCESS"
      elif .state == "FAILURE" or .state == "ERROR" then "FAILURE"
      elif .state == "PENDING" then "PENDING"
      elif .status == "COMPLETED" then (.conclusion // "PENDING")
      else "PENDING"
      end
    )
  }
]')
CI_TOTAL=$(echo "$CI_CHECKS" | jq 'length')
CI_PASS=$(echo "$CI_CHECKS" | jq '[.[] | select(.conclusion == "SUCCESS")] | length')
CI_FAIL=$(echo "$CI_CHECKS" | jq '[.[] | select(.conclusion == "FAILURE" or .conclusion == "ERROR")] | length')
CI_PENDING=$(echo "$CI_CHECKS" | jq '[.[] | select(.conclusion == "PENDING" or .conclusion == null or .conclusion == "")] | length')

# Parse reviews — take last review per author (array order is chronological)
REVIEWS=$(echo "$PR_DATA" | jq -c '[
  (.reviews // [])[] |
  {author: (.author.login // "unknown"), state: .state}
] | group_by(.author) | map(last)')

# Unresolved threads — fetch once, derive count from data
THREAD_DATA=$("$SCRIPT_DIR/get-unresolved-threads.sh" ${PR_REF:+"$PR_REF"} 2>/dev/null | jq -s '.' 2>/dev/null) || THREAD_DATA="[]"
THREAD_COUNT=$(echo "$THREAD_DATA" | jq 'length')

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
  jq -n \
    --arg title "$TITLE" \
    --arg branch "$BRANCH" \
    --arg state "$STATE" \
    --arg mergeable "$MERGEABLE" \
    --arg mergeState "$MERGE_STATE" \
    --arg reviewDecision "$REVIEW_DECISION" \
    --argjson ciChecks "$CI_CHECKS" \
    --argjson ciPass "$CI_PASS" \
    --argjson ciFail "$CI_FAIL" \
    --argjson ciPending "$CI_PENDING" \
    --argjson ciTotal "$CI_TOTAL" \
    --argjson reviews "$REVIEWS" \
    --argjson threadCount "$THREAD_COUNT" \
    --argjson threadDetails "$THREAD_DATA" \
    --argjson ready "$READY" \
    --argjson blockedReasons "$(printf '%s\n' "${BLOCKED_REASONS[@]+"${BLOCKED_REASONS[@]}"}" | jq -R . | jq -s '.')" \
    '{
      title: $title,
      branch: $branch,
      state: $state,
      mergeable: $mergeable,
      mergeState: $mergeState,
      reviewDecision: $reviewDecision,
      ci: {checks: $ciChecks, pass: $ciPass, fail: $ciFail, pending: $ciPending, total: $ciTotal},
      reviews: $reviews,
      threads: {count: $threadCount, details: $threadDetails},
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
if [[ "$THREAD_COUNT" -gt 0 ]] 2>/dev/null; then
  echo "$THREAD_DATA" | jq -r '.[] | "  " + .path + ":" + (.line | tostring) + " — " + .author + ": " + .body[0:80]' 2>/dev/null || true
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
