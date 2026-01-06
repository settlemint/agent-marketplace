---
name: crew:git:push
description: Push current branch to origin
allowed-tools: Bash(git push:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/push-context.sh`

<process>

Run push command shown above.

- Never `--force` unless explicitly requested
- If rejected → `git pull --rebase` first

</process>
