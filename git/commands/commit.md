---
name: commit
description: Create conventional commit with selective staging
argument-hint: [message hint]
---

Create a conventional commit with selective file staging. Never blind `git add .`.

## Current State

```bash
git status --short
git diff --stat
```

## Workflow

1. **Review changes** - Check staged and unstaged files
2. **Stage selectively** - Add only relevant files (never `git add .`)
3. **Check for secrets** - Ensure no .env, .pem, .key, credentials staged
4. **Determine type** - Choose commit type based on changes
5. **Write message** - Use conventional format with descriptive body

## Format

```
type(scope): short description

- Bullet point explaining what changed
- Another bullet point if needed
```

## Commands

```bash
# Stage specific files
git add src/feature.ts src/feature.test.ts

# Stage with patch mode (partial files)
git add -p

# Commit with heredoc for multi-line
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

## Constraints

**Banned:**
- `git add .` or `git add -A` without reviewing
- Committing secrets, credentials, API keys, .env files
- Amending commits that have been pushed

**Required:**
- Conventional commit format: `type(scope): description`
- Selective file staging
- Multi-line body for non-trivial changes (3+ files or logic changes)

## Success Criteria

- [ ] Commit uses `type(scope): description` format
- [ ] Only relevant files staged
- [ ] No secrets or sensitive files committed
- [ ] Multi-line body for complex changes
