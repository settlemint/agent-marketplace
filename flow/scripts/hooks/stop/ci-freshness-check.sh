#!/usr/bin/env bash
# CI freshness check at session end
# Warns if CI is stale and code changes were made

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="ci-freshness-check"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read event data
EVENT_DATA=$(cat)

# Skip for subagents
AGENT_TYPE=$(echo "$EVENT_DATA" | jq -r '.agent_type // "main"' 2>/dev/null || echo "main")
if [[ "$AGENT_TYPE" != "main" ]]; then
  exit 0
fi

# --- Paths ---
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
QA_FILE="$PROJECT_DIR/.claude/state/qa-timestamp"

# --- Check for code changes in this session ---
HAS_CODE_CHANGES=false
CODE_PATTERNS='\.(ts|tsx|js|jsx|py|go|rs|java|c|cpp|h|hpp|rb|php|swift|kt)$'

# Check staged/unstaged changes
if git -C "$PROJECT_DIR" diff --name-only 2>/dev/null | grep -qE "$CODE_PATTERNS"; then
  HAS_CODE_CHANGES=true
fi
if git -C "$PROJECT_DIR" diff --cached --name-only 2>/dev/null | grep -qE "$CODE_PATTERNS"; then
  HAS_CODE_CHANGES=true
fi

# --- Check CI freshness ---
CI_STATUS="unknown"
CI_AGE=""

if [[ -f "$QA_FILE" ]]; then
  LAST_QA=$(cat "$QA_FILE")
  NOW=$(date +%s)
  AGE=$((NOW - LAST_QA))
  CI_AGE="${AGE}s"

  if [[ $AGE -lt 300 ]]; then
    CI_STATUS="fresh"
  else
    CI_STATUS="stale"
  fi
else
  CI_STATUS="missing"
fi

# --- Output based on status ---
log_info "event=CI_CHECK" "status=$CI_STATUS" "age=$CI_AGE" "code_changes=$HAS_CODE_CHANGES"

echo ""
echo "<flow-ci-status>"

case "$CI_STATUS" in
  "fresh")
    echo "CI: Fresh (${CI_AGE} ago) - ready to push"
    ;;
  "stale")
    if [[ "$HAS_CODE_CHANGES" == "true" ]]; then
      echo "CI: STALE (${CI_AGE} ago) - run \`bun run ci\` before pushing code changes"
      echo "Update timestamp: mkdir -p .claude/state && date +%s > .claude/state/qa-timestamp"
    else
      echo "CI: Stale (${CI_AGE} ago) - no code changes detected, OK to skip"
    fi
    ;;
  "missing")
    if [[ "$HAS_CODE_CHANGES" == "true" ]]; then
      echo "CI: No baseline - run \`bun run ci\` to establish CI health"
    else
      echo "CI: No baseline recorded"
    fi
    ;;
esac

echo "</flow-ci-status>"

exit 0
