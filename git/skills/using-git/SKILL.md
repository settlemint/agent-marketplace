---
name: using-git
description: This skill should be used when the user asks to "create a commit", "make a branch", "open a PR", "push changes", "sync with main", "resolve merge conflicts", or when working with git operations, conventional commits, or version control workflows. Provides Git workflow conventions.
version: 1.0.0
---

## Overview

Git workflow conventions for consistent, safe version control operations. Covers conventional commits, branch naming, PR templates, and conflict resolution.

## Conventional Commits

Format: `type(scope): description`

| Type | Use When |
|------|----------|
| `feat` | New feature |
| `fix` | Bug fix |
| `docs` | Documentation only |
| `refactor` | Code change (no feature/fix) |
| `test` | Adding/updating tests |
| `chore` | Maintenance, deps, config |
| `perf` | Performance improvement |
| `style` | Formatting (no code change) |

**Examples:**
```
feat(auth): add JWT token refresh
fix(api): handle null response from payment gateway
docs(readme): update installation instructions
refactor(utils): extract date formatting to helper
test(auth): add integration tests for login flow
chore(deps): bump typescript to 5.3.0
```

**Multi-line format:**
```
type(scope): short description

- Bullet point explaining what changed
- Another bullet point if needed
- Reference issue: closes #123
```

## Branch Naming

Format: `username/type/slug`

| Component | Source | Rules |
|-----------|--------|-------|
| username | `whoami` | System username |
| type | feat/fix/hotfix/chore | Based on work type |
| slug | Description | kebab-case, max 30 chars |

**Examples:**
- `roderik/feat/user-authentication`
- `roderik/fix/null-pointer-login`
- `roderik/hotfix/critical-security`
- `roderik/chore/bump-dependencies`

## PR Templates

Select template based on primary commit type:

| Commit Type | Template | Focus |
|-------------|----------|-------|
| `feat` | pr-feature.md | Summary, Why, Design, Changes, Test |
| `refactor` | pr-refactor.md | Summary, Why, Changes, Impact |
| `fix`, other | pr-body.md | Summary, Why, Changes, Test |

Templates are in `templates/` directory.

## Merge vs Rebase

| Situation | Use | Why |
|-----------|-----|-----|
| Shared branch | Merge | Don't rewrite shared history |
| Solo feature | Rebase | Clean linear history |
| Already pushed | Merge | Avoid force push |
| Pre-push cleanup | Rebase | Squash/reorder commits |

## Conflict Resolution

| Pattern | Resolution |
|---------|------------|
| Version bumps | Keep higher version |
| Added vs deleted | Usually keep addition |
| Both modified | Combine based on intent |
| Import order | Alphabetical, include both |

**CRITICAL:** Remove ALL conflict markers before committing.

For detailed strategies, see `references/conflict-resolution.md`.

## Push Auto-Retry

When a push is rejected because remote has new commits:

1. **Fetch** latest from remote branch
2. **Rebase** local commits on top of remote
3. **Retry push** with `--force-with-lease`

This handles multi-agent scenarios where another Claude instance or collaborator pushed while you were working.

## Safety Rules

**Banned:**
- `git add .` without reviewing changes
- `git push --force` (use `--force-with-lease`)
- Pushing to main/master directly
- Committing secrets (.env, .pem, .key, credentials)
- Leaving conflict markers in files

**Required:**
- Conventional commit format
- Branch from origin/main (freshly fetched)
- Template-based PR descriptions
- Force-with-lease after rebase
- Auto-retry with rebase on push rejection

## Additional Resources

### Templates

- **`templates/pr-feature.md`** - Feature PR template
- **`templates/pr-refactor.md`** - Refactor PR template
- **`templates/pr-body.md`** - Default PR template (also used for fixes)

### References

- **`references/conflict-resolution.md`** - Detailed conflict handling
