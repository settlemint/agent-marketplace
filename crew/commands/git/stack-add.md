---
name: crew:git:stack-add
description: Add current or specified branch to the machete stack
allowed-tools: Bash(git machete:*), Bash(git branch:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

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
