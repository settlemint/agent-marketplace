#!/usr/bin/env bash
# PreToolUse hook: Block Edit/Write after N changes without documented review pass
# Enforces Rule of Five checkpoints during implementation
#
# Checks for:
# - Edit/Write tool calls in transcript
# - Review pass documentation ("## Pass") since last checkpoint
# - Blocks after threshold (default: 10) edits without documented pass
#
# Threshold configurable via CLAUDE_REVIEW_CHECKPOINT env var
# Override: Include "[SKIP-CHECKPOINT]" in recent message (audited)
#
# Excludes: test files, config files, markdown, generated files

set +e

SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="edit-review-checkpoint"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Default threshold (configurable)
CHECKPOINT_THRESHOLD=${CLAUDE_REVIEW_CHECKPOINT:-10}

# Read tool input from stdin
TOOL_INPUT=$(cat)
TOOL_NAME=$(echo "$TOOL_INPUT" | jq -r '.tool_name // ""' 2>/dev/null || echo "")
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null || echo "")
TRANSCRIPT_PATH=$(echo "$TOOL_INPUT" | jq -r '.transcript_path // ""' 2>/dev/null || echo "")

# Skip if not Edit or Write
if [[ "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "Write" ]]; then
  exit 0
fi

# Skip if no file path
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# --- Check if file should be excluded ---
is_excluded() {
  local file="$1"

  # Test files
  [[ "$file" =~ \.test\.(ts|tsx|js|jsx)$ ]] && return 0
  [[ "$file" =~ \.spec\.(ts|tsx|js|jsx)$ ]] && return 0
  [[ "$file" =~ __tests__/ ]] && return 0

  # Config files
  [[ "$file" =~ (vitest|vite|jest|next|tailwind|postcss|eslint|biome|prettier)\.config ]] && return 0
  [[ "$file" =~ tsconfig ]] && return 0
  [[ "$file" =~ package\.json$ ]] && return 0

  # Type declarations
  [[ "$file" =~ \.d\.ts$ ]] && return 0

  # Markdown and docs
  [[ "$file" =~ \.md$ ]] && return 0
  [[ "$file" =~ \.mdx$ ]] && return 0

  # Generated files
  [[ "$file" =~ /generated/ ]] && return 0
  [[ "$file" =~ \.generated\. ]] && return 0
  [[ "$file" =~ /migrations/ ]] && return 0

  # Scripts and hooks (this plugin)
  [[ "$file" =~ /scripts/hooks/ ]] && return 0

  # Non-code files
  [[ ! "$file" =~ \.(ts|tsx|js|jsx|py|go|rs|sol)$ ]] && return 0

  return 1
}

# Skip excluded files
if is_excluded "$FILE_PATH"; then
  log_debug "event=SKIP_EXCLUDED" "file=$FILE_PATH"
  exit 0
fi

# No transcript - allow (can't verify)
if [[ -z "$TRANSCRIPT_PATH" || ! -f "$TRANSCRIPT_PATH" ]]; then
  log_debug "event=SKIP_NO_TRANSCRIPT"
  exit 0
fi

# --- Check for bypass marker in recent messages ---
HAS_BYPASS=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  test("\\[SKIP-CHECKPOINT\\]")
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "false")

if [[ "$HAS_BYPASS" == "true" ]]; then
  log_warn "event=CHECKPOINT_BYPASS" "file=$FILE_PATH"
  # Audit bypass
  AUDIT_DIR="/tmp/claude-audit"
  mkdir -p "$AUDIT_DIR" 2>/dev/null || true
  echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] SKIP-CHECKPOINT used for $FILE_PATH" >>"$AUDIT_DIR/checkpoint-bypass.log" 2>/dev/null || true
  exit 0
fi

# --- Count Edit/Write operations on code files ---
# Count all Edit/Write tool_use entries for code files
EDIT_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "tool_use" and (.name == "Edit" or .name == "Write")) |
   .input.file_path // "" |
   select(test("\\.(ts|tsx|js|jsx|py|go|rs|sol)$")) |
   select(test("\\.(test|spec)\\.(ts|tsx|js|jsx)$") | not) |
   select(test("__tests__/") | not) |
   select(test("(vitest|vite|jest|next|tailwind|postcss|eslint|biome|prettier)\\.config") | not) |
   select(test("tsconfig") | not) |
   select(test("\\.d\\.ts$") | not) |
   select(test("/generated/") | not) |
   select(test("/migrations/") | not) |
   select(test("/scripts/hooks/") | not)] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

# Handle null or empty
if [[ "$EDIT_COUNT" == "null" || -z "$EDIT_COUNT" ]]; then
  EDIT_COUNT=0
fi

log_debug "event=EDIT_COUNT" "count=$EDIT_COUNT" "threshold=$CHECKPOINT_THRESHOLD"

# Under threshold - allow
if [[ "$EDIT_COUNT" -lt "$CHECKPOINT_THRESHOLD" ]]; then
  exit 0
fi

# --- Check for review pass documentation ---
# Look for "## Pass" patterns in assistant messages
PASS_COUNT=$(jq -s '
  [.[] | .message.content[]? |
   select(.type == "text") | .text // ""] |
  join(" ") |
  [match("(?i)(## pass|\\*\\*pass\\s*[1-5]|### pass)"; "g")] |
  length
' "$TRANSCRIPT_PATH" 2>/dev/null || echo "0")

if [[ "$PASS_COUNT" == "null" || -z "$PASS_COUNT" ]]; then
  PASS_COUNT=0
fi

log_info "event=CHECKPOINT_CHECK" "edit_count=$EDIT_COUNT" "pass_count=$PASS_COUNT" "threshold=$CHECKPOINT_THRESHOLD"

# Has documented passes - allow
if [[ "$PASS_COUNT" -gt 0 ]]; then
  log_info "event=CHECKPOINT_PASSED" "passes=$PASS_COUNT"
  exit 0
fi

# --- Block: too many edits without review pass ---
log_warn "event=CHECKPOINT_BLOCK" "edit_count=$EDIT_COUNT" "threshold=$CHECKPOINT_THRESHOLD"

REASON="Edit checkpoint: Too many code changes without review pass.

Code edits: $EDIT_COUNT (threshold: $CHECKPOINT_THRESHOLD)
Review passes: 0

Rule of Five requires periodic review during implementation.

Before continuing, document a review pass:

## Pass N: Review - EVIDENCE
- What I checked: [specific areas reviewed]
- Findings: [issues found or 'No issues']
- Evidence: [test output, code citations]

Example:
## Pass 1: Standard Review - EVIDENCE
- Checked: Type safety, error handling
- Findings: Missing null check at src/auth.ts:42 - FIXED
- Evidence: \`bun run typecheck\` passes

Override: Include [SKIP-CHECKPOINT] in your message (audited)"

jq -n --arg reason "$REASON" '{"decision": "block", "reason": $reason}'
exit 0
