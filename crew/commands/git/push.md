---
name: crew:git:push
description: Push current branch to origin
allowed-tools: Bash(git push:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/push-context.sh`

## Task

Run the push command shown above.

- Never use `--force` unless explicitly requested
- If rejected, suggest `git pull --rebase` first
