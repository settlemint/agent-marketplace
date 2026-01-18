#!/usr/bin/env bash
# PreToolUse hook: Block ExitPlanMode without Rule of Five + Codex + TDD
# Enforces: Mandatory Codex for ALL plans, Rule of Five passes, TDD requirements
#
# Checks for:
# - ExitPlanMode tool calls
# - Codex MCP invocation in transcript (tool_use, not text)
# - Rule of Five passes (documented passes OR Review subagent spawned)
# - TDD requirements in plan file (test mentions for implementation steps)
#
# Blocks if requirements not met, with guidance on how to comply.
#
# Bypass: Include '[PLAN-BYPASS]' in plan file (audited)

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="plan-quality-gate"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read tool input from stdin
TOOL_INPUT=$(cat)
TOOL_NAME=$(echo "$TOOL_INPUT" | jq -r '.tool_name // ""' 2>/dev/null || echo "")
TRANSCRIPT_PATH=$(echo "$TOOL_INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")

# Skip if not ExitPlanMode
if [[ "$TOOL_NAME" != "ExitPlanMode" ]]; then
  exit 0
fi

log_info "event=EXIT_PLAN_MODE_DETECTED"

# No transcript - allow (can't verify)
if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  log_warn "event=ALLOW_NO_TRANSCRIPT"
  exit 0
fi

# --- Find plan file from recent Write operations ---
PLAN_FILE=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and .name == "Write") |
   .input.file_path // ""] |
  map(select(contains("plans/"))) | last // ""
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "")

# Remove quotes if present
PLAN_FILE=$(echo "$PLAN_FILE" | tr -d '"')

# --- Check for bypass marker ---
if [[ -n "$PLAN_FILE" ]] && [[ -f "$PLAN_FILE" ]]; then
  if grep -q '\[PLAN-BYPASS\]' "$PLAN_FILE" 2>/dev/null; then
    log_warn "event=PLAN_BYPASS" "plan_file=$PLAN_FILE"
    # Log bypass for audit
    AUDIT_DIR="$PROJECT_DIR/.claude/audit"
    mkdir -p "$AUDIT_DIR" 2>/dev/null || true
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] PLAN_BYPASS used in $PLAN_FILE" >>"$AUDIT_DIR/plan-bypass.log" 2>/dev/null || true
    exit 0
  fi
fi

# --- Collect failures ---
FAILURES=""

# --- 1. Check for Codex tool_use (structured, not text) ---
CODEX_USED=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and .name == "mcp__plugin_devtools_codex__codex")] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

if [[ "$CODEX_USED" == "null" ]] || [[ "$CODEX_USED" -lt 1 ]]; then
  FAILURES="${FAILURES}- Codex architecture review: NOT FOUND (required for ALL plans)\n"
  log_info "event=CODEX_CHECK" "result=missing" "count=$CODEX_USED"
else
  log_info "event=CODEX_CHECK" "result=found" "count=$CODEX_USED"
fi

# --- 2. Check Rule of Five passes ---
# Look for Review subagent spawn OR documented passes in main thread

# Check for Review subagent spawn (Task with rule-of-five/review/convergence in prompt)
REVIEW_AGENT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and .name == "Task") |
   .input.prompt // ""] |
  map(select(test("(?i)rule.?of.?five|review pass|convergence|tactical|quality|architecture"))) | length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# Check for documented passes in assistant messages
PASS_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  [match("(?i)(pass\\s*[1-5]|## pass|\\*\\*pass|### pass)"; "g")] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

if [[ "$REVIEW_AGENT" == "null" ]]; then REVIEW_AGENT=0; fi
if [[ "$PASS_COUNT" == "null" ]]; then PASS_COUNT=0; fi

if [[ "$REVIEW_AGENT" -lt 1 ]] && [[ "$PASS_COUNT" -lt 3 ]]; then
  FAILURES="${FAILURES}- Rule of Five: $PASS_COUNT passes found (minimum 3, or delegate to Review subagent)\n"
  log_info "event=RULE_OF_FIVE_CHECK" "result=insufficient" "pass_count=$PASS_COUNT" "review_agent=$REVIEW_AGENT"
else
  log_info "event=RULE_OF_FIVE_CHECK" "result=sufficient" "pass_count=$PASS_COUNT" "review_agent=$REVIEW_AGENT"
fi

# --- 3. Check TDD in plan (if plan file found) ---
if [[ -n "$PLAN_FILE" ]] && [[ -f "$PLAN_FILE" ]]; then
  # Count implementation steps (marked with [serial] or [parallel])
  # Note: grep -c returns 0 and exits 1 when no matches, so handle carefully
  IMPL_STEPS=$(grep -cE '\[serial\]|\[parallel\]' "$PLAN_FILE" 2>/dev/null)
  IMPL_STEPS=${IMPL_STEPS:-0}

  # Count TDD/test mentions
  TDD_MENTIONS=$(grep -ciE '(test|TDD|coverage|vitest|spec)' "$PLAN_FILE" 2>/dev/null)
  TDD_MENTIONS=${TDD_MENTIONS:-0}

  if [[ "$IMPL_STEPS" -gt 0 ]] && [[ "$TDD_MENTIONS" -lt 1 ]]; then
    FAILURES="${FAILURES}- TDD requirements: Plan has $IMPL_STEPS steps but no test mentions\n"
    log_info "event=TDD_CHECK" "result=missing" "impl_steps=$IMPL_STEPS" "tdd_mentions=$TDD_MENTIONS"
  else
    log_info "event=TDD_CHECK" "result=ok" "impl_steps=$IMPL_STEPS" "tdd_mentions=$TDD_MENTIONS"
  fi
else
  log_info "event=TDD_CHECK" "result=no_plan_file" "plan_file=$PLAN_FILE"
fi

# --- Block if any failures ---
if [[ -n "$FAILURES" ]]; then
  log_warn "event=EXIT_BLOCKED" "failures=$(echo -e "$FAILURES" | tr '\n' ' ')"

  REASON="Plan quality gate: Cannot exit plan mode.

Requirements not met:
$(echo -e "$FAILURES")
To comply:

1. **Codex Review** (required for ALL plans):
   MCPSearch({ query: \"select:mcp__plugin_devtools_codex__codex\" })
   mcp__plugin_devtools_codex__codex({
     prompt: \"Review this plan for: architecture trade-offs, security implications, complexity\"
   })

2. **Rule of Five** (3+ passes OR delegate):
   Option A: Document passes in your response:
     ## Pass 1: Generation - EVIDENCE
     ## Pass 2: Tactical Review - EVIDENCE
     ## Pass 3: Quality Review - EVIDENCE

   Option B: Spawn Review subagent:
     Task({ subagent_type: \"Plan\", prompt: \"Apply Rule of Five to this plan...\" })

3. **TDD** (for implementation steps):
   Each step should mention test requirements:
     - TDD: Write failing test in X.test.ts FIRST
     - Evidence: Test fails -> passes -> coverage >=80%

Emergency bypass: Add '[PLAN-BYPASS]' to plan file (will be audited)"

  jq -n --arg reason "$REASON" '{"decision": "block", "reason": $reason}'
  exit 0
fi

log_info "event=EXIT_ALLOWED" "codex=$CODEX_USED" "passes=$PASS_COUNT" "review_agent=$REVIEW_AGENT"
exit 0
