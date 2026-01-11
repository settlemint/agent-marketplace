#!/usr/bin/env bash
set -euo pipefail

echo "## Fetching and Pruning"
echo '```'
git fetch --prune 2>&1 || echo "(fetch failed)"
echo '```'
echo

echo "## Branches with Remote Status"
echo '```'
git branch -vv
echo '```'
echo

# Find gone branches
gone_branches=$(git branch -vv | grep ': gone]' | awk '{print $1}' | tr -d '+*')

if [[ -n "$gone_branches" ]]; then
  echo "## Branches to Delete"
  echo '```'
  echo "$gone_branches"
  echo '```'
  echo

  echo "## Cleanup Commands"
  echo '```bash'
  for branch in $gone_branches; do
    worktree=$(git worktree list 2>/dev/null | grep "\\[$branch\\]" | awk '{print $1}' || true)
    if [[ -n "$worktree" ]] && [[ "$worktree" != "$(git rev-parse --show-toplevel)" ]]; then
      echo "git worktree remove --force \"$worktree\""
    fi
    echo "git branch -D \"$branch\""
  done
  echo '```'
else
  echo "## ✓ No Stale Branches"
  echo "All local branches have active remotes."
fi
