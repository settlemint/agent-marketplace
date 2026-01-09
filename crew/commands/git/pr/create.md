---
name: crew:git:pr:create
description: Commit, push, and open a PR
allowed-tools:
  - Bash
  - AskUserQuestion
  - Skill
  - Read
---

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<pr_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/pr-context.sh 2>&1`
</pr_context>

<objective>

Stage, commit, ask PR options (stacking, draft, auto-merge), create PR, update annotations.

</objective>

<workflow>

## Step 1: Check State

```bash
git branch --show-current && git status --short
```

If on main → create feature branch first.

## Step 2: Stage and Commit

```bash
git add . && git commit -m "type(scope): msg"
```

## Step 3: Ask Stacking (if not machete-managed)

If `<stack_context>` shows "is NOT in machete layout":

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Add this branch to a stack?",
      header: "Stacking",
      options: [
        {
          label: "No (Recommended)",
          description: "Standalone PR against main",
        },
        { label: "Stack on parent", description: "Add to machete stack" },
      ],
      multiSelect: false,
    },
  ],
});
```

If stacking selected:

```bash
git machete add $(git branch --show-current) --onto <selected-parent>
```

## Step 4: Ask PR Options

```javascript
AskUserQuestion({
  questions: [
    {
      question: "PR type?",
      header: "Type",
      options: [
        {
          label: "Ready for review (Recommended)",
          description: "Ready to merge",
        },
        { label: "Draft", description: "Work in progress" },
      ],
      multiSelect: false,
    },
    {
      question: "Enable auto-merge?",
      header: "Auto-merge",
      options: [
        { label: "No", description: "Manual merge required" },
        {
          label: "Yes",
          description: "Auto-merge with squash when checks pass",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 5: Generate PR Body

Select template based on commit type:

- `feat` → `skills/git/templates/pr-feature.md`
- `fix` → `skills/git/templates/pr-fix.md`
- `refactor/docs/test` → `skills/git/templates/pr-refactor.md`
- Other → `skills/git/templates/pr-default.md`

Check for plan file: `ls .claude/plans/*.md 2>/dev/null`
If exists, extract motivation and design decisions.

## Step 6: Create PR

**If machete-managed:**

```bash
git machete github create-pr [--draft]
git machete github anno-prs
```

**If traditional:**

```bash
git push -u origin $(git branch --show-current)
gh pr create --title "type(scope): description" --body "..." [--draft]
```

## Step 7: Enable Auto-merge (if selected)

```bash
PR_NUM=$(gh pr view --json number -q '.number')
gh pr merge $PR_NUM --auto --squash
```

## Step 8: Update PR Annotations

```javascript
Skill({ skill: "crew:git:pr:update" });
```

Return PR URL.

</workflow>

<success_criteria>

- [ ] Changes committed
- [ ] Stacking configured (if selected)
- [ ] PR created (draft or ready)
- [ ] Auto-merge enabled (if selected)
- [ ] Machete annotations updated (if stacked)

</success_criteria>
