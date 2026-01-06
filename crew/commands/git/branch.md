---
name: crew:git:branch
description: Create a feature branch from main
allowed-tools: Bash(git checkout:*), Bash(git fetch:*), Bash(git branch:*)
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/branch-context.sh`

## Naming Convention

`type/short-description`

| Type        | Use For       |
| ----------- | ------------- |
| `feat/`     | New feature   |
| `fix/`      | Bug fix       |
| `refactor/` | Restructuring |
| `docs/`     | Documentation |
| `chore/`    | Maintenance   |

## Task

1. Check current branch: `git branch --show-current`
2. **If NOT on main/master**: Warn user they're on a feature branch and ask to confirm switching
3. `git fetch origin main`
4. `git checkout -b <type>/<name> origin/main`

If no name provided, ask user what they're working on.
