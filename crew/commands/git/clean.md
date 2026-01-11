---
name: crew:git:clean
description: Clean up stale branches (deleted on remote)
model: haiku
allowed-tools:
  - Bash
context: fork
hooks:
  PostToolUse: false
  PreToolUse: false
---

<clean_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/clean-context.sh`
</clean_context>

<objective>

Delete local branches that no longer exist on remote. Execute cleanup commands if shown above.

</objective>

<workflow>

## Step 1: Execute Cleanup

If `<clean_context>` shows cleanup commands → execute them.
If "No Stale Branches" → report no cleanup needed.

</workflow>

<success_criteria>

- [ ] Stale branches deleted (if any)

</success_criteria>
