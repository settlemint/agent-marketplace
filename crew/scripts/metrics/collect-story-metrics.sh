#!/usr/bin/env bash
# Collect cheap metrics after story completion (Tier 1)
# Returns JSON with git diff stats for adaptive decision making
#
# Performance: Runs in <100ms using only git commands
# No expensive operations (coverage, complexity analysis)

set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
BASE_BRANCH="${1:-main}"

cd "$PROJECT_DIR"

# Get diff stats against base branch
DIFF_STATS=$(git diff "$BASE_BRANCH"...HEAD --stat 2>/dev/null | tail -1 || echo "")

# Parse: "12 files changed, 340 insertions(+), 45 deletions(-)"
FILES=$(echo "$DIFF_STATS" | grep -oE '[0-9]+ file' | grep -oE '[0-9]+' || echo "0")
INSERTIONS=$(echo "$DIFF_STATS" | grep -oE '[0-9]+ insertion' | grep -oE '[0-9]+' || echo "0")
DELETIONS=$(echo "$DIFF_STATS" | grep -oE '[0-9]+ deletion' | grep -oE '[0-9]+' || echo "0")

# Get file types changed
FILE_TYPES=$(git diff "$BASE_BRANCH"...HEAD --name-only 2>/dev/null |
  sed 's/.*\.//' |
  sort |
  uniq -c |
  awk '{printf "\"%s\": %d, ", $2, $1}' |
  sed 's/, $//' || echo "")

# Output JSON for plan integration
cat <<EOF
{
  "files_changed": ${FILES:-0},
  "lines_added": ${INSERTIONS:-0},
  "lines_removed": ${DELETIONS:-0},
  "file_types": {${FILE_TYPES}},
  "collected_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
