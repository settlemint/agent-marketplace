---
name: crew-patterns
description: Internal patterns for crew commands. Not user-facing.
triggers:
  - "crew:build internal"
  - "crew:design internal"
---

<objective>

Reusable patterns for crew command implementation. All crew commands reference these patterns instead of duplicating code examples.

</objective>

<quick_start>

Reference patterns by name in commands:

```xml
<!-- In command files -->
<process>
Use <pattern name="spawn-batch"/> for parallel agent execution.
Use <pattern name="test-runner"/> after each batch.
</process>
```

</quick_start>

<routing>

| Pattern           | Purpose                        |
| ----------------- | ------------------------------ |
| `spawn-batch`     | Launch parallel agents (max 6) |
| `test-runner`     | Haiku agent for test execution |
| `todo-progress`   | TodoWrite status tracking      |
| `ask-user`        | AskUserQuestion templates      |
| `task-file`       | Task file frontmatter format   |
| `collect-results` | TaskOutput collection pattern  |

</routing>

<references>

- `references/patterns.md` - All pattern definitions

</references>

<success_criteria>

- Commands reference patterns by name
- No duplicate code examples across commands
- Single source of truth for each pattern

</success_criteria>
