---
name: commit-push
description: Create conventional commit and push to remote
argument-hint: [message hint]
---

Create a conventional commit and push to remote. This command delegates to `/commit` and `/push` for single responsibility.

## Context

```bash
! git branch --show-current
! git status --short
! git log origin/$(git branch --show-current 2>/dev/null)..HEAD --oneline 2>/dev/null || echo "New branch"
```

## Workflow

### Step 1: Commit Changes

Delegate to commit command:

```javascript
Skill({ skill: "commit", args: "$ARGUMENTS" })
```

This will:
- Stage all changes with `git add -A`
- Check for sensitive files
- Create conventional commit with proper message

### Step 2: Push to Remote

Delegate to push command:

```javascript
Skill({ skill: "push" })
```

This will:
- Verify not on protected branch
- Push with `-u` flag for new branches
- Auto-retry with rebase if rejected

## Manual Fallback

If skills are not available, execute directly:

```bash
# Stage all changes
git add -A

# Commit
git commit -m "$(cat <<'EOF'
type(scope): description

- Change details
EOF
)"

# Push
BRANCH=$(git branch --show-current)
git push -u origin "$BRANCH" || git push
```

## Constraints

**Banned:**
- Skipping the commit step
- Pushing directly to main/master
- Using `--force` instead of `--force-with-lease`

**Required:**
- Use `/commit` for commit logic (single responsibility)
- Use `/push` for push logic (single responsibility)
- Follow conventional commit format

## Success Criteria

- [ ] All changes staged and committed
- [ ] Commit uses conventional format
- [ ] No secrets committed
- [ ] Push completed successfully
- [ ] Both `/commit` and `/push` workflows followed
