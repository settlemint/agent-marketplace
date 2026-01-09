#!/usr/bin/env bash
# Check git stack/worktree status on session start
# Alerts user if branch is out of sync with parent or if worktree context matters
#
# PERFORMANCE: Runs git commands in parallel where possible

# Hooks must never fail
set +e

# Read stdin to check agent_type (since v2.1.2)
INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // ""' 2>/dev/null)

# Skip for subagents - they don't need stack status info
if [[ -n "$AGENT_TYPE" && "$AGENT_TYPE" != "null" ]]; then
  exit 0
fi

# Check if in a git repo
if ! git rev-parse --git-dir &>/dev/null 2>&1; then
  exit 0
fi

# Get branch info
BRANCH=$(git branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
  exit 0
fi

# Detect worktree status
GIT_DIR=$(git rev-parse --git-dir 2>/dev/null)
GIT_COMMON_DIR=$(git rev-parse --git-common-dir 2>/dev/null)
IS_WORKTREE="false"
if [[ "$GIT_DIR" != "$GIT_COMMON_DIR" ]]; then
  IS_WORKTREE="true"
fi

# Check if git-machete is available and branch is managed
if ! command -v git-machete &>/dev/null; then
  # No machete - just show worktree status if applicable
  if [[ $IS_WORKTREE == "true" ]]; then
    echo ""
    echo "📂 **WORKTREE CONTEXT** (branch: $BRANCH)"
    echo "  ⚠️ **IMPORTANT:** Do NOT use branch-switching commands (checkout, switch)"
    echo ""
  fi
  exit 0
fi

# Check machete file location (worktree-aware)
MACHETE_FILE="${GIT_COMMON_DIR}/machete"
if [[ ! -f "$MACHETE_FILE" ]]; then
  exit 0
fi

# Check if current branch is in machete layout
if ! git machete is-managed "$BRANCH" 2>/dev/null; then
  exit 0
fi

# Get parent branch
PARENT=$(git machete show up 2>/dev/null || echo '')

# Fetch in background to check remote status (don't wait)
git fetch origin --quiet 2>/dev/null &
FETCH_PID=$!

# Check sync status with parent
SYNC_STATUS=""
if [[ -n $PARENT ]]; then
  # Count commits behind parent
  BEHIND_PARENT=$(git rev-list --count "$BRANCH".."$PARENT" 2>/dev/null || echo "0")
  if [[ $BEHIND_PARENT -gt 0 ]]; then
    SYNC_STATUS="⚠️  Branch is $BEHIND_PARENT commits behind parent ($PARENT)"
  fi
fi

# Wait for fetch (with timeout)
if kill -0 $FETCH_PID 2>/dev/null; then
  # Still running, wait up to 2 seconds
  for _ in {1..20}; do
    if ! kill -0 $FETCH_PID 2>/dev/null; then
      break
    fi
    sleep 0.1
  done
  # Kill if still running
  kill $FETCH_PID 2>/dev/null || true
fi

# Check if remote is ahead
BEHIND_REMOTE=$(git rev-list --count "$BRANCH"..origin/"$BRANCH" 2>/dev/null || echo "0")
AHEAD_REMOTE=$(git rev-list --count origin/"$BRANCH".."$BRANCH" 2>/dev/null || echo "0")

# Build output
HAS_ISSUES="false"
OUTPUT=""

if [[ $IS_WORKTREE == "true" ]]; then
  OUTPUT="${OUTPUT}📂 **WORKTREE CONTEXT**\n"
  OUTPUT="${OUTPUT}  Branch: $BRANCH\n"
  if [[ -n $PARENT ]]; then
    OUTPUT="${OUTPUT}  Parent: $PARENT (stacked branch)\n"
  fi
  OUTPUT="${OUTPUT}  ⚠️ **IMPORTANT:** Do NOT use branch-switching commands (checkout, switch)\n"
  OUTPUT="${OUTPUT}  Use Skill(skill: \"crew:git:sync\") instead of traverse\n"
  HAS_ISSUES="true"
fi

if [[ -n $SYNC_STATUS ]]; then
  OUTPUT="${OUTPUT}${SYNC_STATUS}\n"
  OUTPUT="${OUTPUT}  **ACTION REQUIRED:** Use Skill(skill: \"crew:git:sync\") to rebase on parent\n"
  HAS_ISSUES="true"
fi

if [[ $BEHIND_REMOTE -gt 0 ]]; then
  OUTPUT="${OUTPUT}⚠️  Branch is $BEHIND_REMOTE commits behind origin/$BRANCH\n"
  OUTPUT="${OUTPUT}  **ACTION REQUIRED:** Use Skill(skill: \"crew:git:sync\") to pull remote changes\n"
  HAS_ISSUES="true"
fi

if [[ $AHEAD_REMOTE -gt 0 ]]; then
  OUTPUT="${OUTPUT}📤 Branch is $AHEAD_REMOTE commits ahead of origin/$BRANCH (unpushed)\n"
  OUTPUT="${OUTPUT}  **REMINDER:** Use Skill(skill: \"crew:git:push\") when ready to push\n"
  HAS_ISSUES="true"
fi

# Only output if there are issues or we're in a worktree
if [[ $HAS_ISSUES == "true" ]]; then
  echo ""
  echo -e "$OUTPUT"
fi

exit 0
