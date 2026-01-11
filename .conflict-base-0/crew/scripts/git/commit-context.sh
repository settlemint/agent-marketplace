#!/usr/bin/env bash
set -euo pipefail

echo "## Branch"
echo '```'
git branch --show-current
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

echo "## Recent Commits (style reference)"
echo '```'
git log --oneline -5 2>/dev/null || echo "(no commits)"
echo '```'
echo

# Check for sensitive files
sensitive=$(git diff --cached --name-only 2>/dev/null | grep -E '\.(env|pem|key)$|credentials|secret' || true)
if [[ -n "$sensitive" ]]; then
  echo "## ⚠️ SENSITIVE FILES STAGED"
  echo '```'
  echo "$sensitive"
  echo '```'
  echo "**Unstage these before committing!**"
  echo
fi
