#!/bin/bash
# Lint and format the file that was just modified
# Runs immediately after Edit/Write so issues can be fixed in same turn
set +e

# Read hook input from stdin
INPUT=$(cat)

# Extract file path from tool input
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null)

if [[ -z $FILE_PATH ]] || [[ ! -f $FILE_PATH ]]; then
  exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

case "$EXT" in
  sol)
    # Format Solidity with forge
    forge fmt "$FILE_PATH" 2>/dev/null || true
    ;;
  sh)
    # Format shell scripts with shfmt
    if command -v shfmt &>/dev/null; then
      shfmt -w "$FILE_PATH" 2>/dev/null || true
    fi

    # Lint with shellcheck
    if command -v shellcheck &>/dev/null; then
      sc_output=$(shellcheck -f gcc "$FILE_PATH" 2>&1)
      if [[ -n $sc_output ]]; then
        # Filter out common false positives (SC1091 = not following sourced file)
        issues=$(echo "$sc_output" | grep -v "SC1091" | head -10)
        if [[ -n $issues ]]; then
          echo "ACTION REQUIRED: Fix shellcheck issues in $FILE_PATH:"
          echo "$issues"
        fi
      fi
    fi
    ;;
  ts | tsx | js | jsx)
    # TypeScript/JavaScript: full lint but skip unused-import removal
    # Reason: When adding imports first, auto-fix removes them before usage is added
    bunx prettier --write "$FILE_PATH" --ignore-unknown 2>/dev/null || true

    # Run biome directly with noUnusedImports disabled to preserve imports during edits
    bunx biome check --write --unsafe \
      --rules-disabled=lint/correctness/noUnusedImports \
      "$FILE_PATH" 2>/dev/null || true
    ;;
  json | css | scss | yaml | yml)
    # Non-code files: safe to fully lint
    bunx prettier --write "$FILE_PATH" --ignore-unknown 2>/dev/null || true
    ;;
  md)
    # Markdown files: format with prettier
    bunx prettier --write "$FILE_PATH" --ignore-unknown 2>/dev/null || true

    # Lint with markdownlint if available
    if command -v markdownlint &>/dev/null; then
      ml_output=$(markdownlint "$FILE_PATH" 2>&1)
      if [[ -n $ml_output ]]; then
        echo "ACTION REQUIRED: Fix markdownlint issues in $FILE_PATH:"
        echo "$ml_output" | head -10
      fi
    fi
    ;;
esac
