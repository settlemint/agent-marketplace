#!/usr/bin/env bash
# PostToolUse hook: Check for excessive/unnecessary comments in code changes
# Analyzes comment ratio and flags suspicious patterns
#
# Based on patterns from jarrodwatts/claude-code-config (ported to Bash)

set -euo pipefail

# Configuration
readonly MAX_COMMENT_RATIO=25 # Max 25% of lines as comments

# Valid comment patterns (regex) - these are acceptable
readonly VALID_PATTERNS=(
  '^[[:space:]]*(#|//)[[:space:]]*(given|when|then|and|but)\b' # BDD comments
  '^[[:space:]]*/\*\*'                                         # JSDoc start
  '^[[:space:]]*\*[[:space:]]*@'                               # JSDoc tags
  '^[[:space:]]*#!'                                            # Shebang
  '^[[:space:]]*//@ts-'                                        # TypeScript directives
  '^[[:space:]]*//[[:space:]]*eslint-'                         # ESLint directives
  '^[[:space:]]*#[[:space:]]*type:'                            # Python type hints
  '^[[:space:]]*#[[:space:]]*noqa'                             # Python noqa
  '^[[:space:]]*#[[:space:]]*pragma'                           # Pragma directives
  '^[[:space:]]*(#|//)[[:space:]]*TODO:'                       # TODO markers
  '^[[:space:]]*(#|//)[[:space:]]*FIXME:'                      # FIXME markers
  '^[[:space:]]*///'                                           # Rust doc comments
  '^[[:space:]]*@dev'                                          # Solidity dev docs
  '^[[:space:]]*@param'                                        # Doc params
  '^[[:space:]]*@return'                                       # Doc returns
  '^[[:space:]]*@notice'                                       # Solidity notice
)

# Code extensions to check
readonly CODE_EXTENSIONS="ts tsx js jsx py go rs java cpp c sol"

# Read hook input
HOOK_INPUT=$(cat)

# Extract tool info
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // ""')
FILE_PATH=$(echo "$HOOK_INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // .tool_input.path // ""')

# Only check Write/Edit operations
if [[ "$TOOL_NAME" != "Write" && "$TOOL_NAME" != "Edit" && "$TOOL_NAME" != "MultiEdit" ]]; then
  exit 0
fi

# Need a file path
[[ -z "$FILE_PATH" ]] && exit 0

# Get file extension
EXT="${FILE_PATH##*.}"

# Check if it's a code file
is_code_file() {
  for ext in $CODE_EXTENSIONS; do
    [[ "$ext" == "$1" ]] && return 0
  done
  return 1
}

is_code_file "$EXT" || exit 0

# Read file content (for Write, use tool_input.content; for Edit, read the file)
if [[ "$TOOL_NAME" == "Write" ]]; then
  CONTENT=$(echo "$HOOK_INPUT" | jq -r '.tool_input.content // ""')
else
  [[ -f "$FILE_PATH" ]] || exit 0
  CONTENT=$(cat "$FILE_PATH")
fi

[[ -z "$CONTENT" ]] && exit 0

# Count lines
total_lines=$(echo "$CONTENT" | grep -cv '^[[:space:]]*$' || true)
[[ "$total_lines" -eq 0 ]] && exit 0

# Count comment lines based on language
count_comment_lines() {
  local ext="$1"
  local content="$2"
  local count=0

  case "$ext" in
    py)
      count=$(echo "$content" | grep -c '^[[:space:]]*#' || true)
      ;;
    ts | tsx | js | jsx | java | go | rs | cpp | c | sol)
      # Count // and /* style comments
      count=$(echo "$content" | grep -c '^[[:space:]]*//' || true)
      count=$((count + $(echo "$content" | grep -c '^[[:space:]]*/\*' || true)))
      count=$((count + $(echo "$content" | grep -c '^[[:space:]]*\*' || true)))
      ;;
  esac

  echo "$count"
}

comment_lines=$(count_comment_lines "$EXT" "$CONTENT")

# Calculate ratio
if [[ "$total_lines" -gt 0 ]]; then
  ratio=$((comment_lines * 100 / total_lines))
else
  ratio=0
fi

# Check if ratio exceeds threshold
if [[ "$ratio" -gt "$MAX_COMMENT_RATIO" ]]; then
  # Count flagged comments (non-valid patterns)
  flagged_count=0
  flagged_examples=""

  while IFS= read -r line; do
    is_valid=false
    for pattern in "${VALID_PATTERNS[@]}"; do
      if echo "$line" | grep -qE "$pattern"; then
        is_valid=true
        break
      fi
    done

    if ! $is_valid && echo "$line" | grep -qE '^[[:space:]]*(#|//)'; then
      flagged_count=$((flagged_count + 1))
      if [[ "$flagged_count" -le 3 ]]; then
        # Truncate long lines
        short_line=$(echo "$line" | head -c 60)
        [[ ${#line} -gt 60 ]] && short_line="${short_line}..."
        flagged_examples="${flagged_examples}  - ${short_line}\n"
      fi
    fi
  done <<<"$CONTENT"

  # Only warn if there are flagged comments
  if [[ "$flagged_count" -gt 0 ]]; then
    warning=$(
      cat <<EOF

Comment check: ${ratio}% of lines are comments (${comment_lines}/${total_lines})
Flagged (sample):
$(echo -e "$flagged_examples")$([[ "$flagged_count" -gt 3 ]] && echo "  ... and $((flagged_count - 3)) more")
Tip: prefer self-documenting code; keep only "why" comments.
EOF
    )

    # Output as additional context
    jq -n --arg ctx "$warning" '{
      "hookSpecificOutput": {
        "additionalContext": $ctx
      }
    }'
  fi
fi

exit 0
