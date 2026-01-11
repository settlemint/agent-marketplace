---
name: crew:git:pr:update
description: Update PR title, body, and machete annotations
argument-hint: "[PR number, defaults to current branch PR]"
allowed-tools:
  - Bash
---

<pr_info>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gh-pr-info.sh 2>&1`
</pr_info>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>

Update PR title/body from commits. Update machete annotations if stacked.

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

Select template based on commit type. Sources:

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

## Step 6: Update Machete (if stacked)

If `<stack_context>` shows "is in machete layout":

```bash
if git machete is-managed "$(git branch --show-current)" 2>/dev/null; then
  git config machete.github.prDescriptionIntroStyle full
  git machete github anno-prs
  git machete github update-pr-descriptions --related
fi
```

</workflow>

<success_criteria>

- [ ] PR title reflects commit type and scope
- [ ] PR body generated from template
- [ ] Plan context included (if exists)
- [ ] Machete annotations updated (if stacked)

</success_criteria>
