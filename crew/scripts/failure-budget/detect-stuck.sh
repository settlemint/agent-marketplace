#!/usr/bin/env bash
# Detect if execution is stuck in a loop
# Analyzes progress trend to identify oscillating errors
#
# Usage: detect-stuck.sh [error_count]
#
# Exit codes:
#   0 - Making progress
#   1 - Stuck (no progress after 3+ iterations)

set -euo pipefail

CURRENT_ERROR_COUNT="${1:-0}"

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
  echo '{}' >"$STATE_FILE"
fi

# Get previous error counts (history of last 5)
HISTORY=$(jq -r '.stuck_detection.error_history // []' "$STATE_FILE")

# Add current count to history
NEW_HISTORY=$(echo "$HISTORY" | jq --argjson count "$CURRENT_ERROR_COUNT" '. + [$count] | .[-5:]')

# Update state with new history
jq --argjson history "$NEW_HISTORY" '.stuck_detection.error_history = $history' \
  "$STATE_FILE" >"${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

# Analyze trend (need at least 3 data points)
HISTORY_LENGTH=$(echo "$NEW_HISTORY" | jq 'length')
if [[ $HISTORY_LENGTH -lt 3 ]]; then
  echo "PROGRESS: Insufficient data (${HISTORY_LENGTH}/3 iterations)"
  exit 0
fi

# Check for progress: error count should be decreasing
# Get last 3 values
LAST_THREE=$(echo "$NEW_HISTORY" | jq '.[-3:]')
FIRST=$(echo "$LAST_THREE" | jq '.[0]')
SECOND=$(echo "$LAST_THREE" | jq '.[1]')
THIRD=$(echo "$LAST_THREE" | jq '.[2]')

# Progress = TRUE if error count decreased at any point
if [[ $SECOND -lt $FIRST ]] || [[ $THIRD -lt $SECOND ]]; then
  echo "PROGRESS: Error count decreasing ($FIRST -> $SECOND -> $THIRD)"
  # Reset consecutive no-progress counter
  jq '.stuck_detection.no_progress_count = 0' "$STATE_FILE" >"${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"
  exit 0
fi

# No progress - increment counter
NO_PROGRESS=$(jq -r '.stuck_detection.no_progress_count // 0' "$STATE_FILE")
NO_PROGRESS=$((NO_PROGRESS + 1))
jq --argjson count "$NO_PROGRESS" '.stuck_detection.no_progress_count = $count' \
  "$STATE_FILE" >"${STATE_FILE}.tmp" && mv "${STATE_FILE}.tmp" "$STATE_FILE"

# Stuck if 3+ iterations with no progress
if [[ $NO_PROGRESS -ge 3 ]]; then
  echo "STUCK: No progress after $NO_PROGRESS iterations (errors: $FIRST -> $SECOND -> $THIRD)"
  exit 1
fi

echo "WARNING: No progress ($NO_PROGRESS/3 iterations)"
exit 0
