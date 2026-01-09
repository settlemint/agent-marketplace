---
name: crew:git:stacked:slide-out
description: Remove merged branches from stack, reconnect children, and update PRs
allowed-tools:
  - Bash
  - AskUserQuestion
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh 2>&1`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>

Remove merged branches from machete layout, reconnect children to parent.

</objective>

<workflow>

## Step 1: Identify Merged Branches

```bash
git machete status
```

Look for gray edges (o) indicating merged branches.

## Step 2: Handle Worktree

If in a worktree, cannot slide out:

- The branch checked out in THIS worktree
- A branch checked out in ANOTHER worktree

```javascript
AskUserQuestion({
  questions: [
    {
      question: "You're in a worktree. Which branch to slide out?",
      header: "Branch",
      options: [
        {
          label: "A different branch",
          description: "Slide out a branch NOT checked out in any worktree",
        },
        {
          label: "Show worktree list",
          description: "See which branches have worktrees",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 3: Execute Slide-Out

```bash
git machete slide-out <branch> --no-rebase  # For remote merges
git machete slide-out <branch> --delete     # Also delete local
```

## Step 4: Update PRs

```bash
if git machete is-managed "$(git branch --show-current)" 2>/dev/null; then
  git config machete.github.prDescriptionIntroStyle full
  git machete github retarget-pr --branch "$(git machete show down 2>/dev/null | head -1)" 2>/dev/null || true
  git machete github update-pr-descriptions --related
fi
```

## Step 5: Sync Remaining

```bash
git machete traverse -W -y -H
```

</workflow>

<success_criteria>

- [ ] Merged branch removed from layout
- [ ] Children reconnected to parent
- [ ] Child PRs retargeted
- [ ] PR descriptions updated

</success_criteria>
