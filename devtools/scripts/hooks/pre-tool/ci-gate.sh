#!/usr/bin/env bash
# CI gate for git push/commit operations
# Warns (non-blocking) when CI is stale and code changes are being pushed

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="ci-gate"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

is_truthy() {
  case "${1:-}" in
    1 | true | yes | on) return 0 ;;
    *) return 1 ;;
  esac
}

QUIET="${CLAUDE_QUIET:-${DEVTOOLS_QUIET:-}}"

# Allow opt-out
if is_truthy "$QUIET"; then
  exit 0
fi

# Read tool input
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // ""' 2>/dev/null || echo "")

# Only check git push and git commit commands
if [[ "$COMMAND" != *"git push"* ]] && [[ "$COMMAND" != *"git commit"* ]]; then
  exit 0
fi

# --- Paths ---
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
QA_FILE="$PROJECT_DIR/.claude/state/qa-timestamp"

# --- Session deduplication (warn only once per session) ---
SESSION_ID="${CLAUDE_SESSION_ID:-$$}"
MARKER_DIR="$PROJECT_DIR/.claude/devtools/hooks"
MARKER="$MARKER_DIR/.ci-gate-warned-${SESSION_ID}"

if [[ -f "$MARKER" ]]; then
  exit 0
fi

# --- Check if changes include code files ---
CODE_PATTERNS='\.(ts|tsx|js|jsx|py|go|rs|java|c|cpp|h|hpp|rb|php|swift|kt)$'
DOCS_ONLY=true

# For commits, check staged files
if [[ "$COMMAND" == *"git commit"* ]]; then
  if git -C "$PROJECT_DIR" diff --cached --name-only 2>/dev/null | grep -qE "$CODE_PATTERNS"; then
    DOCS_ONLY=false
  fi
fi

# For pushes, check commits ahead of remote
if [[ "$COMMAND" == *"git push"* ]]; then
  BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo "HEAD")
  if git -C "$PROJECT_DIR" log "origin/${BRANCH}..HEAD" --name-only --oneline 2>/dev/null | grep -qE "$CODE_PATTERNS"; then
    DOCS_ONLY=false
  fi
fi

# Skip warning for docs-only changes
if [[ "$DOCS_ONLY" == "true" ]]; then
  log_info "event=CI_GATE_SKIP" "reason=docs_only"
  exit 0
fi

# --- Check CI freshness ---
if [[ ! -f "$QA_FILE" ]]; then
  log_warn "event=CI_GATE_WARN" "reason=no_qa_file"
  mkdir -p "$MARKER_DIR" 2>/dev/null
  touch "$MARKER" 2>/dev/null
  jq -n '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "message": "CI status: Unknown - no .claude/state/qa-timestamp found. Run `bun run ci` to verify code health before pushing."
    }
  }'
  exit 0
fi

LAST_QA=$(cat "$QA_FILE")
NOW=$(date +%s)
AGE=$((NOW - LAST_QA))

if [[ $AGE -gt 300 ]]; then
  log_warn "event=CI_GATE_WARN" "reason=stale" "age=${AGE}s"
  mkdir -p "$MARKER_DIR" 2>/dev/null
  touch "$MARKER" 2>/dev/null
  jq -n --arg age "${AGE}s" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "message": ("CI status: Stale (" + $age + " ago). Run `bun run ci` before pushing code changes. Skip for docs/config only.")
    }
  }'
fi

exit 0
