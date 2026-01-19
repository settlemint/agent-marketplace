---
name: branch
description: Create feature branch with naming convention
argument-hint: <type> <description>
---

Create a new branch following the `username/type/slug` naming convention, branched from origin/main.

## Arguments

- `type`: feat, fix, hotfix, or chore
- `description`: Brief description (will be converted to kebab-case slug)

## Workflow

1. **Get username** from system
2. **Validate type** (feat/fix/hotfix/chore)
3. **Generate slug** from description (kebab-case, max 30 chars)
4. **Fetch and branch** from origin/main

## Commands

```bash
# Get username
USERNAME=$(whoami)

# Fetch latest main
git fetch origin main

# Create and checkout branch
git checkout -b ${USERNAME}/${TYPE}/${SLUG} origin/main
```

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
- "Add user authentication" → `add-user-authentication`
- "Fix NULL pointer in login" → `fix-null-pointer-in-login`
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
