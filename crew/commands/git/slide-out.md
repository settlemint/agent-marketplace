---
name: crew:git:slide-out
description: Remove merged branches from stack and reconnect children
allowed-tools: Bash(git machete:*), Bash(git branch:*), Bash(git fetch:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

## Purpose

Remove a merged branch from the git-machete layout and reconnect its child branches to its parent. Essential for cleaning up after PRs are merged.

## What Happens

1. Branch is removed from `.git/machete` layout
2. Child branches are attached to the parent of removed branch
3. By default, children are rebased onto new parent
4. Optionally delete the local branch

## Task

1. **If no branch specified**, check for merged branches:

   ```bash
   git machete status
   ```

   Look for gray edges (merged branches)

2. **Slide out the branch**:

   ```bash
   # Standard slide-out (rebases children)
   git machete slide-out <branch>

   # For remote merges (squash/merge queue), skip rebase
   git machete slide-out --no-rebase <branch>

   # Also delete local branch
   git machete slide-out --delete <branch>
   ```

3. **After slide-out**, sync remaining branches:
   ```bash
   git machete traverse -W -y -H
   ```

## Common Workflows

**After PR merged via GitHub:**

```bash
# Slide out without immediate rebase (remote merge)
git machete slide-out --no-rebase feature-x

# Sync and retarget remaining PRs
git machete traverse -W -y -H
```

**Multiple merged branches:**

```bash
git machete slide-out branch1 branch2 branch3 --no-rebase
git machete traverse -W -y
```
