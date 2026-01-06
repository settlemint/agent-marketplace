---
name: crew:git:commit-and-push
description: Create a conventional commit and push to origin
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git reset:*), Bash(git push:*)
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
4. `git push -u origin $(git branch --show-current)`

Never `--force` unless explicitly requested. If rejected → `git pull --rebase` first.

</process>
