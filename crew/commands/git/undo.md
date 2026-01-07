---
name: crew:git:undo
description: Undo last commit (keeps changes staged)
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, WebFetch, WebSearch, MCPSearch, Skill
---

<undo_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/undo-context.sh`
</undo_context>

<process>

**If "COMMIT ALREADY PUSHED"** → STOP. Requires force-push.

**If "Safe to Undo":**

1. `git reset --soft HEAD~1`
2. `git status`

</process>

<recovery>

```bash
git reflog  # find SHA
git cherry-pick <sha>
```

</recovery>
