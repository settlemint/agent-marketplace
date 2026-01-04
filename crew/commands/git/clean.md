---
description: Clean up stale branches (deleted on remote) and prune remote tracking
---

## Your Task

Clean up local branches that have been deleted from the remote repository.

## Steps

1. **Fetch and prune remote tracking branches**
   ```bash
   git fetch --prune
   ```

2. **List branches to identify [gone] status**
   ```bash
   git branch -vv
   ```

3. **Remove worktrees and delete [gone] branches**
   ```bash
   git branch -vv | grep ': gone]' | awk '{print $1}' | while read branch; do
     echo "Processing: $branch"
     worktree=$(git worktree list | grep "\\[$branch\\]" | awk '{print $1}')
     if [ -n "$worktree" ] && [ "$worktree" != "$(git rev-parse --show-toplevel)" ]; then
       echo "  Removing worktree: $worktree"
       git worktree remove --force "$worktree"
     fi
     echo "  Deleting branch: $branch"
     git branch -D "$branch"
   done
   ```

## Expected Output

Report which branches were deleted. If none found, report "No stale branches to clean."
