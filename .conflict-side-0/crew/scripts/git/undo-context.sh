#!/usr/bin/env bash
set -euo pipefail

branch=$(git branch --show-current)

echo "## Branch"
echo '```'
echo "$branch"
echo '```'
echo

echo "## Last Commit"
echo '```'
git log -1 --format="%h %s" 2>/dev/null || echo "(no commits)"
echo '```'
echo

echo "## Commit Details"
echo '```'
git log -1 --format="Author: %an <%ae>%nDate: %ar%n%n%b" 2>/dev/null || echo "(no commits)"
echo '```'
echo

# Safety check - is commit pushed?
if git rev-parse "origin/$branch" >/dev/null 2>&1; then
  local_head=$(git rev-parse HEAD)
  remote_head=$(git rev-parse "origin/$branch" 2>/dev/null || echo "")

  if [[ "$local_head" == "$remote_head" ]]; then
    echo "## 🛑 COMMIT ALREADY PUSHED"
    echo "This commit exists on remote. Undoing requires force-push."
    echo "**Aborting to prevent breaking collaborators.**"
    echo
  else
    unpushed=$(git log "origin/$branch"..HEAD --oneline 2>/dev/null | wc -l | tr -d ' ')
    echo "## ✓ Safe to Undo"
    echo "$unpushed unpushed commit(s) on this branch."
    echo
  fi
else
  echo "## ✓ Safe to Undo"
  echo "Branch has no remote tracking (new branch)."
  echo
fi
