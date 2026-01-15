---
name: pr-create
description: Create pull request with smart defaults
---

<context>
!`${SKILL_ROOT}/scripts/context.sh pr`
</context>

<objective>
Stage, commit, push, create PR. Smart defaults: ready for review, no auto-merge.
</objective>

<workflow>

1. **Check state:** If on main, create feature branch first
2. **Stage and commit:** If uncommitted changes, use conventional format
3. **Smart QA:** If QA stale, run `bun run ci` and update timestamp
4. **Push:** `git push -u origin $(git branch --show-current)`
5. **Generate PR body:** Read `templates/pr-body.md`, fill from commits/plan
6. **Create PR:** `gh pr create --title "type(scope): summary" --body "..."`

</workflow>

<pr_body_generation>

Select sections based on primary commit type (see `templates/pr-body.md`).

**Context sources:**

- Commits: `git log origin/main..HEAD --oneline`
- Plan: `ls .claude/plans/*.md 2>/dev/null` (extract motivation, design)
- Changes: `git diff --stat origin/main`

</pr_body_generation>

<commands>

```bash
# Push
git push -u origin $(git branch --show-current)

# Create PR (ready for review)
gh pr create --title "feat(scope): description" --body "$(cat <<'EOF'
## Summary
...

## Why
...

## What changed
...

## How to test
...
EOF
)"

# Create draft PR
gh pr create --draft --title "..." --body "..."

# Enable auto-merge (if requested)
gh pr merge $(gh pr view --json number -q '.number') --auto --squash
```

</commands>

<success_criteria>

- [ ] Changes committed (conventional format)
- [ ] QA passed (or fresh)
- [ ] PR created with meaningful description

</success_criteria>
