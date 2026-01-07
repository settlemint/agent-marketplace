---
name: crew:git:stack-add
description: Add current or specified branch to the machete stack
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, WebFetch, WebSearch, MCPSearch, Skill
---

<constraints>

**CRITICAL: NEVER output plain text questions. Use AskUserQuestion tool for all user choices.**

</constraints>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<process>

1. `git branch --show-current`
2. If no layout → `git machete discover`
3. Add to layout:

```bash
git machete add --onto <parent-branch>
```

4. `git machete status`

If parent not specified:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which parent branch?",
      header: "Parent",
      options: [
        { label: "main", description: "Base off main" },
        { label: "Current parent", description: "Stack on current branch" },
      ],
    },
  ],
});
```

</process>
