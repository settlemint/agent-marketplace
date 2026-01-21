---
name: push
description: Push commits to remote safely
argument-hint: [--force-with-lease]
---

Push commits to remote with safety checks and auto-retry.

## Context

```bash
! git branch --show-current
! git status --short
! git log origin/$(git branch --show-current 2>/dev/null)..HEAD --oneline 2>/dev/null || echo "New branch or no upstream"
```

## Workflow

1. **Check uncommitted changes** - Warn if working directory is dirty
2. **Verify not on protected branch** - Block push to main/master
3. **Determine push type** - New branch vs existing, rebased vs normal
4. **Execute push** - With appropriate flags
5. **Auto-retry if rejected** - Fetch, rebase, push again

## Push Types

| Situation | Command | Why |
|-----------|---------|-----|
| New branch | `git push -u origin branch` | Sets upstream tracking |
| Normal commits | `git push` | Standard push |
| After rebase | `git push --force-with-lease` | Safer than --force |
| After amend | `git push --force-with-lease` | History rewritten |

## Commands

```bash
BRANCH=$(git branch --show-current)

# Block protected branches
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  echo "ERROR: Cannot push directly to $BRANCH"
  exit 1
fi

# New branch (set upstream)
git push -u origin "$BRANCH"

# Existing branch (normal push)
git push

# After rebase (force with lease for safety)
git push --force-with-lease
```

## Auto-Retry on Conflict

If push is rejected because remote has new commits:

```bash
BRANCH=$(git branch --show-current)

if ! git push; then
  git fetch origin "$BRANCH"
  if [ -n "$(git log HEAD..origin/$BRANCH --oneline 2>/dev/null)" ]; then
    echo "Remote has new commits. Rebasing..."
    git rebase "origin/$BRANCH"
    git push --force-with-lease
  fi
fi
```

## Constraints

**Banned:**
- `git push --force` (use `--force-with-lease` instead)
- Pushing directly to main/master
- Pushing with uncommitted changes (warn user)

**Required:**
- Use `-u` flag for new branches
- Use `--force-with-lease` after rebase/amend
- Verify not on protected branch

## Success Criteria

- [ ] Not pushing to protected branch
- [ ] Using `-u` flag for new branches
- [ ] Using `--force-with-lease` (not `--force`) if needed
- [ ] Auto-retry with rebase if push rejected
- [ ] Push completed successfully
