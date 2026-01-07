---
name: crew:git:clean
description: Clean up stale branches (deleted on remote)
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, WebFetch, WebSearch, MCPSearch, Skill
---

<clean_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/clean-context.sh`
</clean_context>

<process>

If cleanup commands shown → execute them.
If "No Stale Branches" → report no cleanup needed.

</process>
