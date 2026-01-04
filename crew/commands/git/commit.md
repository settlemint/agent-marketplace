---
allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*), Bash(git diff:*)
description: Create a conventional commit
---

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --short`
- Diff stats: !`git diff --stat HEAD`
- Recent commits (for style reference): !`git log --oneline -5`

## Commit Message Format

Use conventional commits: `type(scope): description`

Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `ci`, `build`

Examples:
- `feat(auth): add OAuth2 login flow`
- `fix(api): handle null response from payment service`
- `refactor(db): simplify query builder interface`

## Safety Checks

Before committing, verify NO sensitive files are staged:
- `.env*` files (except `.env.example`)
- `*credentials*`, `*secret*`, `*.pem`, `*.key`
- `node_modules/`, `.git/`

If sensitive files are staged, unstage them and warn the user.

## Your Task

1. Review the diff to understand the changes
2. Check for sensitive files - unstage if found
3. Stage appropriate files with `git add`
4. Create a single commit with a conventional commit message

Execute all git commands in a single response. Do not output any other text.
