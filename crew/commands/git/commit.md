---
name: crew:git:commit
description: Create a conventional commit
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, WebFetch, WebSearch, MCPSearch, Skill
---

<commit_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/commit-context.sh`
</commit_context>

<format>

`type(scope): description`

| Type       | Use           |
| ---------- | ------------- |
| `feat`     | New feature   |
| `fix`      | Bug fix       |
| `refactor` | Restructuring |
| `docs`     | Documentation |
| `test`     | Tests         |
| `chore`    | Maintenance   |

</format>

<process>

1. If sensitive files flagged → `git reset HEAD <file>`
2. `git add <files>`
3. `git commit -m "type(scope): description"`

</process>
