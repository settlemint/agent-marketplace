---
allowed-tools: Bash(git reset:*), Bash(git status:*)
description: Undo last commit (keeps changes staged)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/undo-context.sh`

## Task

**If "COMMIT ALREADY PUSHED" above**: STOP. Tell user this requires force-push.

**If "Safe to Undo"**:
1. `git reset --soft HEAD~1`
2. `git status`

## Recovery

If user needs the undone commit back:
```bash
git reflog  # find SHA
git cherry-pick <sha>
```
