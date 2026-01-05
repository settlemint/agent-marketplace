---
name: crew:git:commit-and-push
description: Create a conventional commit and push to origin
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git reset:*), Bash(git push:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/commit-context.sh`

## Commit Format

Use conventional commits: `type(scope): description`

| Type       | Use For            |
| ---------- | ------------------ |
| `feat`     | New feature        |
| `fix`      | Bug fix            |
| `refactor` | Code restructuring |
| `docs`     | Documentation      |
| `test`     | Tests              |
| `chore`    | Maintenance        |

## Task

1. If sensitive files flagged above, run `git reset HEAD <file>` to unstage
2. Stage files: `git add <files>`
3. Commit: `git commit -m "type(scope): description"`
4. Push: `git push -u origin $(git branch --show-current)`

Execute all steps in a single response.

- Never use `--force` unless explicitly requested
- If push rejected, suggest `git pull --rebase` first
