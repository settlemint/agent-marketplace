---
name: crew:git:sync
description: Sync current branch with main
allowed-tools: Bash(git fetch:*), Bash(git rebase:*), Bash(git stash:*), Bash(git status:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/sync-context.sh`

## Task

1. **Stash** (if uncommitted changes): `git stash push -m "sync-stash"`
2. **Fetch**: `git fetch origin main`
3. **Rebase**: `git rebase origin/main`
4. **Pop stash** (if stashed): `git stash pop`

## On Conflict

If rebase conflicts:

- Report conflicting files
- Do NOT auto-resolve
- Tell user to run `git rebase --continue` after fixing
