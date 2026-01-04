---
allowed-tools: Bash(git fetch:*), Bash(git rebase:*), Bash(git merge:*), Bash(git status:*), Bash(git stash:*), Bash(git log:*)
description: Sync current branch with main
---

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Commits ahead/behind: !`git rev-list --left-right --count origin/main...HEAD 2>/dev/null || echo "N/A"`

## Your Task

Sync the current branch with the latest changes from main:

1. **Stash uncommitted changes** (if any)
   ```bash
   git stash push -m "auto-stash before sync"
   ```

2. **Fetch latest from origin**
   ```bash
   git fetch origin main
   ```

3. **Rebase current branch onto main**
   ```bash
   git rebase origin/main
   ```

4. **Pop stashed changes** (if stashed in step 1)
   ```bash
   git stash pop
   ```

## Conflict Handling

If rebase conflicts occur:
- Report the conflicting files
- Do NOT attempt to resolve automatically
- Instruct user to resolve manually, then run `git rebase --continue`

## Expected Output

Report sync status: commits rebased, any conflicts, stash restored.
