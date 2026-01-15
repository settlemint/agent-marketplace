#!/usr/bin/env bash
# Capture tool usage for session self-evaluation
# Hook: PostToolUse (all tools)

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="capture-tool-usage"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
# shellcheck source=../lib/evaluation-lib.sh
source "$SCRIPT_DIR/../lib/evaluation-lib.sh"
log_init

# Read tool output from stdin
TOOL_OUTPUT=$(cat)

# Extract tool information
TOOL_NAME=$(echo "$TOOL_OUTPUT" | jq -r '.tool_name // "unknown"' 2>/dev/null || echo "unknown")
TOOL_INPUT=$(echo "$TOOL_OUTPUT" | jq -c '.tool_input // {}' 2>/dev/null || echo '{}')
TOOL_RESULT=$(echo "$TOOL_OUTPUT" | jq -r '.tool_result // ""' 2>/dev/null || echo "")

# Determine success/failure
SUCCESS=true
ERROR_TYPE=""

# Check for error indicators in result
if echo "$TOOL_RESULT" | grep -qiE "error|failed|exception|ENOENT|permission denied|command not found|FAIL|timeout"; then
  SUCCESS=false
  ERROR_TYPE=$(classify_error "$TOOL_RESULT")
fi

# Determine if we should capture this call (sampling for high-frequency tools)
if ! should_capture "$TOOL_NAME" "$SUCCESS"; then
  log_debug "event=TOOL_SKIPPED" "tool=$TOOL_NAME" "reason=sampling"
  exit 0
fi

# Check state file size before adding
check_state_size

# Create input preview (truncated for storage efficiency)
INPUT_PREVIEW=$(echo "$TOOL_INPUT" | jq -c '.' 2>/dev/null | head -c 150)

# Generate input hash for retry detection
INPUT_HASH=$(echo "$TOOL_INPUT" | sha256sum 2>/dev/null | cut -d' ' -f1 | head -c 16)

# Detect if this is a retry
IS_RETRY=$(detect_retry_pattern "$INPUT_HASH" "$EVAL_STATE_FILE")

# Extract file path if present (for file operations)
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // .path // .command // ""' 2>/dev/null | head -c 100)

# Create tool call entry
TIMESTAMP=$(date -u +%Y-%m-%dT%H:%M:%SZ)
ENTRY=$(jq -n \
  --arg ts "$TIMESTAMP" \
  --arg tool "$TOOL_NAME" \
  --argjson success "$SUCCESS" \
  --arg err_type "$ERROR_TYPE" \
  --arg preview "$INPUT_PREVIEW" \
  --arg hash "$INPUT_HASH" \
  --argjson retry "$IS_RETRY" \
  --arg file "$FILE_PATH" \
  '{
    timestamp: $ts,
    tool_name: $tool,
    success: $success,
    error_type: (if $err_type == "" then null else $err_type end),
    input_preview: $preview,
    input_hash: $hash,
    is_retry: $retry,
    file_path: (if $file == "" then null else $file end)
  }')

# Append to session evaluator state
if append_tool_call "$ENTRY"; then
  if [[ "$SUCCESS" == "false" ]]; then
    SUGGESTION=$(suggest_skill_for_error "$ERROR_TYPE")
    log_info "event=TOOL_CAPTURED" "tool=$TOOL_NAME" "success=false" "error_type=$ERROR_TYPE" "suggestion=$SUGGESTION"
  else
    log_debug "event=TOOL_CAPTURED" "tool=$TOOL_NAME" "success=true"
  fi
else
  log_warn "event=TOOL_CAPTURE_FAILED" "tool=$TOOL_NAME"
fi

exit 0
