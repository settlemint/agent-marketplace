#!/usr/bin/env bash
set -euo pipefail

echo "## Pending Todos"
echo '```'
if [[ -d ".claude/todos" ]]; then
  pending=$(ls .claude/todos/*-pending-*.md 2>/dev/null || true)
  if [[ -n "$pending" ]]; then
    echo "$pending" | while read -r file; do
      basename "$file"
    done
  else
    echo "(none)"
  fi
else
  echo "(no todos directory)"
fi
echo '```'
echo

echo "## PR Review Comments"
echo '```'
gh pr view --json reviewDecision,reviews --jq '.reviews[] | select(.state == "CHANGES_REQUESTED") | .body' 2>/dev/null | head -20 || echo "(no PR or no comments)"
echo '```'
echo

echo "## Recent CI Status"
echo '```'
gh run list --limit 3 2>/dev/null || echo "(no runs)"
echo '```'
