---
description: Git safety rules to prevent destructive operations and enforce conventions
globs: "**/*"
alwaysApply: true
---

# Git Safety Rules

These rules protect the repository from destructive operations and enforce consistent git practices.

## Protected Operations - NEVER Execute

### Destructive Commands

- **NEVER** run `git push --force` or `git push -f` to main/master
- **NEVER** run `git reset --hard` on shared branches
- **NEVER** run `git clean -fd` without explicit user confirmation
- **NEVER** run `git branch -D` (force delete) without checking merge status
- **NEVER** run `git rebase -i` (interactive) - it requires terminal interaction

### Configuration Changes

- **NEVER** modify git config (user.name, user.email, etc.)
- **NEVER** modify .gitignore to exclude security-sensitive patterns
- **NEVER** disable git hooks with `--no-verify`

## Protected Files - NEVER Commit

These patterns must NEVER be staged or committed:

```
.env
.env.*
*.pem
*.key
*credentials*
*secrets*
*password*
*.p12
*.pfx
id_rsa*
known_hosts
```

If these files are staged, warn the user and unstage them.

## Commit Message Format

Use conventional commit format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

| Type       | Usage                      |
| ---------- | -------------------------- |
| `feat`     | New feature                |
| `fix`      | Bug fix                    |
| `docs`     | Documentation only         |
| `style`    | Formatting, no code change |
| `refactor` | Code restructuring         |
| `perf`     | Performance improvement    |
| `test`     | Adding tests               |
| `chore`    | Maintenance tasks          |
| `ci`       | CI/CD changes              |

### Rules

- Use present tense ("add" not "added")
- Keep description under 50 characters
- Start description with lowercase after colon
- No period at the end
- Include scope when changes are localized

## Branch Naming

Format: `<type>/<short-description>`

```bash
feat/add-user-auth
fix/login-validation
refactor/api-structure
```

## Pre-Push Checklist

Before pushing, verify:

1. `bun run ci` passes (or equivalent)
2. No pending uncommitted changes
3. Branch is up-to-date with target
4. No secrets in staged files

## Amend Safety

Only use `git commit --amend` when ALL conditions are met:

1. User explicitly requested amend
2. HEAD commit was created by you in this conversation
3. Commit has NOT been pushed to remote

If any condition fails, create a new commit instead.
