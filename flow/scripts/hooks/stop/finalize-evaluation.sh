#!/usr/bin/env bash
# Finalize session evaluation and write log
# Hook: Stop

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="finalize-evaluation"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=../lib/evaluation-lib.sh
source "$SCRIPT_DIR/../lib/evaluation-lib.sh"
log_init

# Read event data from stdin (not currently used but consumed for hook protocol)
EVENT_DATA=$(cat)

log_debug "event=EVAL_FINALIZE_START"

# Check if evaluation state exists
if [[ ! -f "$EVAL_STATE_FILE" ]]; then
  log_debug "event=EVAL_FINALIZE_SKIPPED" "reason=no_state_file"
  exit 0
fi

# Check if there are any tool calls to analyze
TOOL_COUNT=$(jq '.tool_calls | length' "$EVAL_STATE_FILE" 2>/dev/null || echo "0")
if [[ "$TOOL_COUNT" -eq 0 ]]; then
  log_debug "event=EVAL_FINALIZE_SKIPPED" "reason=no_tool_calls"
  exit 0
fi

# Write the evaluation log
LOG_FILE=$(write_evaluation_log "$EVAL_STATE_FILE")

if [[ -n "$LOG_FILE" && -f "$LOG_FILE" ]]; then
  log_info "event=EVAL_LOG_WRITTEN" "file=$LOG_FILE" "tool_count=$TOOL_COUNT"

  # Generate and output summary hint
  generate_summary_hint "$LOG_FILE"

  # Clean up session state file (keep archive)
  rm -f "$EVAL_STATE_FILE"

  # Clean up counter files
  rm -f "$PROJECT_DIR/.claude/flow/.eval-counter-"* 2>/dev/null
else
  log_warn "event=EVAL_LOG_FAILED" "reason=write_error"
fi

# Clean up old evaluation logs (older than 30 days)
find "$LOGS_DIR" -name "*-evaluation.json" -mtime +30 -delete 2>/dev/null

exit 0
