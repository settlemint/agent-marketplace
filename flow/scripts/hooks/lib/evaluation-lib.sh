#!/usr/bin/env bash
# Evaluation utilities for self-assessment hooks
# Source this file in evaluation-related hook scripts

# --- Paths ---
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
EVAL_STATE_FILE="$PROJECT_DIR/.claude/flow/session-evaluator.json"
LOGS_DIR="$PROJECT_DIR/.claude/logs"

# --- Configuration ---
EVAL_SAMPLE_RATE=${EVAL_SAMPLE_RATE:-3}
EVAL_MAX_STATE_KB=${EVAL_MAX_STATE_KB:-100}
EVAL_SHOW_SUMMARY=${EVAL_SHOW_SUMMARY:-true}

# --- Error Classification ---
# Classifies error messages into categories for skill suggestions
classify_error() {
  local result="$1"

  # Check for common error patterns
  if echo "$result" | grep -qiE "ENOENT|no such file|file not found|does not exist"; then
    echo "file_not_found"
  elif echo "$result" | grep -qiE "permission denied|EACCES"; then
    echo "permission_denied"
  elif echo "$result" | grep -qiE "syntax error|SyntaxError|unexpected token"; then
    echo "syntax_error"
  elif echo "$result" | grep -qiE "FAIL|test failed|AssertionError|expect.*received"; then
    echo "test_failure"
  elif echo "$result" | grep -qiE "timeout|ETIMEDOUT|timed out"; then
    echo "timeout"
  elif echo "$result" | grep -qiE "command not found|not recognized"; then
    echo "command_not_found"
  elif echo "$result" | grep -qiE "merge conflict|CONFLICT"; then
    echo "merge_conflict"
  elif echo "$result" | grep -qiE "type error|TypeError|cannot read property"; then
    echo "type_error"
  elif echo "$result" | grep -qiE "npm ERR|yarn error|pnpm ERR"; then
    echo "package_error"
  elif echo "$result" | grep -qiE "eslint|prettier|lint"; then
    echo "lint_error"
  else
    echo "unknown"
  fi
}

# --- Skill Suggestions ---
# Maps error types to skill recommendations
suggest_skill_for_error() {
  local error_type="$1"

  case "$error_type" in
    test_failure)
      echo 'Skill({ skill: "devtools:tdd-typescript" })'
      ;;
    lint_error)
      echo 'Run: shfmt -w -i 2 -ci <file> && shellcheck <file>'
      ;;
    type_error)
      echo 'Skill({ skill: "devtools:typescript-lsp" })'
      ;;
    package_error)
      echo 'Check package.json and run npm install'
      ;;
    merge_conflict)
      echo 'Skill({ skill: "devtools:git" })'
      ;;
    syntax_error)
      echo 'Review file syntax, check for missing brackets/quotes'
      ;;
    *)
      echo ''
      ;;
  esac
}

# --- Pattern Detection ---
# Detects if current operation is a retry of a recent operation
detect_retry_pattern() {
  local current_hash="$1"
  local eval_file="$2"

  if [[ ! -f "$eval_file" ]]; then
    echo "false"
    return
  fi

  # Check last 5 tool calls for same hash
  local recent_hashes
  recent_hashes=$(jq -r '.tool_calls[-5:][].input_hash // empty' "$eval_file" 2>/dev/null)

  if echo "$recent_hashes" | grep -q "$current_hash"; then
    echo "true"
  else
    echo "false"
  fi
}

