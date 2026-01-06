---
name: crew:git:commit
description: Create a conventional commit
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*), Bash(git reset:*)
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
3. Commit with `[skill]` marker to bypass hook: `git commit -m "[skill] type(scope): description"`

**IMPORTANT:** The `[skill]` prefix is required to bypass the git commit hook that redirects to this skill. Without it, the commit will be blocked.

Execute in a single response.
