#!/usr/bin/env bash
# Track a failure and update the failure budget
# Called after worker/CI/review failures
#
# Usage: track-failure.sh <category> [error_signature]
# Categories: worker, ci, review
#
# Updates .claude/branches/{branch}/state.json with failure counts

set -euo pipefail

CATEGORY="${1:-worker}"
ERROR_SIG="${2:-}"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Get branch info
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo 'unknown')
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')

# State location
BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
STATE_FILE="$BRANCH_DIR/state.json"

# Ensure state file exists
mkdir -p "$BRANCH_DIR"
if [[ ! -f $STATE_FILE ]]; then
  echo '{"failure_budget":{}}' >"$STATE_FILE"
fi

# Initialize failure_budget if not present
if ! jq -e '.failure_budget' "$STATE_FILE" >/dev/null 2>&1; then
  jq '. + {"failure_budget": {
    "worker": {"current": 0, "max": 5, "consecutive": 0},
    "ci": {"iterations": 0, "max": 3},
    "review": {"passes": 0, "unfixed_p1": 0},
    "error_signatures": []
  }}' "$STATE_FILE" >"${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
fi

# Update failure count based on category
case "$CATEGORY" in
  worker)
    jq '.failure_budget.worker.current += 1 | .failure_budget.worker.consecutive += 1' \
      "$STATE_FILE" >"${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    ;;
  ci)
    jq '.failure_budget.ci.iterations += 1' \
      "$STATE_FILE" >"${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    ;;
  review)
    jq '.failure_budget.review.passes += 1' \
      "$STATE_FILE" >"${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
    ;;
esac

# Track error signature for deduplication
if [[ -n "$ERROR_SIG" ]]; then
  jq --arg sig "$ERROR_SIG" '.failure_budget.error_signatures += [$sig] | .failure_budget.error_signatures |= unique' \
    "$STATE_FILE" >"${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
fi

# Output current budget status
jq -r '.failure_budget | "Budget: worker=\(.worker.current // 0)/\(.worker.max // 5), ci=\(.ci.iterations // 0)/\(.ci.max // 3), review=\(.review.passes // 0)/5"' "$STATE_FILE"
