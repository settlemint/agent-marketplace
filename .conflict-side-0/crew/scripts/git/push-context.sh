#!/usr/bin/env bash
set -euo pipefail

branch=$(git branch --show-current)

echo "## Branch"
echo '```'
echo "$branch"
echo '```'
echo

echo "## Remote Tracking"
echo '```'
upstream=$(git rev-parse --abbrev-ref --symbolic-full-name "@{u}" 2>/dev/null || echo "none")
echo "Upstream: $upstream"
echo '```'
echo

echo "## Unpushed Commits"
echo '```'
if [[ "$upstream" != "none" ]]; then
  git log "@{u}..HEAD" --oneline 2>/dev/null || echo "(none)"
else
  git log "origin/main..HEAD" --oneline 2>/dev/null || echo "(new branch)"
fi
echo '```'
echo

# Determine push command
if [[ "$upstream" == "none" ]]; then
  echo "## Push Command"
  echo '```bash'
  echo "git push -u origin $branch"
  echo '```'
else
  echo "## Push Command"
  echo '```bash'
  echo "git push"
  echo '```'
fi
