---
allowed-tools: Bash(git reset:*), Bash(git log:*), Bash(git status:*), Bash(git reflog:*)
description: Undo last commit (keeps changes staged)
---

## Context

- Current branch: !`git branch --show-current`
- Last commit: !`git log -1 --oneline`
- Remote tracking: !`git status -sb | head -1`

## Safety Check

**STOP if the commit has been pushed to remote.** Undoing pushed commits requires force-push which can break collaborators.

Check with:
```bash
git log origin/$(git branch --show-current)..HEAD --oneline
```

If empty or error, the commit is pushed - warn user and abort.

## Your Task

If safe to proceed:

1. **Soft reset** - keeps changes staged
   ```bash
   git reset --soft HEAD~1
   ```

2. **Show result**
   ```bash
   git status
   ```

## Recovery

If user needs to recover the undone commit:
```bash
git reflog  # find the commit SHA
git cherry-pick <sha>
```
