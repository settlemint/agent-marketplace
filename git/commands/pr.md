---
name: pr
description: Create pull request with template-based body
argument-hint: [--draft] [--auto-merge]
---

Create a pull request with smart template selection based on commit type.

## Current State

```bash
git branch --show-current
git log origin/main..HEAD --oneline
git diff --stat origin/main
```

## Workflow

### Step 1: Verify State

```bash
BRANCH=$(git branch --show-current)
[[ "$BRANCH" == "main" || "$BRANCH" == "master" ]] && echo "ERROR: Create feature branch first with /branch"
```

If on main → stop and instruct to use `/branch` first.

### Step 2: Stage and Commit

If uncommitted changes exist, use `/commit` workflow first.

### Step 3: Push Branch

```bash
git push -u origin $(git branch --show-current)
```

### Step 4: Determine PR Type

Ask user for PR type:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "PR type?",
      header: "Type",
      options: [
        { label: "Ready for review", description: "Ready to merge when approved" },
        { label: "Ready + auto-squash", description: "Ready for review, auto-merge with squash when checks pass" },
        { label: "Draft", description: "Work in progress, not ready for review" }
      ],
      multiSelect: false
    }
  ]
})
```

**If "Ready + auto-squash" selected:** Skip to Step 5 (auto-merge will be enabled in Step 8).

**Otherwise**, ask about auto-merge:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Enable auto-merge?",
      header: "Auto-merge",
      options: [
        { label: "No", description: "Manual merge required after approval" },
        { label: "Yes (squash)", description: "Auto-merge with squash when checks pass" }
      ],
      multiSelect: false
    }
  ]
})
```

### Step 5: Select Template

Determine primary commit type from first commit:

```bash
PRIMARY_TYPE=$(git log origin/main..HEAD --format="%s" | head -1 | cut -d'(' -f1)
```

| Commit Type | Template |
|-------------|----------|
| `feat` | `templates/pr-feature.md` |
| `refactor`, `docs`, `chore`, `test` | `templates/pr-refactor.md` |
| `fix`, other | `templates/pr-body.md` |

### Step 6: Generate PR Body

Read template from `skills/using-git/templates/` and fill placeholders:

- `{{SUMMARY}}` - Brief description from commits
- `{{COMMITS}}` - List of commits
- `{{FILES_CHANGED}}` - Files modified
- `{{WHY}}` - Motivation (extract from plan file if exists)
- `{{PLAN}}` - Full implementation plan (for verification)

**Find and include the plan:**

```bash
# Find most recent plan file
PLAN_FILE=$(ls -t ~/.claude/plans/*.md 2>/dev/null | head -1)

if [[ -n "$PLAN_FILE" ]]; then
  PLAN_CONTENT=$(cat "$PLAN_FILE")
fi
```

**IMPORTANT:** If a plan file exists, include the FULL plan content in the PR description under a collapsible "Implementation Plan" section. This allows reviewers to verify the implementation matches the plan.

```markdown
<details>
<summary>Implementation Plan</summary>

[Full plan content here]

</details>
```

### Step 7: Create PR

```bash
# Ready for review
gh pr create --title "type(scope): description" --body "$(cat <<'EOF'
[filled template]
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
