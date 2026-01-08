---
name: crew:git:clean
description: Clean up stale branches (deleted on remote)
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, WebFetch, WebSearch, MCPSearch, Skill
context: fork
hooks:
  PostToolUse: false
  PreToolUse: false
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<clean_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/clean-context.sh`
</clean_context>

<process>

If cleanup commands shown → execute them.
If "No Stale Branches" → report no cleanup needed.

</process>
