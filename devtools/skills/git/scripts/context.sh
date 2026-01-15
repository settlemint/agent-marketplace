#!/usr/bin/env bash
# Unified git context script
# Usage: context.sh [mode]
# Modes: default, pr, commit, branch
set -euo pipefail

MODE="${1:-default}"

echo "## Branch"
git branch --show-current 2>/dev/null || echo "(detached HEAD)"
echo

echo "## Status"
git status --short 2>/dev/null || echo "(clean)"
echo

# QA freshness check
QA_FILE=".claude/state/qa-timestamp"
if [[ -f "$QA_FILE" ]]; then
  LAST_QA=$(cat "$QA_FILE")
  NOW=$(date +%s)
  AGE=$((NOW - LAST_QA))
  echo "## QA Status"
  if [[ $AGE -lt 300 ]]; then
    echo "Fresh (${AGE}s ago) - skip CI"
  else
    echo "Stale (${AGE}s ago) - run bun run ci"
  fi
  echo
fi

case "$MODE" in
  pr)
    echo "## Commits ahead of main"
    git log origin/main..HEAD --oneline 2>/dev/null || echo "(none or no origin/main)"
    echo
    echo "## Diff stats"
    git diff --stat origin/main 2>/dev/null || echo "(no diff)"
    ;;
  commit)
    echo "## Staged changes"
    git diff --cached --stat 2>/dev/null || echo "(none staged)"
    echo
    echo "## Recent commits (style reference)"
    git log --oneline -5 2>/dev/null || echo "(no commits)"
    ;;
  branch)
    echo "## Existing branches"
    git branch --list 2>/dev/null | head -10
    ;;
esac

# Sensitive file warning
SENSITIVE=$(git diff --cached --name-only 2>/dev/null | grep -E '\.(env|pem|key)$|credentials|secret' || true)
if [[ -n "$SENSITIVE" ]]; then
  echo
  echo "## WARNING: Sensitive files staged"
  echo "$SENSITIVE"
  echo "Unstage before committing!"
fi
