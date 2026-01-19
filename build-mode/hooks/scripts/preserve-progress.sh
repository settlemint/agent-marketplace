#!/usr/bin/env bash
# Preserve progress information before context compaction
# Outputs a system message with current state for Claude to remember
set -uo pipefail

# Read input from stdin
INPUT=$(cat)

# Extract current working directory
CWD=$(echo "$INPUT" | jq -r '.cwd // "unknown"')

# Find the most recent plan file
PLAN_DIR="$HOME/.claude/plans"
LATEST_PLAN=""
if [[ -d "$PLAN_DIR" ]]; then
  LATEST_PLAN=$(find "$PLAN_DIR" -maxdepth 1 -name "*.md" -type f -printf '%T@ %p\n' 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
  # Fallback for macOS which doesn't support -printf
  if [[ -z "$LATEST_PLAN" ]]; then
    LATEST_PLAN=$(find "$PLAN_DIR" -maxdepth 1 -name "*.md" -type f -exec stat -f '%m %N' {} \; 2>/dev/null | sort -rn | head -1 | cut -d' ' -f2-)
  fi
fi

# Get current git branch
BRANCH=$(git -C "$CWD" branch --show-current 2>/dev/null || echo "unknown")

# Get test status if available
TEST_STATUS="unknown"
if command -v bun &>/dev/null && [[ -f "$CWD/package.json" ]]; then
  # Quick test count without running full suite
  TEST_COUNT=$(find "$CWD/src" -name "*.test.ts" -o -name "*.spec.ts" 2>/dev/null | wc -l | tr -d ' ')
  TEST_STATUS="$TEST_COUNT test files found"
fi

# Build the progress summary
cat <<EOF
{
  "continue": true,
  "suppressOutput": false,
  "systemMessage": "## Progress Preservation (Pre-Compaction)

### Current Context
- Working directory: $CWD
- Branch: $BRANCH
- Plan file: ${LATEST_PLAN:-"No active plan"}

### Test Status
- $TEST_STATUS

### Reminders After Compaction
1. Read the plan file to understand current task
2. Check TodoWrite for in-progress items
3. Run \`bun run test\` to verify state
4. Continue with TDD workflow: RED -> GREEN -> REFACTOR

### Build-Mode Agents Available
- task-implementer: TDD implementation
- spec-reviewer: Requirement verification
- quality-reviewer: Code quality assessment
- silent-failure-hunter: Error handling gaps
- visual-tester: UI verification
- completion-validator: Final gate"
}
EOF
