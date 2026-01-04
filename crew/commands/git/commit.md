---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git reset:*)
description: Create a conventional commit
---

!`../../scripts/git/commit-context.sh`

## Commit Format

Use conventional commits: `type(scope): description`

| Type | Use For |
|------|---------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring |
| `docs` | Documentation |
| `test` | Tests |
| `chore` | Maintenance |

## Task

1. If sensitive files flagged above, run `git reset HEAD <file>` to unstage
2. Stage files: `git add <files>`
3. Commit: `git commit -m "type(scope): description"`

Execute in a single response.
