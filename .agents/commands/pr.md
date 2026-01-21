---
name: pr
description: Create pull request with smart template
argument-hint: [--draft] [--auto-merge]
---

Create a pull request with smart template selection based on commit type.

## Context

```bash
! git branch --show-current
! git log origin/main..HEAD --oneline 2>/dev/null | head -10
! git diff --stat origin/main 2>/dev/null | tail -5
! git status --short
```

## Workflow

### Step 1: Verify State

```bash
BRANCH=$(git branch --show-current)
[[ "$BRANCH" == "main" || "$BRANCH" == "master" ]] && echo "ERROR: Create feature branch first with /branch"
```

If on main -> stop and instruct to use `/branch` first.

### Step 2: Stage and Commit

If uncommitted changes exist, use `/commit` workflow first.

### Step 3: Push Branch

```bash
git push -u origin $(git branch --show-current)
```

### Step 4: Determine PR Type

Ask user for PR type:
- **Ready for review** - Ready to merge when approved
- **Ready + auto-squash** - Auto-merge with squash when checks pass
- **Draft** - Work in progress, not ready for review

### Step 5: Select Template

Determine primary commit type from first commit:

```bash
PRIMARY_TYPE=$(git log origin/main..HEAD --format="%s" | head -1 | cut -d'(' -f1)
```

| Commit Type | Template Style |
|-------------|----------------|
| `feat` | Feature template (summary, motivation, changes) |
| `refactor`, `docs`, `chore`, `test` | Refactor template (what/why/impact) |
| `fix`, other | Fix template (problem, solution, testing) |

### Step 6: Generate PR Body

Fill template with:
- `{{SUMMARY}}` - Brief description from commits
- `{{COMMITS}}` - List of commits
- `{{FILES_CHANGED}}` - Files modified
- `{{WHY}}` - Motivation (extract from plan if exists)

Include implementation plan if available:

```bash
PLAN_FILE=$(ls -t ~/.claude/plans/*.md 2>/dev/null | head -1)
[[ -n "$PLAN_FILE" ]] && PLAN_CONTENT=$(cat "$PLAN_FILE")
```

### Step 7: Create PR

```bash
# Ready for review
gh pr create --title "type(scope): description" --body "$(cat <<'EOF'
## Summary
- Brief description of changes

## Changes
- List of changes made

## Test Plan
- [ ] Tests pass locally
- [ ] Manual testing completed
EOF
)"

# Draft PR
gh pr create --draft --title "..." --body "..."
```

### Step 8: Enable Auto-merge (if selected)

```bash
gh pr merge $(gh pr view --json number -q '.number') --auto --squash
```

### Step 9: Return URL

```bash
gh pr view --json url -q '.url'
```

## Constraints

**Banned:**
- Creating PR from main/master branch
- PRs without meaningful description
- Skipping template-based body

**Required:**
- Feature branch (not main/master)
- Conventional commit format in title
- PR body from appropriate template
- User confirmation for draft/auto-merge

## Success Criteria

- [ ] Not on main/master branch
- [ ] All changes committed
- [ ] Branch pushed to origin
- [ ] User confirmed PR options
- [ ] PR created with template body
- [ ] Auto-merge enabled (if selected)
- [ ] PR URL returned to user
