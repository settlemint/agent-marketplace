---
name: branch
description: Create a feature branch with naming convention. Use when asked to "create branch", "new branch", or "start feature".
license: MIT
user_invocable: true
command: /branch
argument-hint: "[branch description or type/name]"
triggers:
  - "create branch"
  - "new branch"
  - "start feature"
  - "feature branch"
---

<objective>
Create branch: `username/type/slug` from origin/main.
</objective>

<quick_start>

1. **Get username:** `whoami`
2. **Determine type:** feat, fix, hotfix, or chore
3. **Generate slug:** kebab-case from description, max 30 chars
4. **Create branch:** `git checkout -b ${username}/${type}/${slug} origin/main`

</quick_start>

<branch_types>

| Type     | Use When                        |
| -------- | ------------------------------- |
| `feat`   | New feature                     |
| `fix`    | Bug fix                         |
| `hotfix` | Urgent production fix           |
| `chore`  | Maintenance, deps, config       |

</branch_types>

<workflow>

**Step 1: Fetch latest main**

```bash
git fetch origin main
```

**Step 2: Get username**

```bash
USERNAME=$(whoami)
```

**Step 3: Create branch**

```bash
# Feature branch
git checkout -b ${USERNAME}/feat/asset-transfer origin/main

# Bug fix
git checkout -b ${USERNAME}/fix/balance-calc origin/main

# Chore
git checkout -b ${USERNAME}/chore/update-deps origin/main
```

</workflow>

<naming_rules>

- **Format:** `username/type/slug`
- **Slug:** kebab-case, max 30 chars
- **No spaces:** Use hyphens instead
- **Lowercase:** All lowercase

**Good examples:**
- `roderik/feat/user-authentication`
- `roderik/fix/null-pointer-login`
- `roderik/chore/bump-dependencies`

**Bad examples:**
- `feature/UserAuth` (no username, not kebab-case)
- `roderik-fix-bug` (wrong format)
- `feat_user_auth` (underscores instead of hyphens)

</naming_rules>

<constraints>

**Banned:**
- Creating branch from dirty working tree (stash first)
- Branch names with spaces or special characters
- Creating branch from non-main base without explicit request

**Required:**
- Branch from origin/main (freshly fetched)
- Follow `username/type/slug` naming convention
- Kebab-case slug

</constraints>

<success_criteria>

1. [ ] Branch follows `username/type/slug` pattern
2. [ ] Created from origin/main
3. [ ] Slug is kebab-case, max 30 chars

</success_criteria>
