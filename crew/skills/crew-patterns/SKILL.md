---
name: crew-patterns
description: Internal patterns for crew commands. Not user-facing.
triggers:
  - "crew:work internal"
  - "crew:plan internal"
context: fork
---

<objective>

Crew-specific patterns. For orchestration (Task, TodoWrite, AskUserQuestion), use `n-skills:orchestration`.

</objective>

<routing>

| Pattern       | Reference                                 | Purpose                          |
| ------------- | ----------------------------------------- | -------------------------------- |
| Orchestration | `n-skills:orchestration`                  | Task, TodoWrite, AskUserQuestion |
| Bash subagent | `references/patterns.md#bash-subagent`    | Large output handling            |
| Task files    | `references/patterns.md#task-file`        | File-based task format           |
| Branch state  | `references/patterns.md#branch-state`     | State persistence                |
| Build checks  | `references/always-works-verification.md` | Sanity checks                    |

</routing>

<constraints>

**CRITICAL: Always use AskUserQuestion for user choices (see `references/patterns.md#user-questions-constraint`).**

</constraints>

<success_criteria>

- Commands reference patterns by name
- Orchestration delegated to n-skills:orchestration
- Crew-specific patterns in references/patterns.md

</success_criteria>
