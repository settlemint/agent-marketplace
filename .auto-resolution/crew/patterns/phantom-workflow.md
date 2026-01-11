---
description: Phantom worktree workflow patterns for parallel development
globs: "**/commands/**/*.md"
alwaysApply: true
---

# Phantom Worktree Workflow

## When to Use Worktrees

Choose phantom worktrees for:

- **Independent features** - Work that doesn't depend on other in-progress changes
- **Hotfixes** - Critical fixes that need isolation from feature work
- **PR reviews** - Checkout PRs without affecting current work
- **Experiments** - Test approaches in isolation

Choose machete stacked branches for:

- **Sequential changes** - Features that build on each other
- **Related PRs** - Changes that should merge in order
- **Refactoring chains** - Incremental improvements

## Worktree Constraints

**Cannot switch branches in a worktree.** Each worktree is locked to its branch.

| Operation        | Safe in Worktree? | Notes                |
| ---------------- | ----------------- | -------------------- |
| `git commit`     | Yes               | Normal operation     |
| `git push`       | Yes               | Normal operation     |
| `git pull`       | Yes               | Normal operation     |
| `git checkout`   | **NO**            | Will fail            |
| `git switch`     | **NO**            | Will fail            |
| `phantom create` | Yes               | Creates new worktree |

## Creating Worktrees

Use phantom commands (not raw git worktree):

```bash
# Create new worktree from main
phantom create feat/my-feature --base main

# Create from current branch
phantom create feat/child --base $(git branch --show-current)

# Attach existing branch
phantom attach existing-branch
```

## Working Across Worktrees

Run commands in other worktrees without switching:

```bash
# Run tests in another worktree
phantom exec feat/other npm test

# Build in another worktree
phantom exec feat/other npm run build

# Check git status
phantom exec feat/other git status
```

## Cleanup

Always clean up finished worktrees:

```bash
# Delete worktree and branch
phantom delete feat/completed

# Force delete with uncommitted changes
phantom delete feat/abandoned -f
```

## Integration with Machete

Worktrees can contain their own stacked branches:

```bash
# In a worktree, create stacked branches
git checkout -b feat/feature-part-2
git machete add --onto feat/feature-part-1
```

**Best Practice:** One primary stack per worktree.
