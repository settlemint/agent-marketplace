#!/usr/bin/env bash
# Consolidated Bash safety gate - PreToolUse hook
# Consolidates: git-safety.sh + commit-review-gate.sh + security-gate.sh
#
# Checks in order:
# 1. Destructive git operations (warning only)
# 2. Security-sensitive patterns in staged changes (suggest skill)
# 3. Review pass documentation for commits (blocking)
#
# Philosophy: Single checkpoint, clear feedback, evidence-based enforcement

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="safety-checkpoint"
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

# ============================================================================
# SECTION 1: Git safety warnings (non-blocking)
# ============================================================================
if [[ "$COMMAND" == *"git "* ]]; then
  DESTRUCTIVE_WARNING=""

  case "$COMMAND" in
    *"git reset --hard"*)
      DESTRUCTIVE_WARNING="git reset --hard discards uncommitted changes"
      ;;
    *"git clean -fd"* | *"git clean -f"*)
      DESTRUCTIVE_WARNING="git clean removes untracked files permanently"
      ;;
    *"git push --force"* | *"git push -f"*)
      DESTRUCTIVE_WARNING="Force push overwrites remote history. Use --force-with-lease instead"
      ;;
    *"git checkout -- ."* | *"git restore ."*)
      DESTRUCTIVE_WARNING="This discards all local changes"
      ;;
    *"git stash drop"* | *"git stash clear"*)
      DESTRUCTIVE_WARNING="This permanently deletes stashed changes"
      ;;
    *"git branch -D"*)
      DESTRUCTIVE_WARNING="Force deleting branch with potentially unmerged work"
      ;;
  esac

  if [[ -n "$DESTRUCTIVE_WARNING" ]]; then
    log_warn "event=DESTRUCTIVE_GIT" "warning=$DESTRUCTIVE_WARNING"
    echo "Warning: $DESTRUCTIVE_WARNING" >&2
  fi
fi

# ============================================================================
# SECTION 2: Commit-specific checks
# ============================================================================
if [[ "$COMMAND" != *"git commit"* ]]; then
  exit 0
fi

log_info "event=COMMIT_DETECTED"

# --- Bypass check ---
if [[ "$COMMAND" == *"--skip-review"* ]]; then
  log_warn "event=REVIEW_BYPASS" "reason=skip_review_flag"
  echo "Review check bypassed with --skip-review flag" >&2
  exit 0
fi

# ============================================================================
# SECTION 2a: Security pattern detection (informational)
# ============================================================================
if ! session_marker_exists "security-skill-loaded"; then
  STAGED_DIFF=$(git diff --cached --unified=0 2>/dev/null || echo "")

  if [[ -n "$STAGED_DIFF" ]]; then
    SECURITY_PATTERNS="(auth|login|session|token|credential|password|oauth|jwt)"
    SECURITY_PATTERNS+="|"
    SECURITY_PATTERNS+="(payment|billing|charge|transaction|stripe)"
    SECURITY_PATTERNS+="|"
    SECURITY_PATTERNS+="(secret|api.?key|private.?key|encryption)"
    SECURITY_PATTERNS+="|"
    SECURITY_PATTERNS+="(sanitize|escape|validate|injection|xss|csrf)"
    SECURITY_PATTERNS+="|"
    SECURITY_PATTERNS+="(permission|access.?control|role|privilege|admin)"

    if echo "$STAGED_DIFF" | grep -qiE "$SECURITY_PATTERNS"; then
      MATCHED=$(echo "$STAGED_DIFF" | grep -oiE "$SECURITY_PATTERNS" | head -3 | tr '\n' ',' | sed 's/,$//')
      log_info "event=SECURITY_PATTERNS_DETECTED" "matched=$MATCHED"
      create_session_marker "security-skill-loaded"

      cat <<EOF

Security-sensitive code detected (patterns: $MATCHED).
Consider loading: Skill({ skill: "differential-review:differential-review" })

EOF
    fi
  fi
fi

# ============================================================================
# SECTION 2b: Review pass enforcement (blocking)
# ============================================================================
# No transcript - allow (can't verify)
if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  log_warn "event=ALLOW_NO_TRANSCRIPT"
  exit 0
fi

# Check for code changes in session
CODE_CHANGE_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and (.name == "Edit" or .name == "Write"))] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# No code changes - allow commit
if [[ "$CODE_CHANGE_COUNT" == "0" || "$CODE_CHANGE_COUNT" == "null" ]]; then
  log_info "event=ALLOW" "reason=no_code_changes_in_session"
  exit 0
fi

# Count review passes with evidence
PASS_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  [match("(?i)(pass\\s*[1-5]|## pass|\\*\\*pass)"; "g")] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

EVIDENCE_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  [match("(?i)(EVIDENCE:|✓ tests? pass|[0-9]+ tests?,? [0-9]+ (fail|passed)|FIXED|Fixed in|\\w+\\.(ts|js|tsx|jsx):[0-9]+|Codex found|security (scan|review)|No (new )?findings?|converged)"; "g")] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# Calculate score
if [[ "$EVIDENCE_COUNT" -ge "$PASS_COUNT" ]]; then
  TOTAL_SCORE=$((PASS_COUNT * 2))
else
  TOTAL_SCORE=$((EVIDENCE_COUNT * 2))
fi

log_info "event=REVIEW_CHECK" "passes=$PASS_COUNT" "evidence=$EVIDENCE_COUNT" "score=$TOTAL_SCORE" "changes=$CODE_CHANGE_COUNT"

# Minimums
MIN_SCORE=6
MIN_PASSES=3
MIN_EVIDENCE=3

if [[ "$PASS_COUNT" -lt "$MIN_PASSES" || "$EVIDENCE_COUNT" -lt "$MIN_EVIDENCE" || "$TOTAL_SCORE" -lt "$MIN_SCORE" ]]; then
  log_warn "event=COMMIT_BLOCKED" "passes=$PASS_COUNT" "evidence=$EVIDENCE_COUNT" "score=$TOTAL_SCORE"

  REASON="Commit blocked: Review passes with evidence required.

Code changes: $CODE_CHANGE_COUNT file(s)
Review passes: $PASS_COUNT (need $MIN_PASSES)
Evidence markers: $EVIDENCE_COUNT (need $MIN_EVIDENCE)
Score: $TOTAL_SCORE (need $MIN_SCORE)

Before committing, use superpowers verification:
Skill({ skill: \"superpowers:verification-before-completion\" })

Or document 3 review passes with evidence:
  ## Pass 1: Standard Review - EVIDENCE
  - ✓ Tests pass: [output]
  - File citations: src/file.ts:42

  ## Pass 2: Deep Review - EVIDENCE
  - Checked: naming, error handling
  - No new findings

  ## Pass 3: Architecture Review - EVIDENCE
  - Converged: all issues addressed

Emergency bypass: Add '--skip-review' to commit message"

  jq -n --arg reason "$REASON" '{"decision": "block", "reason": $reason}'
  exit 0
fi

log_info "event=COMMIT_ALLOWED" "passes=$PASS_COUNT" "evidence=$EVIDENCE_COUNT" "score=$TOTAL_SCORE"
exit 0
