#!/usr/bin/env bash
set -euo pipefail

echo "## Branch"
echo '```'
branch=$(git branch --show-current)
echo "$branch"
echo '```'
echo

# Check if on feature branch
if echo "$branch" | grep -qE '^(feat|fix|refactor|chore|docs)/'; then
  echo "✓ On feature branch"
else
  echo "⚠️ Not on feature branch - consider creating one first"
fi
echo

echo "## Git Status"
echo '```'
git status --short || echo "(clean)"
echo '```'
echo

echo "## Handoffs Directory"
echo '```'
branch_slug=$(echo "$branch" | tr '/' '-')
handoffs_dir=".claude/branches/$branch_slug/handoffs"
if [[ -d "$handoffs_dir" ]]; then
  ls "$handoffs_dir"/*.md 2>/dev/null || echo "(no handoffs yet)"
else
  echo "(directory not created yet)"
fi
echo '```'
