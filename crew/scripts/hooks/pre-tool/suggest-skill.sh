#!/usr/bin/env bash
# Suggest relevant skills based on command being run
# Non-blocking - provides tips without preventing the action

set +e

is_truthy() {
  case "${1:-}" in
    1 | true | yes | on) return 0 ;;
    *) return 1 ;;
  esac
}

QUIET="${CLAUDE_QUIET:-${CREW_QUIET:-}}"
TOKEN_SAVER="${CLAUDE_TOKEN_SAVER:-${CREW_TOKEN_SAVER:-}}"
TIPS_MODE="${CREW_TIPS:-}"

# Allow opt-out for tips
if is_truthy "$QUIET" || [[ "$TIPS_MODE" =~ ^(0|off|false)$ ]]; then
  exit 0
fi

INPUT=$(cat)

# Single jq call to extract both fields (performance optimization)
read -r TOOL_NAME COMMAND < <(echo "$INPUT" | jq -r '[.tool_name // "", .tool_input.command // ""] | @tsv' 2>/dev/null)

# Only check Bash tool
[[ $TOOL_NAME != "Bash" ]] && exit 0

# Extract first line of command
CMD_LINE="${COMMAND%%$'\n'*}"

# Suggestion messages based on command patterns
SUGGESTION=""

# Optional dedupe per session (default) to save tokens
MARKER=""
if is_truthy "$TOKEN_SAVER" || [[ "$TIPS_MODE" != "all" ]]; then
  PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
  BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
  [[ -z $BRANCH ]] && BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
  SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
  BRANCH_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH"
  SESSION_ID="${CLAUDE_SESSION_ID:-$$}"
  MARKER="$BRANCH_DIR/.tips-shown-${SESSION_ID}"
  [[ -f $MARKER ]] && exit 0
fi

# Git commit - suggest git skill
if [[ $CMD_LINE =~ ^git\ commit ]]; then
  SUGGESTION="Tip: use Skill(skill: \"crew:git:commit\") for guided commits."
fi

# Direct test/lint commands - suggest /crew:work:ci
if [[ $CMD_LINE =~ (npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?(test|lint|format|typecheck)([[:space:]]|$) ]] ||
  [[ $CMD_LINE =~ ^[[:space:]]*(vitest|jest|biome|eslint|prettier|tsc)[[:space:]] ]]; then
  SUGGESTION="Tip: use Skill(skill: \"crew:work:ci\") to run CI in background."
fi

# Git push - remind about CI
if [[ $CMD_LINE =~ ^git\ push ]]; then
  SUGGESTION="Tip: run Skill(skill: \"crew:work:ci\") before push."
fi

# Sed/grep patterns that look like code refactoring - suggest ast-grep
# Patterns: sed with s/ replacement, for loops with sed/grep, grep -l piped to xargs
if [[ $CMD_LINE =~ sed[[:space:]]+-i?[[:space:]]*[\'\"]?s/ ]] ||
  [[ $CMD_LINE =~ for[[:space:]]+.*in.*\$\(.*grep ]] ||
  [[ $CMD_LINE =~ grep[[:space:]]+-[lr].*\|.*sed ]] ||
  [[ $CMD_LINE =~ grep[[:space:]]+-[lr].*\|.*xargs ]] ||
  [[ $COMMAND =~ import.*from ]] && [[ $CMD_LINE =~ sed ]]; then
  SUGGESTION="Tip: use Skill(skill: \"crew:ast-grep\") for syntax-aware refactors."
fi

# Package installation - suggest Context7 for docs
if [[ $CMD_LINE =~ (npm|bun|pnpm|yarn)[[:space:]]+(install|add|i)[[:space:]] ]]; then
  SUGGESTION="Tip: use MCPSearch({ query: \"select:mcp__plugin_crew_context7__query-docs\" }) to verify library APIs."
fi

# Package.json reading - suggest checking docs
if [[ $CMD_LINE =~ cat.*package\.json ]] || [[ $CMD_LINE =~ jq.*package\.json ]]; then
  SUGGESTION="Tip: use Context7 MCP to verify library APIs are current."
fi

# Output suggestion if we have one
if [[ -n $SUGGESTION ]]; then
  # Mark as shown for this session (token saver)
  if [[ -n $MARKER ]]; then
    mkdir -p "$(dirname "$MARKER")" 2>/dev/null
    touch "$MARKER" 2>/dev/null
  fi
  # Use jq to properly escape the suggestion for JSON
  jq -n --arg msg "$SUGGESTION" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "message": $msg
    }
  }'
fi

exit 0
