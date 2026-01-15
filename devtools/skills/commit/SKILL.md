---
name: commit
description: Create a conventional commit. Use when asked to "commit changes" or "save my work".
license: MIT
user_invocable: true
command: /commit
argument-hint: "[optional commit message]"
triggers:
  - "commit"
  - "save changes"
  - "commit my work"
---

<objective>
Create a conventional commit with proper format: `type(scope): description`. Stage files selectively, run QA if needed.
</objective>

<quick_start>

1. **Check status:** `git status` to see what changed
2. **Stage files:** `git add <specific-files>` (never blind `git add .`)
3. **Commit:** `git commit -m "type(scope): description"`

</quick_start>

<commit_types>

| Type       | Use When                              |
| ---------- | ------------------------------------- |
| `feat`     | New feature                           |
| `fix`      | Bug fix                               |
| `docs`     | Documentation only                    |
| `refactor` | Code change (no feature/fix)          |
| `test`     | Adding/updating tests                 |
| `chore`    | Maintenance, deps, config             |
| `perf`     | Performance improvement               |
| `style`    | Formatting (no code change)           |

</commit_types>

<workflow>

**Step 1: Review changes**

```bash
git status
git diff --stat
```

**Step 2: Stage relevant files**

```bash
# Stage specific files
git add src/feature.ts src/feature.test.ts

# Interactive staging (optional)
git add -p
```

**Step 3: Create commit**

```bash
git commit -m "$(cat <<'EOF'
feat(auth): add login endpoint

- Added POST /api/auth/login
- Created AuthService with password verification
- Added unit tests for authentication flow
EOF
)"
```

</workflow>

<constraints>

**Banned:**
- `git add .` without reviewing changes
- Committing secrets, credentials, or API keys
- Amending commits that have been pushed

**Required:**
- Conventional commit format
- Selective file staging
- Multi-line commit body for non-trivial changes

</constraints>

<success_criteria>

1. [ ] Commit uses `type(scope): description` format
2. [ ] Only relevant files staged
3. [ ] No secrets committed

</success_criteria>
