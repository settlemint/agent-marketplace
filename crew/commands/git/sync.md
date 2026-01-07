---
name: crew:git:sync
description: Sync current branch with main
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/sync-context.sh`
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

<process>

**If machete-managed branch:**

⚠️ This branch is part of a stack. Use `git machete update` to sync with parent:

```bash
git machete update   # Rebase onto parent branch
```

Or use `/crew:git:traverse` to sync the entire stack.

**If regular branch (not in machete):**

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