# --- Multi-turn Pattern Detection ---
# Identifies common multi-turn sequences
detect_multi_turn_patterns() {
  local eval_file="$1"

  if [[ ! -f "$eval_file" ]]; then
    return
  fi

  # Detect grep->read->edit cycles
  local grep_read_edit_count
  grep_read_edit_count=$(jq '
    [.tool_calls[].tool_name] as $tools |
    [range(0; ($tools | length) - 2)] |
    map(select(
      $tools[.] == "Grep" and
      $tools[. + 1] == "Read" and
      $tools[. + 2] == "Edit"
    )) |
    length
  ' "$eval_file" 2>/dev/null || echo "0")

  # Detect test->edit->test cycles with failures
  local test_retry_count
  test_retry_count=$(jq '
    [.tool_calls | to_entries[] |
      select(.value.tool_name == "Bash" and
             (.value.input_preview | test("test|vitest|jest|bun test"; "i")) and
             .value.success == false)] |
    length
  ' "$eval_file" 2>/dev/null || echo "0")

  # Output patterns as JSON
  jq -n \
    --argjson grep_cycles "$grep_read_edit_count" \
    --argjson test_retries "$test_retry_count" \
    '{
      grep_read_edit_cycles: $grep_cycles,
      test_failure_retries: $test_retries
    }'
}

# --- Metrics Calculation ---
# Calculates aggregate metrics from session data
calculate_metrics() {
  local eval_file="$1"

  if [[ ! -f "$eval_file" ]]; then
    echo '{}'
    return
  fi

  jq '
    .tool_calls as $calls |
    ($calls | length) as $total |
    ([$calls[] | select(.success == true)] | length) as $successful |
    ([$calls[] | select(.success == false)] | length) as $failed |
    {
      total_tool_calls: $total,
      successful_calls: $successful,
      failed_calls: $failed,
      success_rate: (if $total > 0 then ($successful / $total) else 1 end),
      unique_tools: ([$calls[].tool_name] | unique)
    }
  ' "$eval_file" 2>/dev/null || echo '{}'
}

# --- State Management ---
# Initialize fresh evaluation state
init_evaluator_state() {
  local session_id="${CLAUDE_SESSION_ID:-$$}"
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

  mkdir -p "$(dirname "$EVAL_STATE_FILE")"

  jq -n \
    --arg sid "$session_id" \
    --arg branch "$branch" \
    --arg started "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    '{
      session_id: $sid,
      branch: $branch,
      started_at: $started,
      compaction_count: 0,
      tool_calls: [],
      task_count: 0
    }' >"$EVAL_STATE_FILE"
}

# Append a tool call to evaluation state
append_tool_call() {
  local entry="$1"

  if [[ ! -f "$EVAL_STATE_FILE" ]]; then
    return 1
  fi

  local tmp_file
  tmp_file=$(mktemp)

  jq --argjson entry "$entry" '
    .tool_calls += [$entry]
  ' "$EVAL_STATE_FILE" >"$tmp_file" 2>/dev/null && mv "$tmp_file" "$EVAL_STATE_FILE"
}

# Check if state file is too large and needs rotation
check_state_size() {
  if [[ ! -f "$EVAL_STATE_FILE" ]]; then
    return 0
  fi

  local size_kb
  size_kb=$(($(wc -c <"$EVAL_STATE_FILE") / 1024))

  if [[ $size_kb -gt $EVAL_MAX_STATE_KB ]]; then
    # Archive current state
    local archive_dir="$PROJECT_DIR/.claude/flow/eval-archive"
    mkdir -p "$archive_dir"
    mv "$EVAL_STATE_FILE" "$archive_dir/$(date -u +%Y%m%d%H%M%S)-session.json"

    # Reinitialize
    init_evaluator_state
    return 1
  fi

  return 0
}

# --- Sampling ---
# Determines if this tool call should be captured (for high-frequency tools)
should_capture() {
  local tool="$1"
  local success="$2"

  # Always capture errors
  [[ "$success" == "false" ]] && return 0

  # Sample high-frequency read operations
  case "$tool" in
    Read | Grep | Glob | LS)
      # Use a counter file for sampling
      local counter_file="$PROJECT_DIR/.claude/flow/.eval-counter-$tool"
      local counter=0

      if [[ -f "$counter_file" ]]; then
        counter=$(cat "$counter_file" 2>/dev/null || echo "0")
      fi

      counter=$((counter + 1))
      echo "$counter" >"$counter_file"

      [[ $((counter % EVAL_SAMPLE_RATE)) -eq 0 ]] && return 0
      return 1
      ;;
    *)
      return 0
      ;;
  esac
}

