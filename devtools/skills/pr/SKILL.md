---
name: pr
description: Create a pull request with smart defaults. Use when asked to "create PR", "open pull request", or "submit for review".
license: MIT
user_invocable: true
argument-hint: "[optional PR title]"
triggers:
  - "create pr"
  - "open pr"
  - "pull request"
  - "submit for review"
---

<objective>
Create a pull request: stage, commit, push, and open PR with meaningful description. Smart defaults: ready for review, no auto-merge.
</objective>

<quick_start>

1. **Check state:** If on main, create feature branch first
2. **Stage and commit:** If uncommitted changes, use conventional format
3. **Smart QA:** If QA stale (>5 min), run `bun run ci`
4. **Push:** `git push -u origin $(git branch --show-current)`
5. **Create PR:** `gh pr create --title "..." --body "..."`

</quick_start>

<workflow>

**Step 1: Verify branch**

```bash
BRANCH=$(git branch --show-current)
[[ "$BRANCH" == "main" || "$BRANCH" == "master" ]] && echo "Create feature branch first!"
```

**Step 2: Commit any pending changes**

```bash
git status
git add <relevant-files>
git commit -m "feat(scope): description"
```

**Step 3: Check QA freshness**

```bash
QA_FILE=".claude/state/qa-timestamp"
if [[ -f "$QA_FILE" ]]; then
    AGE=$(($(date +%s) - $(cat "$QA_FILE")))
    [[ $AGE -lt 300 ]] && echo "QA fresh" || echo "Run: bun run ci"
fi
```

**Step 4: Push**

```bash
git push -u origin $(git branch --show-current)
```

**Step 5: Create PR**

```bash
gh pr create --title "feat(scope): description" --body "$(cat <<'EOF'
## Summary
Brief description of what this PR does.

## Why
Motivation for the change.

## What changed
- Change 1
- Change 2

## How to test
1. Step to verify
2. Expected result
EOF
)"
```

</workflow>

<pr_templates>

**Feature PR:**
```markdown
## Summary
[What does this add?]

## Why
[Motivation/user story]

## What changed
- [List of changes]

## How to test
1. [Test steps]
```

**Bug Fix PR:**
```markdown
## Summary
Fixes #[issue-number]

## Root cause
[What caused the bug]

## Fix
[How it was fixed]

## How to test
1. [Reproduction steps - should now work]
```

</pr_templates>

<constraints>

**Banned:**
- Creating PR from main/master branch
- PRs without meaningful description
- Pushing without QA check

**Required:**
- Feature branch
- Conventional commit format
- PR body with summary and test plan

</constraints>

<success_criteria>

1. [ ] Not on main/master branch
2. [ ] Changes committed (conventional format)
3. [ ] QA passed (or fresh)
4. [ ] PR created with meaningful description

</success_criteria>
