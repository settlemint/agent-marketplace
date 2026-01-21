---
name: commit
description: Create conventional commit with all changes staged
argument-hint: [message hint]
---

Create a conventional commit with all current changes staged.

In multi-agent and human-in-the-loop workflows, all changes should be committed unless they are clearly cruft. Do not be overly selective.

## Context

```bash
! git status --short
! git diff --stat
! git diff --cached --stat
! git log --oneline -5
```

## Workflow

1. **Review changes** - Check all modified files
2. **Stage all changes** - `git add -A` (stage everything)
3. **Check for secrets** - Verify no .env, .pem, .key, credentials staged
4. **Determine type** - Choose commit type based on changes
5. **Write message** - Use conventional format with descriptive body

## Commit Format

```
type(scope): short description

- Bullet point explaining what changed
- Another bullet point if needed
```

## Commit Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring without behavior change |
| `docs` | Documentation only |
| `test` | Adding or updating tests |
| `chore` | Build, CI, dependencies |
| `perf` | Performance improvement |

## Commands

```bash
# Stage all changes
git add -A

# Check for sensitive files
git diff --cached --name-only | grep -E '\.(env|pem|key)$|credentials|secret'

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

## Sensitive File Handling

If sensitive files are staged, unstage them:
```bash
git reset HEAD <sensitive-file>
```

Then re-run the commit.

## Constraints

**Banned:**
- Committing secrets, credentials, API keys, .env files
- Amending commits that have been pushed
- Being overly selective (commit all work in multi-agent workflows)

**Required:**
- Conventional commit format: `type(scope): description`
- Stage all changes with `git add -A`
- Multi-line body for non-trivial changes (3+ files or logic changes)

## Success Criteria

- [ ] Commit uses `type(scope): description` format
- [ ] All changes staged with `git add -A`
- [ ] No secrets or sensitive files committed
- [ ] Multi-line body for complex changes
