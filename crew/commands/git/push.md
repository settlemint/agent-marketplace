---
allowed-tools: Bash(git push:*), Bash(git status:*), Bash(git log:*)
description: Push current branch to origin
---

## Context

- Current branch: !`git branch --show-current`
- Remote tracking: !`git status -sb | head -1`
- Unpushed commits: !`git log @{u}..HEAD --oneline 2>/dev/null || git log origin/main..HEAD --oneline 2>/dev/null || echo "New branch"`

## Your Task

Push the current branch to origin:

1. **If branch has no upstream**, set it:
   ```bash
   git push -u origin $(git branch --show-current)
   ```

2. **If branch already tracks remote**, just push:
   ```bash
   git push
   ```

## Safety

- Never use `--force` unless explicitly requested
- If push is rejected, report the error and suggest `git pull --rebase` first