# --- Log Writing ---
# Write final evaluation log
write_evaluation_log() {
  local eval_file="$1"
  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

  # Sanitize branch name for filesystem
  local safe_branch="${branch//\//-}"

  local log_dir="$LOGS_DIR/$safe_branch"
  mkdir -p "$log_dir"

  local timestamp
  timestamp=$(date -u +%Y-%m-%dT%H-%M-%SZ)
  local log_file="$log_dir/${timestamp}-evaluation.json"

  # Calculate final metrics
  local metrics
  metrics=$(calculate_metrics "$eval_file")

  local patterns
  patterns=$(detect_multi_turn_patterns "$eval_file")

  # Build error analysis
  local error_analysis
  error_analysis=$(jq '
    [.tool_calls[] | select(.success == false)] |
    group_by(.error_type) |
    map({
      error_type: .[0].error_type,
      count: length,
      tools: [.[].tool_name] | unique,
      samples: [.[].input_preview][:3]
    }) |
    sort_by(-.count)
  ' "$eval_file" 2>/dev/null || echo '[]')

  # Build recommendations
  local recommendations='[]'
  local test_failures
  test_failures=$(echo "$patterns" | jq -r '.test_failure_retries // 0')
  if [[ "$test_failures" -gt 2 ]]; then
    recommendations=$(echo "$recommendations" | jq '. + [{
      priority: "high",
      type: "skill_load",
      message: "Multiple test failures detected - load TDD skill at session start",
      action: "Skill({ skill: \"devtools:tdd-typescript\" })"
    }]')
  fi

  local grep_cycles
  grep_cycles=$(echo "$patterns" | jq -r '.grep_read_edit_cycles // 0')
  if [[ "$grep_cycles" -gt 3 ]]; then
    recommendations=$(echo "$recommendations" | jq '. + [{
      priority: "medium",
      type: "workflow",
      message: "Multiple grep-read-edit cycles suggest exploration phase needed",
      action: "Use Explore agent or ast-grep skill"
    }]')
  fi

  # Get session metadata
  local session_id started_at compaction_count
  session_id=$(jq -r '.session_id // "unknown"' "$eval_file" 2>/dev/null)
  started_at=$(jq -r '.started_at // ""' "$eval_file" 2>/dev/null)
  compaction_count=$(jq -r '.compaction_count // 0' "$eval_file" 2>/dev/null)

  # Write final log
  jq -n \
    --arg version "1.0.0" \
    --arg session_id "$session_id" \
    --arg branch "$branch" \
    --arg started "$started_at" \
    --arg ended "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
    --argjson compaction "$compaction_count" \
    --argjson metrics "$metrics" \
    --argjson patterns "$patterns" \
    --argjson errors "$error_analysis" \
    --argjson recommendations "$recommendations" \
    '{
      version: $version,
      session_id: $session_id,
      branch: $branch,
      duration: {
        started_at: $started,
        ended_at: $ended,
        compaction_count: $compaction
      },
      metrics: $metrics,
      multi_turn_patterns: $patterns,
      error_analysis: $errors,
      recommendations: $recommendations
    }' >"$log_file"

  echo "$log_file"
}

# --- Summary Output ---
# Generate summary hint for session end
generate_summary_hint() {
  local log_file="$1"

  if [[ "$EVAL_SHOW_SUMMARY" != "true" ]]; then
    return
  fi

  local success_rate
  success_rate=$(jq -r '.metrics.success_rate // 1 | . * 100 | floor' "$log_file" 2>/dev/null || echo "100")

  local failed_calls
  failed_calls=$(jq -r '.metrics.failed_calls // 0' "$log_file" 2>/dev/null || echo "0")

  local top_recommendation
  top_recommendation=$(jq -r '.recommendations[0].message // "No specific recommendations"' "$log_file" 2>/dev/null)

  cat <<EOF

<flow-evaluation-summary>
Session: ${success_rate}% success rate, ${failed_calls} errors
Top opportunity: ${top_recommendation}
Log: ${log_file#"$PROJECT_DIR/"}
</flow-evaluation-summary>
EOF
}
