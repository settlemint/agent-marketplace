---
allowed-tools: Bash(git checkout:*), Bash(git fetch:*), Bash(git branch:*), Bash(git status:*)
description: Create a feature branch from main
---

## Context

- Current branch: !`git branch --show-current`
- Git status: !`git status --short`

## Branch Naming Convention

Use: `type/short-description`

Types:
- `feat/` - New feature
- `fix/` - Bug fix
- `refactor/` - Code refactoring
- `docs/` - Documentation
- `test/` - Tests
- `chore/` - Maintenance

Examples:
- `feat/oauth-login`
- `fix/null-pointer-api`
- `refactor/query-builder`

## Your Task

1. **Check for uncommitted changes** - warn if working directory is dirty
2. **Fetch latest main**
   ```bash
   git fetch origin main
   ```
3. **Create and checkout new branch from origin/main**
   ```bash
   git checkout -b <branch-name> origin/main
   ```

## Input

If no branch name provided, ask the user what they're working on and suggest a name.
