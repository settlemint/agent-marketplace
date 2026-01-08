---
name: crew:git:sync
description: Sync current branch with main
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
  - TodoWrite
  - WebFetch
  - WebSearch
  - MCPSearch
  - Skill
---

<sync_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/sync-context.sh`
</sync_context>

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<process>

**Check `<stack_context>` above to determine which sync method to use.**

## If "is in machete layout" (machete-managed branch)

⚠️ This branch is part of a stack. Sync with PARENT, not main:

```bash
# Verify machete-managed first
if git machete is-managed "$(git branch --show-current)" 2>/dev/null; then
  git fetch origin
  git machete update           # Rebase onto parent branch
  git push --force-with-lease  # Push rebased branch
fi
```

Do NOT use `git rebase origin/main` - that would flatten the stack!

**If also in a WORKTREE:** This is the correct workflow - each worktree syncs its own branch. After syncing, move to child worktrees and repeat.

## If "is NOT in machete layout" (regular branch)

```bash
# Stash uncommitted changes if any
git stash push -m "sync-stash" 2>/dev/null || true

git fetch origin main
git rebase origin/main

# Pop stash if we stashed
git stash pop 2>/dev/null || true
```

</process>

<on_conflict>

- Report conflicting files
- Do NOT auto-resolve
- Tell user: `git rebase --continue` after fixing

</on_conflict>
