---
name: crew:git:commit
description: Create a conventional commit
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git reset:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/commit-context.sh`

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
