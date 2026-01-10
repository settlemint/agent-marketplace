---
name: crew:git:worktree:checkout-pr
description: Create a worktree from a GitHub PR or issue
argument-hint: "<PR or issue number>"
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

For PR checkout with GitButler, use:
- `gh pr checkout <number>` - Standard checkout (exits GitButler mode)
- Or work directly on virtual branches

To use worktrees, first disable GitButler in this repository.
```

Exit immediately. Do not proceed with worktree commands.

</gitbutler_incompatible>

<objective>

Checkout PR or issue into a new phantom worktree.

</objective>

<workflow>

## Step 1: Checkout PR/Issue

```bash
phantom gh checkout ${number}
```

## Step 2: Instruct User

```
Checked out PR/issue #${number}
Worktree created at: $(phantom where ${branchName})

To work on this:
  phantom shell ${branchName}
```

</workflow>

<success_criteria>

- [ ] PR/issue checked out
- [ ] Worktree created

</success_criteria>
