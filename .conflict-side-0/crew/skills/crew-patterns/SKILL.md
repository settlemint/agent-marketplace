---
name: crew-patterns
description: Internal patterns for crew commands. Not user-facing.
triggers:
  - "crew:work internal"
  - "crew:plan internal"
context: fork
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

| Pattern                     | Purpose                                      |
| --------------------------- | -------------------------------------------- |
| `user-questions-constraint` | **MANDATORY** - Use AskUserQuestion always   |
| `spawn-batch`               | Launch parallel agents (max 6)               |
| `test-runner`               | Bash subagent for test execution             |
| `large-output`              | Bash subagent for commands with large output |
| `todo-progress`             | TodoWrite status tracking                    |
| `ask-user`                  | AskUserQuestion templates                    |
| `task-file`                 | Task file frontmatter format                 |
| `collect-results`           | TaskOutput collection pattern                |
| `always-works`              | Verification sanity checks for builds        |

</routing>

<constraints>

**CRITICAL: Follow `<pattern name="user-questions-constraint"/>` at ALL times.**

Never output plain text questions with bullet options. Always use AskUserQuestion tool.

</constraints>

<references>

- `references/patterns.md` - All pattern definitions
- `references/always-works-verification.md` - Build verification sanity checks

</references>

<success_criteria>

- Commands reference patterns by name
- No duplicate code examples across commands
- Single source of truth for each pattern

</success_criteria>
