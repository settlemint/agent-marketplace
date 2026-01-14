#!/usr/bin/env bash
# Check failure budget before spawning a worker
# Returns non-zero exit code if budget exceeded
#
# Usage: check-budget.sh <category>
# Categories: worker, ci, review
#
# Exit codes:
#   0 - Budget OK, can proceed
#   1 - Budget exceeded, should escalate

set -euo pipefail

CATEGORY="${1:-worker}"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Get branch info
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo 'unknown')
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')

# State location
BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
STATE_FILE="$BRANCH_DIR/state.json"

# If no state file, budget is OK
if [[ ! -f $STATE_FILE ]]; then
  exit 0
fi

# Check budget based on category
case "$CATEGORY" in
  worker)
    CURRENT=$(jq -r '.failure_budget.worker.current // 0' "$STATE_FILE")
    MAX=$(jq -r '.failure_budget.worker.max // 5' "$STATE_FILE")
    ;;
  ci)
    CURRENT=$(jq -r '.failure_budget.ci.iterations // 0' "$STATE_FILE")
    MAX=$(jq -r '.failure_budget.ci.max // 3' "$STATE_FILE")
    ;;
  review)
    CURRENT=$(jq -r '.failure_budget.review.passes // 0' "$STATE_FILE")
    MAX=5 # Rule of Five
    ;;
  *)
    echo "Unknown category: $CATEGORY" >&2
    exit 1
    ;;
esac

# Check if budget exceeded
if [[ $CURRENT -ge $MAX ]]; then
  echo "BUDGET_EXCEEDED: $CATEGORY ($CURRENT/$MAX)"
  exit 1
fi

echo "BUDGET_OK: $CATEGORY ($CURRENT/$MAX)"
exit 0
