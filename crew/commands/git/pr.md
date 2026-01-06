---
name: crew:git:pr
description: Commit, push, and open a PR
allowed-tools: Bash(git checkout:*), Bash(git add:*), Bash(git status:*), Bash(git push:*), Bash(git commit:*), Bash(git fetch:*), Bash(gh pr create:*), Bash(git machete:*), AskUserQuestion
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/git/pr-context.sh`
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`

## PR Template

```markdown
## Summary

<2-3 bullets>

## Test plan

- [ ] <verification>
```

## Task

### Step 1: Check Git State

```bash
git branch --show-current
git status --short
```

### Step 2: Handle Branch (if on main/master)

If on main/master, create feature branch:

```bash
git checkout -b feat/<name>
```

### Step 3: Stage & Commit

```bash
git add . && git commit -m "type(scope): msg"
```

### Step 4: Ask PR Type

Use AskUserQuestion to ask if this should be a draft PR or ready for review:

- **Draft PR** - Work in progress, not ready for review
- **Ready PR** - Ready for review and merge

### Step 5: Check Machete Status

**If branch is in machete layout** (`.git/machete` exists and branch is managed):

```bash
# Use git-machete for PR creation - uses parent from layout as base
# Add --draft if user selected draft PR
git machete github create-pr [--draft]
```

**If NOT in machete layout** (traditional PR):

```bash
# Push branch
git push -u origin $(git branch --show-current)

# Create PR with HEREDOC body
# Add --draft if user selected draft PR
gh pr create --title "..." --body "$(cat <<'EOF'
## Summary
...
EOF
)" [--draft]
```

### Step 6: Sync Stack (if machete)

If branch is in a stack, sync after PR creation:

```bash
git machete github anno-prs  # Add PR numbers to status
git machete status           # Show updated stack
```

## Machete Benefits

When using git-machete for PRs:

- Automatically uses parent branch from layout as PR base
- Adds PR chain description for stacked PRs
- Enables easy retargeting with `git machete github retarget-pr`

## Quick Reference

```bash
# Traditional PR (add --draft based on user choice)
gh pr create --title "feat: thing" --body "..." [--draft]

# Machete-managed PR (add --draft based on user choice)
git machete github create-pr [--draft]
```

Return the PR URL when done.
