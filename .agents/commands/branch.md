---
name: branch
description: Create feature branch with naming convention
argument-hint: <type> <description>
---

Create a new branch following the `username/type/slug` naming convention.

## Context

```bash
! whoami
! git branch --show-current
! git fetch origin main --dry-run 2>&1 | head -3
! git branch --list | head -10
```

## Arguments

- `type`: feat, fix, hotfix, or chore
- `description`: Brief description (converted to kebab-case slug)

## Workflow

1. **Validate type** - Must be: feat, fix, hotfix, or chore
2. **Generate slug** - Convert description to kebab-case, max 30 chars
3. **Fetch latest** - `git fetch origin main`
4. **Create branch** - `git checkout -b ${USERNAME}/${TYPE}/${SLUG} origin/main`

## Branch Types

| Type | Use When |
|------|----------|
| `feat` | New feature or enhancement |
| `fix` | Bug fix |
| `hotfix` | Urgent production fix |
| `chore` | Maintenance, dependencies, config |

## Examples

```bash
# Feature branch
git checkout -b roderik/feat/user-authentication origin/main

# Bug fix
git checkout -b roderik/fix/balance-calculation origin/main

# Hotfix
git checkout -b roderik/hotfix/critical-security-patch origin/main

# Chore
git checkout -b roderik/chore/update-dependencies origin/main
```

## Slug Generation

Convert description to kebab-case:
- "Add user authentication" -> `add-user-authentication`
- "Fix NULL pointer in login" -> `fix-null-pointer-in-login`
- Truncate to 30 characters max

## Constraints

**Banned:**
- Creating branches from stale local main
- Branch names with spaces or special characters
- Starting work on main/master directly

**Required:**
- Always fetch origin/main first
- Follow `username/type/slug` format
- Use kebab-case for slug

## Success Criteria

- [ ] Branch follows `username/type/slug` pattern
- [ ] Created from fresh origin/main
- [ ] Currently on the new branch
