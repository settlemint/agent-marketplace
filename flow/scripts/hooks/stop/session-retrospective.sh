#!/usr/bin/env bash
# Session retrospective - auto-extracts learnings from corrections log
# This runs at Stop to capture insights before session ends
# No longer relies on Claude to write the file - does it automatically

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="session-retrospective"
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
LEARNINGS_DIR="$PROJECT_DIR/.claude/flow/learnings"
CORRECTIONS_LOG="$PROJECT_DIR/.claude/flow/corrections.jsonl"
SKILL_LOG="$PROJECT_DIR/.claude/flow/skill-activations.jsonl"
LOGS_DIR="$PROJECT_DIR/.claude/flow/logs"

# Get current session ID
SESSION_ID=$(get_session_id)

# --- Collect corrections for this session ---
SESSION_CORRECTIONS=""
CORRECTION_COUNT=0
if [[ -f "$CORRECTIONS_LOG" ]]; then
  SESSION_CORRECTIONS=$(grep "\"session_id\":\"$SESSION_ID\"" "$CORRECTIONS_LOG" 2>/dev/null || true)
  if [[ -n "$SESSION_CORRECTIONS" ]]; then
    CORRECTION_COUNT=$(echo "$SESSION_CORRECTIONS" | wc -l | tr -d ' ')
  fi
fi

# --- Collect skill activations for this session ---
SESSION_SKILLS=""
SKILL_COUNT=0
if [[ -f "$SKILL_LOG" ]]; then
  SESSION_SKILLS=$(grep "\"session_id\":\"$SESSION_ID\"" "$SKILL_LOG" 2>/dev/null || true)
  if [[ -n "$SESSION_SKILLS" ]]; then
    SKILL_COUNT=$(echo "$SESSION_SKILLS" | wc -l | tr -d ' ')
  fi
fi

# --- Collect errors from today's logs ---
TODAY=$(date +%Y-%m-%d)
HOOK_ERRORS=""
if [[ -d "$LOGS_DIR" ]]; then
  HOOK_ERRORS=$(grep -h "ERROR" "$LOGS_DIR"/*.log 2>/dev/null | grep "$TODAY" | head -5 || true)
fi
ERROR_COUNT=0
if [[ -n "$HOOK_ERRORS" ]]; then
  ERROR_COUNT=$(echo "$HOOK_ERRORS" | wc -l | tr -d ' ')
fi

# --- Decide if learnings file should be created ---
# Skip trivial sessions: no corrections, no errors, < 3 skill activations
if [[ "$CORRECTION_COUNT" -eq 0 && "$ERROR_COUNT" -eq 0 && "$SKILL_COUNT" -lt 3 ]]; then
  log_info "event=RETROSPECTIVE_SKIPPED" "reason=trivial_session" "corrections=0" "errors=0" "skills=$SKILL_COUNT"
  exit 0
fi

# --- Generate learnings file ---
mkdir -p "$LEARNINGS_DIR" 2>/dev/null || true

TIMESTAMP=$(date +%Y-%m-%d-%H%M)
BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")
SAFE_BRANCH="${BRANCH//\//-}"
LEARNINGS_FILE="$LEARNINGS_DIR/${TIMESTAMP}-${SAFE_BRANCH}.md"

{
  echo "# Session Learnings - $TIMESTAMP (auto-generated)"
  echo ""
  echo "**Branch:** $BRANCH"
  echo "**Session:** $SESSION_ID"
  echo ""

  # --- Direction Changes Section ---
  if [[ "$CORRECTION_COUNT" -gt 0 ]]; then
    echo "## Direction Changes Detected"
    echo ""
    echo "| Time | Pattern | User Said |"
    echo "|------|---------|-----------|"
    echo "$SESSION_CORRECTIONS" | while IFS= read -r line; do
      ts=$(echo "$line" | jq -r '.timestamp // ""' 2>/dev/null)
      pattern=$(echo "$line" | jq -r '.correction_pattern // ""' 2>/dev/null)
      prompt=$(echo "$line" | jq -r '.prompt_excerpt // ""' 2>/dev/null | head -c 80)
      # Format timestamp to just time
      time_only="${ts#*T}"
      time_only="${time_only%Z}"
      echo "| $time_only | \`$pattern\` | ${prompt}... |"
    done
    echo ""
  fi

  # --- Errors Section ---
  if [[ "$ERROR_COUNT" -gt 0 ]]; then
    echo "## Errors Encountered"
    echo ""
    echo '```'
    echo "$HOOK_ERRORS"
    echo '```'
    echo ""
  fi

  # --- Skills Section ---
  if [[ "$SKILL_COUNT" -gt 0 ]]; then
    echo "## Skills Loaded"
    echo ""
    echo "$SESSION_SKILLS" | jq -r '.skill' 2>/dev/null | sort | uniq -c | sort -rn | while read -r count skill; do
      echo "- **$skill**: $count activation(s)"
    done
    echo ""
  fi

  # --- Session Stats ---
  echo "## Session Stats"
  echo ""
  echo "- Corrections detected: $CORRECTION_COUNT"
  echo "- Errors encountered: $ERROR_COUNT"
  echo "- Skills activated: $SKILL_COUNT"
  echo ""

  # --- Actionable Insights ---
  if [[ "$CORRECTION_COUNT" -gt 0 ]]; then
    echo "## Potential Improvements"
    echo ""
    echo "Based on detected corrections, consider:"
    echo ""
    echo "$SESSION_CORRECTIONS" | jq -r '.correction_pattern' 2>/dev/null | sort | uniq -c | sort -rn | head -3 | while read -r count pattern; do
      case "$pattern" in
        *"actually"* | *"instead"*)
          echo "- **Alternative approach preferred**: User redirected to a different solution"
          ;;
        *"wrong"* | *"^no"* | *"not what"* | *"not like"* | *"not correct"*)
          echo "- **Initial approach rejected**: Consider asking for clarification earlier"
          ;;
        *"scratch"* | *"forget"* | *"cancel"*)
          echo "- **Task abandoned**: May indicate misunderstanding of requirements"
          ;;
        *)
          echo "- **Correction detected**: Pattern \`$pattern\` ($count occurrences)"
          ;;
      esac
    done
    echo ""
  fi

} >"$LEARNINGS_FILE"

log_info "event=LEARNINGS_GENERATED" "file=$LEARNINGS_FILE" "corrections=$CORRECTION_COUNT" "errors=$ERROR_COUNT" "skills=$SKILL_COUNT"

# Output a brief summary to stdout (shown to user)
echo ""
echo "<flow-session-summary>"
echo "Session learnings saved to: $LEARNINGS_FILE"
echo "- $CORRECTION_COUNT direction change(s) captured"
echo "- $ERROR_COUNT error(s) logged"
echo "- $SKILL_COUNT skill activation(s)"
echo "</flow-session-summary>"

exit 0
