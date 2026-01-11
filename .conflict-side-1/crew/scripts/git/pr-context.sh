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

echo "## Diff Stats"
echo '```'
git diff --stat HEAD 2>/dev/null || echo "(no changes)"
echo '```'
echo

echo "## Commits ahead of main"
echo '```'
git log origin/main..HEAD --oneline 2>/dev/null || echo "(none or main not fetched)"
echo '```'
echo

echo "## Remote Tracking"
echo '```'
git status -sb | head -1
echo '```'
echo

# Check if on main
if [[ "$branch" == "main" || "$branch" == "master" ]]; then
  echo "## ⚠️ ON MAIN BRANCH"
  echo "Will need to create a feature branch first."
  echo
fi
