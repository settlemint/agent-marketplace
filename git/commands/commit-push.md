---
name: commit-push
description: Create conventional commit and push to remote
argument-hint: [message hint] [--force-with-lease]
---

Create a conventional commit with selective staging and push to remote in one step.

## Current State

```bash
git status --short
git diff --stat
git branch --show-current
git log origin/$(git branch --show-current)..HEAD --oneline 2>/dev/null || echo "New branch"
```

## Workflow

1. **Review changes** - Check staged and unstaged files
2. **Stage selectively** - Add only relevant files (never `git add .`)
3. **Check for secrets** - Ensure no .env, .pem, .key, credentials staged
4. **Determine type** - Choose commit type based on changes
5. **Write message** - Use conventional format with descriptive body
6. **Verify branch** - Block if on main/master
7. **Push** - With appropriate flags (-u for new, --force-with-lease after rebase)

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

# Commit with heredoc for multi-line
git commit -m "$(cat <<'EOF'
feat(auth): add login endpoint

- Added POST /api/auth/login
- Created AuthService with password verification
- Added unit tests for authentication flow
EOF
)"

# Push (new branch)
git push -u origin $(git branch --show-current)

# Push (existing branch)
git push

# Push (after rebase)
git push --force-with-lease
```

## Push Types

| Situation | Command | Why |
|-----------|---------|-----|
| New branch | `git push -u origin branch` | Sets upstream tracking |
| Normal commits | `git push` | Standard push |
| After rebase | `git push --force-with-lease` | Safer than --force |

## Safety Checks

### Protected Branches

```bash
BRANCH=$(git branch --show-current)
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  echo "ERROR: Cannot push directly to $BRANCH"
  exit 1
fi
```

### Force Push Safety

Always use `--force-with-lease` instead of `--force`:
- Fails if remote has new commits you haven't seen
- Prevents accidentally overwriting others' work

## Constraints

**Banned:**
- `git add .` or `git add -A` without reviewing
- Committing secrets, credentials, API keys, .env files
- Amending commits that have been pushed
- `git push --force` (use `--force-with-lease` instead)
- Pushing directly to main/master

**Required:**
- Conventional commit format: `type(scope): description`
- Selective file staging
- Multi-line body for non-trivial changes (3+ files or logic changes)
- Use `-u` flag for new branches
- Use `--force-with-lease` after rebase/amend

## Success Criteria

- [ ] Commit uses `type(scope): description` format
- [ ] Only relevant files staged
- [ ] No secrets or sensitive files committed
- [ ] Multi-line body for complex changes
- [ ] Not pushing to protected branch
- [ ] Using `-u` flag for new branches
- [ ] Using `--force-with-lease` (not `--force`) if needed
- [ ] Push completed successfully
