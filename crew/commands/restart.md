---
name: crew:restart
description: Resume pending work from a previous session
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/restart-context.sh`

## Task

Based on the context above:

1. **If pending tasks found**: Resume work by invoking `/crew:build`
2. **If active workflow found**: Resume using the Skill tool as shown
3. **If state.json exists**: Restore todos with TodoWrite, then continue
4. **If nothing pending**: Inform user there's no work to resume

Execute the appropriate action immediately without asking for confirmation.
