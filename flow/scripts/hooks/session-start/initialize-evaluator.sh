#!/usr/bin/env bash
# Initialize session evaluation state
# Hook: SessionStart (startup, compact, resume)

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="initialize-evaluator"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=../lib/evaluation-lib.sh
source "$SCRIPT_DIR/../lib/evaluation-lib.sh"
log_init

# Read event data from stdin
EVENT_DATA=$(cat)

# Extract event type
EVENT_TYPE=$(echo "$EVENT_DATA" | jq -r '.event // "startup"' 2>/dev/null || echo "startup")

log_debug "event=EVAL_INIT_START" "event_type=$EVENT_TYPE"

case "$EVENT_TYPE" in
  startup)
    # Fresh session - initialize new evaluation state
    init_evaluator_state
    log_info "event=EVAL_STATE_INITIALIZED" "type=fresh"
    ;;

  compact | resume)
    # Resuming session - increment compaction count
    if [[ -f "$EVAL_STATE_FILE" ]]; then
      TMP_FILE=$(mktemp)
      jq '.compaction_count += 1' "$EVAL_STATE_FILE" >"$TMP_FILE" 2>/dev/null && mv "$TMP_FILE" "$EVAL_STATE_FILE"
      log_info "event=EVAL_STATE_RESUMED" "type=$EVENT_TYPE"
    else
      # State file missing, create fresh
      init_evaluator_state
      log_info "event=EVAL_STATE_INITIALIZED" "type=recovered"
    fi
    ;;

  *)
    log_debug "event=EVAL_INIT_SKIPPED" "reason=unknown_event_type"
    ;;
esac

exit 0
