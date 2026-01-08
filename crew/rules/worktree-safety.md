---
description: Git worktree constraints and safe operations
globs: "**/commands/git/**/*.md"
alwaysApply: true
---

# Worktree Safety

## Critical Constraint

**Cannot switch branches in a worktree.** Each worktree is bound to its branch.

## Detection

Check if in a worktree:

```bash
git rev-parse --is-inside-work-tree && git worktree list | grep -q "$(pwd)"
```

Or check `<worktree_status>` context - if it shows "WORKTREE", special handling required.

## Safe Operations in Worktrees

| Operation     | Safe?   | Notes                          |
| ------------- | ------- | ------------------------------ |
| Commit        | Yes     | Normal git commit works        |
| Push          | Yes     | Normal git push works          |
| Pull/Fetch    | Yes     | Normal fetch/pull works        |
| Rebase        | Yes     | `git machete update` is safe   |
| Checkout      | **NO**  | Cannot switch branches         |
| Branch delete | Careful | Don't delete worktree's branch |

## When User Wants Different Branch

If user needs to work on a different branch while in a worktree:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "You're in a worktree. How do you want to proceed?",
      header: "Method",
      options: [
        {
          label: "Create new worktree",
          description: "New branch in separate directory",
        },
        {
          label: "Switch to main checkout",
          description: "cd to main repo directory",
        },
        {
          label: "Stay here",
          description: "Continue on current branch",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

## Creating Branch in Worktree Context

```bash
# New worktree for the branch
git worktree add ../<branch-name> -b <type>/<name>

# Then tell user:
# cd ../<branch-name>
```

## Worktree Cleanup

```bash
# List all worktrees
git worktree list

# Remove a worktree (after merging its branch)
git worktree remove <path>

# Prune stale worktree references
git worktree prune
```
