#!/usr/bin/env bash
# PreToolUse hook: Block git commit without documented review passes WITH EVIDENCE
# Implements "proof over vibes" enforcement: block at commit gates
#
# Checks for:
# - git commit commands
# - Review pass documentation in transcript (Pass 1, Pass 2, Pass 3)
# - Evidence markers (test output, citations, FIXED, tool output)
# - Blocks if score < 6 (3 passes with evidence)
#
# Scoring:
# - Pass with evidence: 2 points (pass without evidence: 0 points)
# - Minimum: 3 passes, 3 evidence markers, 6 points total
# - Evidence required: passes without evidence don't count
#
# Based on: https://addyosmani.com/blog/code-review-ai/
# "The bottleneck moved from writing code to proving it works."
#
# Bypass: Include "--skip-review" in commit message for emergencies

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="commit-review-gate"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read tool input from stdin
TOOL_INPUT=$(cat)
COMMAND=$(echo "$TOOL_INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")
TRANSCRIPT_PATH=$(echo "$TOOL_INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")

# Skip if no command
if [[ -z "$COMMAND" ]]; then
  exit 0
fi

# Skip if not a git commit command
if [[ "$COMMAND" != *"git commit"* ]]; then
  exit 0
fi

log_info "event=COMMIT_DETECTED"

# Check for bypass flag in commit message
if [[ "$COMMAND" == *"--skip-review"* ]]; then
  log_warn "event=REVIEW_BYPASS" "reason=skip_review_flag"
  echo "Review check bypassed with --skip-review flag" >&2
  exit 0
fi

# No transcript - allow (can't verify)
if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  log_warn "event=ALLOW_NO_TRANSCRIPT"
  exit 0
fi

# --- Check for code changes (Edit/Write tool usage) ---
CODE_CHANGE_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and (.name == "Edit" or .name == "Write"))] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# No code changes in session - allow commit (might be committing external changes)
if [[ "$CODE_CHANGE_COUNT" == "0" || "$CODE_CHANGE_COUNT" == "null" ]]; then
  log_info "event=ALLOW" "reason=no_code_changes_in_session"
  exit 0
fi

# --- Check for review pass documentation ---
PASS_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  [match("(?i)(pass\\s*[1-5]|## pass|\\*\\*pass)"; "g")] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# --- Check for evidence markers (proof over vibes) ---
# Evidence includes: test output, code citations, FIXED markers, tool output
# Match both singular and plural forms (test/tests, failure/failures, finding/findings)
EVIDENCE_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  [match("(?i)(EVIDENCE:|✓ tests? pass|[0-9]+ tests?,? [0-9]+ (fail(ure)?s?|passed)|FIXED|Fixed in|\\w+\\.(ts|js|tsx|jsx|py|go|rs):[0-9]+|Codex found|security (scan|review)|No (new )?findings?|converged)"; "g")] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# --- Calculate score: passes with evidence required ---
# Each pass contributes 2 points ONLY if there's corresponding evidence
# This ensures passes without evidence don't count toward the minimum
MIN_EVIDENCE_PER_PASS=1
if [[ "$EVIDENCE_COUNT" -ge "$PASS_COUNT" ]]; then
  # Enough evidence: each pass gets full 2 points
  TOTAL_SCORE=$((PASS_COUNT * 2))
else
  # Not enough evidence: passes without evidence get 0 points
  # Only count passes that have evidence (1 evidence = 1 pass counted)
  TOTAL_SCORE=$((EVIDENCE_COUNT * 2))
fi

log_info "event=REVIEW_CHECK" "pass_count=$PASS_COUNT" "evidence_count=$EVIDENCE_COUNT" "total_score=$TOTAL_SCORE" "code_changes=$CODE_CHANGE_COUNT"

# --- Block if insufficient score ---
# Minimum 6 points = 3 passes, each with at least 1 evidence marker
# Without evidence, passes don't count toward the score
MIN_SCORE=6
MIN_PASSES=3
MIN_EVIDENCE=3

if [[ "$PASS_COUNT" -lt "$MIN_PASSES" || "$EVIDENCE_COUNT" -lt "$MIN_EVIDENCE" || "$TOTAL_SCORE" -lt "$MIN_SCORE" ]]; then
  log_warn "event=COMMIT_BLOCKED" "pass_count=$PASS_COUNT" "evidence_count=$EVIDENCE_COUNT" "total_score=$TOTAL_SCORE" "required_score=$MIN_SCORE"

  REASON="Commit blocked: Rule of Five requires documented review passes WITH EVIDENCE.

Code changes detected: $CODE_CHANGE_COUNT file(s)
Review passes found: $PASS_COUNT (minimum $MIN_PASSES required)
Evidence markers found: $EVIDENCE_COUNT (minimum $MIN_EVIDENCE required)
Total score: $TOTAL_SCORE (minimum $MIN_SCORE required)

Note: Passes without evidence markers don't count toward the score.

Before committing, document your review with evidence:
  1. Pass 1: Standard review - bugs, edge cases, test coverage
  2. Pass 2: Deep review - naming, duplication, error handling
  3. Pass 3: Architecture review - patterns, dependencies, YAGNI

Example output format WITH EVIDENCE:
  ## Pass 1: Standard Review - EVIDENCE
  - ✓ Tests pass: 24 tests, 0 failures
  - Finding: Missing null check at auth.ts:67 - FIXED
  - Citation: src/auth.ts:67

  ## Pass 2: Deep Review - EVIDENCE
  - ✓ Error path traced: validateInput() → throws → caught at caller
  - No new findings

  ## Pass 3: Architecture Review - EVIDENCE
  - Converged: All issues addressed
  - Final test run: 24 tests, 0 failures

Evidence markers include:
  - Test output (\"24 tests, 0 failures\")
  - Code citations (file.ts:42)
  - FIXED markers
  - Tool output (\"Codex found...\")
  - Convergence statements

Emergency bypass: Add '--skip-review' to commit message (use sparingly)"

  jq -n --arg reason "$REASON" '{"decision": "block", "reason": $reason}'
  exit 0
fi

log_info "event=COMMIT_ALLOWED" "pass_count=$PASS_COUNT" "evidence_count=$EVIDENCE_COUNT" "total_score=$TOTAL_SCORE"
exit 0
