#!/usr/bin/env bash
# Capture user correction patterns for learning extraction
# Runs on: UserPromptSubmit
# Silent auto-logging - captures direction changes without interrupting flow

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="capture-correction"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read prompt from stdin
PROMPT_DATA=$(cat)
PROMPT=$(echo "$PROMPT_DATA" | jq -r '.prompt // ""' 2>/dev/null || echo "")

# Skip empty prompts
if [[ -z "$PROMPT" ]]; then
  exit 0
fi

# Convert to lowercase for pattern matching (POSIX-compatible)
PROMPT_LOWER=$(echo "$PROMPT" | tr '[:upper:]' '[:lower:]')

# Correction patterns - signals user is redirecting Claude
# These indicate a change in direction that should be captured as a learning
CORRECTION_PATTERNS=(
  # Direct negations
  "^no[,.]"
  "^no "
  "^nope"
  "^wrong"
  "^that's not"
  "^that is not"
  "^not what i"
  "^not like that"
  # Redirection signals
  "actually[,]"
  "instead[,]"
  "different approach"
  "different way"
  "try something else"
  "let's try"
  "let me clarify"
  "what i meant"
  "i meant"
  "i want you to"
  # Cancellation signals
  "stop doing"
  "don't do that"
  "don't continue"
  "scratch that"
  "forget that"
  "never mind"
  "nevermind"
  "cancel that"
  # Explicit corrections
  "you should have"
  "you were supposed"
  "that was wrong"
  "not correct"
  "incorrect"
)

# Check for correction patterns
DETECTED_PATTERN=""
for pattern in "${CORRECTION_PATTERNS[@]}"; do
  if [[ "$PROMPT_LOWER" =~ $pattern ]]; then
    DETECTED_PATTERN="$pattern"
    break
  fi
done

# If no correction detected, exit silently
if [[ -z "$DETECTED_PATTERN" ]]; then
  exit 0
fi

# Log the correction
log_correction "$DETECTED_PATTERN" "$PROMPT"

exit 0
