---
name: crew:git:pr:update
description: Update PR title and body
argument-hint: "[PR number, defaults to current branch PR]"
model: haiku
allowed-tools:
  - Bash
---

<pr_info>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh 2>&1`
</pr_info>

<objective>

Update PR title/body from commits.

</objective>

<workflow>

## Step 1: Validate PR

If no PR found → exit.

## Step 2: Gather Context

```bash
BASE=$(gh pr view --json baseRefName -q '.baseRefName')
git log origin/${BASE}..HEAD --pretty=format:"%s" | head -20
ls .claude/plans/*.md 2>/dev/null
```

## Step 3: Generate Title

- Single commit → use commit message
- Multiple commits → `type(scope): summary`
- Mixed types → use most significant (feat > fix > refactor > docs > chore)

## Step 4: Generate Body

Select and read template based on commit type:

```javascript
// Determine template based on primary commit type
const templateMap = {
  feat: "pr-feature.md",
  fix: "pr-fix.md",
  refactor: "pr-refactor.md",
  docs: "pr-refactor.md",
  test: "pr-refactor.md",
  chore: "pr-refactor.md",
};
const template = templateMap[commitType] || "pr-default.md";
Read({
  file_path: `${CLAUDE_PLUGIN_ROOT}/skills/git/templates/${template}`,
});
```

Sources:

- **Summary**: From commit messages
- **Why**: From plan file or commit bodies
- **What changed**: From `git diff --stat`

Add visuals (ASCII/Mermaid) when helpful for reviewer.

## Step 5: Update PR

```bash
PR_NUM=$(gh pr view --json number -q '.number')
gh pr edit $PR_NUM --title "type(scope): description"
gh pr edit $PR_NUM --body "..."
```

</workflow>

<success_criteria>

- [ ] PR title reflects commit type and scope
- [ ] PR body generated from template
- [ ] Plan context included (if exists)

</success_criteria>
