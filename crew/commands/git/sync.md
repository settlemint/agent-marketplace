---
name: crew:git:sync
description: Sync current branch with main
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/sync-context.sh`
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

<process>

**If machete-managed branch:**

⚠️ This branch is part of a stack. Sync with PARENT, not main:

```bash
git fetch origin
git machete update           # Rebase onto parent branch
git push --force-with-lease  # Push rebased branch
```

Do NOT use `git rebase origin/main` - that would flatten the stack!

**If in a WORKTREE with stacked branches:**

This is the correct workflow - each worktree syncs its own branch:

```bash
git fetch origin
git machete update           # Rebase onto parent
git push --force-with-lease
```

Then move to child worktrees and repeat.

**If regular branch (not machete-managed):**

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
