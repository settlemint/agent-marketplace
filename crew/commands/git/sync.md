---
name: crew:git:sync
description: Sync current branch with main
allowed-tools: Bash(git fetch:*), Bash(git rebase:*), Bash(git stash:*), Bash(git status:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/sync-context.sh`

<process>

1. If uncommitted → `git stash push -m "sync-stash"`
2. `git fetch origin main`
3. `git rebase origin/main`
4. If stashed → `git stash pop`

</process>

<on_conflict>

- Report conflicting files
- Do NOT auto-resolve
- Tell user: `git rebase --continue` after fixing

</on_conflict>
