---
name: crew:git:commit-and-push
description: Create a conventional commit and push to origin
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
  - TodoWrite
  - WebFetch
  - WebSearch
  - MCPSearch
  - Skill
---

<commit_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/commit-context.sh 2>&1`
</commit_context>

<notes>
This command delegates to canonical skill locations for each phase.
</notes>

<process>

<phase name="commit">
**Create conventional commit:**

```javascript
Skill({ skill: "crew:git:commit" });
```

</phase>

<phase name="push">
**Sync stack (if machete), push, and update PR:**

```javascript
Skill({ skill: "crew:git:push" });
```

</phase>

</process>
