#!/usr/bin/env bash
set -euo pipefail

branch=$(git branch --show-current)

echo "## Branch"
echo '```'
echo "$branch"
echo '```'
echo

echo "## Status"
echo '```'
git status --short || echo "(clean)"
echo '```'
echo

echo "## Commits ahead/behind main"
echo '```'
if git rev-parse origin/main >/dev/null 2>&1; then
  behind=$(git rev-list --count HEAD..origin/main 2>/dev/null || echo "?")
  ahead=$(git rev-list --count origin/main..HEAD 2>/dev/null || echo "?")
  echo "Behind: $behind, Ahead: $ahead"
else
  echo "(origin/main not available - run git fetch)"
fi
echo '```'
echo

# Check for uncommitted changes
if [[ -n "$(git status --porcelain)" ]]; then
  echo "## ⚠️ UNCOMMITTED CHANGES"
  echo "Will stash before sync."
  echo
fi
