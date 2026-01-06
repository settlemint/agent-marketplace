---
name: crew:restart
description: Resume pending work from a previous session
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/restart-context.sh`

<process>

Based on context above:

1. **Pending tasks** → `/crew:build`
2. **Active workflow** → Resume via Skill tool
3. **state.json exists** → Restore TodoWrite, continue
4. **Nothing pending** → Inform user

Execute immediately without confirmation.

</process>
