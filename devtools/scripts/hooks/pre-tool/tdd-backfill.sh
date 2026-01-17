#!/usr/bin/env bash
# TDD Backfill Hook - Reminder for test coverage on Edit/Write
# Triggered on PreToolUse for Edit and Write tools
#
# When editing .ts/.tsx files without a corresponding test file,
# reminds the user to create tests first (backfill TDD).

set +e # Hooks must never fail

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
# shellcheck disable=SC2034 # SCRIPT_NAME is used by sourced common.sh
SCRIPT_NAME="tdd-backfill"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# --- Environment flags ---
is_truthy() {
  case "${1:-}" in
    1 | true | yes | on) return 0 ;;
    *) return 1 ;;
  esac
}

QUIET="${CLAUDE_QUIET:-${DEVTOOLS_QUIET:-}}"
TOKEN_SAVER="${CLAUDE_TOKEN_SAVER:-${DEVTOOLS_TOKEN_SAVER:-}}"

# Allow opt-out
if is_truthy "$QUIET"; then
  exit 0
fi

# --- Parse input ---
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null || echo "")

# --- Validate input ---
if [[ -z "$FILE_PATH" ]]; then
  exit 0
fi

# --- Check if TypeScript file ---
if [[ ! "$FILE_PATH" =~ \.(ts|tsx)$ ]]; then
  log_debug "event=SKIP_NON_TS" "file=$FILE_PATH"
  exit 0
fi

# --- Check exclusion patterns ---
is_excluded() {
  local file="$1"

  # Test files themselves
  [[ "$file" =~ \.test\.(ts|tsx)$ ]] && return 0
  [[ "$file" =~ \.spec\.(ts|tsx)$ ]] && return 0
  [[ "$file" =~ __tests__/ ]] && return 0

  # Config files
  [[ "$file" =~ (vitest|vite|jest|next|tailwind|postcss|eslint|biome|prettier)\.config ]] && return 0
  [[ "$file" =~ tsconfig ]] && return 0

  # Type declarations
  [[ "$file" =~ \.d\.ts$ ]] && return 0
  [[ "$file" =~ /types/ ]] && return 0

  # Scripts and hooks
  [[ "$file" =~ /scripts/ ]] && return 0
  [[ "$file" =~ /hooks/ ]] && return 0

  # Generated and migrations
  [[ "$file" =~ /migrations/ ]] && return 0
  [[ "$file" =~ /generated/ ]] && return 0
  [[ "$file" =~ \.generated\. ]] && return 0

  # Storybook
  [[ "$file" =~ \.stories\. ]] && return 0

  return 1
}

if is_excluded "$FILE_PATH"; then
  log_debug "event=SKIP_EXCLUDED" "file=$FILE_PATH"
  exit 0
fi

# --- Find test file ---
# Searches for test file in multiple patterns:
# 1. Co-located: foo.ts -> foo.test.ts or foo.spec.ts
# 2. Jest-style: foo.ts -> __tests__/foo.test.ts
# 3. Separate dir: src/foo.ts -> tests/foo.test.ts
# 4. Root test dir: foo.ts -> test/foo.test.ts
find_test_file() {
  local source_file="$1"
  local basename="${source_file%.*}"
  local filename
  filename=$(basename "$basename")
  local dir
  dir=$(dirname "$source_file")
  local project_root="${CLAUDE_PROJECT_DIR:-$(pwd)}"

  # Pattern 1: Co-located - foo.ts -> foo.test.ts or foo.spec.ts
  for ext in test.ts test.tsx spec.ts spec.tsx; do
    [[ -f "${basename}.${ext}" ]] && return 0
  done

  # Pattern 2: Jest-style __tests__ directory
  for ext in test.ts test.tsx spec.ts spec.tsx; do
    [[ -f "${dir}/__tests__/${filename}.${ext}" ]] && return 0
  done

  # Pattern 3: Separate tests directory (mirroring src structure)
  # src/foo/bar.ts -> tests/foo/bar.test.ts
  local relative_path="${source_file#"${project_root}"/}"
  relative_path="${relative_path#src/}"
  local test_base="${project_root}/tests/${relative_path%.*}"
  for ext in test.ts test.tsx spec.ts spec.tsx; do
    [[ -f "${test_base}.${ext}" ]] && return 0
  done

  # Pattern 4: test/ directory at project root
  for ext in test.ts test.tsx spec.ts spec.tsx; do
    [[ -f "${project_root}/test/${filename}.${ext}" ]] && return 0
  done

  return 1
}

# --- Check if test exists ---
if find_test_file "$FILE_PATH"; then
  log_debug "event=TEST_EXISTS" "file=$FILE_PATH"
  exit 0
fi

# --- Session deduplication (per-file) ---
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
BRANCH=$(git -C "$PROJECT_DIR" branch --show-current 2>/dev/null || echo '')
[[ -z $BRANCH ]] && BRANCH=$(git -C "$PROJECT_DIR" rev-parse --short HEAD 2>/dev/null || echo 'unknown')
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
SESSION_ID="${CLAUDE_SESSION_ID:-$$}"

# Use filename hash for deduplication key
FILE_HASH=$(echo -n "$FILE_PATH" | md5 -q 2>/dev/null || echo -n "$FILE_PATH" | md5sum 2>/dev/null | cut -d' ' -f1)
MARKER_DIR="$PROJECT_DIR/.claude/branches/$SAFE_BRANCH/tdd-backfill"
MARKER="$MARKER_DIR/${SESSION_ID}-${FILE_HASH}"

if [[ -f "$MARKER" ]]; then
  log_debug "event=SKIP_ALREADY_WARNED" "file=$FILE_PATH"
  exit 0
fi

mkdir -p "$MARKER_DIR" 2>/dev/null
touch "$MARKER" 2>/dev/null

# --- Output reminder ---
log_info "event=TDD_BACKFILL_REMINDER" "file=$FILE_PATH"

FILENAME=$(basename "$FILE_PATH")
BASE="${FILENAME%.*}"

if is_truthy "$TOKEN_SAVER"; then
  # Compact message for token saver mode
  jq -n --arg file "$FILENAME" --arg base "$BASE" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "message": ("TDD: No test for " + $file + ". Create " + $base + ".test.ts first (RED phase).")
    }
  }'
else
  # Full message with guidance
  jq -n --arg file "$FILENAME" --arg base "$BASE" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "message": ("TDD Reminder: No test file found for " + $file + ".\n\nBefore implementing:\n1. Create " + $base + ".test.ts (co-located) or __tests__/" + $base + ".test.ts\n2. Write a failing test (RED phase)\n3. Run tests to verify failure\n4. Then implement (GREEN phase)\n\nLoad: Skill({ skill: \"devtools:tdd-typescript\" })")
    }
  }'
fi

exit 0
