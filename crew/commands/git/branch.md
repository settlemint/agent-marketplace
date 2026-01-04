---
allowed-tools: Bash(git checkout:*), Bash(git fetch:*), Bash(git branch:*)
description: Create a feature branch from main
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/branch-context.sh`

## Naming Convention

`type/short-description`

| Type | Use For |
|------|---------|
| `feat/` | New feature |
| `fix/` | Bug fix |
| `refactor/` | Restructuring |
| `docs/` | Documentation |
| `chore/` | Maintenance |

## Task

1. `git fetch origin main`
2. `git checkout -b <type>/<name> origin/main`

If no name provided, ask user what they're working on.
