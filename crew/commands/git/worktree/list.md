---
name: crew:git:worktree:list
description: List all phantom worktrees
allowed-tools:
  - Bash
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<gitbutler_incompatible>

**This command does not work with GitButler.**

If `GITBUTLER_ACTIVE=true` from `<butler_context>`:

```
Git worktrees are not compatible with GitButler virtual branches.

GitButler uses virtual branches instead of worktrees for parallel development.
All virtual branches exist in the same working directory simultaneously.

Use these instead:
- `crew:git:butler:status` - View virtual branches (equivalent to worktree list)
- `crew:git:butler:branch` - Create virtual branch (equivalent to worktree create)

To use worktrees, first disable GitButler in this repository.
```

Exit immediately. Do not proceed with worktree commands.

</gitbutler_incompatible>

<objective>

List all phantom worktrees.

</objective>

<workflow>

## Step 1: List Worktrees

```bash
phantom list
```

</workflow>

<success_criteria>

- [ ] Worktrees listed

</success_criteria>
