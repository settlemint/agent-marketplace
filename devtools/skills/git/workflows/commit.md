---
name: commit
description: Create conventional commit with selective staging
---

<context>
!`${SKILL_ROOT}/scripts/context.sh commit`
</context>

<objective>
Create a conventional commit: `type(scope): description`. Stage files selectively. Never blind `git add .`.
</objective>

<workflow>

1. **Review changes:** Parse context above for staged/unstaged files
2. **Stage selectively:** Add only relevant files (never `git add .`)
3. **Check for secrets:** Ensure no .env, .pem, .key, credentials staged
4. **Commit:** Use conventional format with multi-line body for non-trivial changes

</workflow>

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

<commands>

```bash
# Review what changed
git status --short
git diff --stat

# Stage specific files (preferred)
git add src/feature.ts src/feature.test.ts

# Stage with patch mode (for partial files)
git add -p

# Commit with conventional format
git commit -m "$(cat <<'EOF'
feat(auth): add login endpoint

- Added POST /api/auth/login
- Created AuthService with password verification
- Added unit tests for authentication flow
EOF
)"

# Single-line for trivial changes
git commit -m "fix(typo): correct spelling in README"
```

</commands>

<constraints>

**Banned:**
- `git add .` without reviewing changes
- `git add -A` without reviewing changes
- Committing secrets, credentials, API keys, .env files
- Amending commits that have been pushed

**Required:**
- Conventional commit format: `type(scope): description`
- Selective file staging
- Multi-line commit body for non-trivial changes

</constraints>

<success_criteria>

- [ ] Commit uses `type(scope): description` format
- [ ] Only relevant files staged
- [ ] No secrets or sensitive files committed
- [ ] Multi-line body for complex changes

</success_criteria>
