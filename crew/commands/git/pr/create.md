---
name: crew:git:pr:create
description: Commit, push, and open a PR
model: haiku
allowed-tools:
  - Bash
  - AskUserQuestion
  - Skill
  - Read
---

<pr_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/pr-context.sh 2>&1`
</pr_context>

<objective>

Stage, commit, ask PR options (draft, auto-merge), create PR.

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

## Step 3: Ask PR Options

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

## Step 4: Generate PR Body

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

Check for plan file: `ls .claude/plans/*.md 2>/dev/null`
If exists, extract motivation and design decisions.

## Step 5: Create PR

```bash
git push -u origin $(git branch --show-current)
gh pr create --title "type(scope): description" --body "..." [--draft]
```

## Step 6: Enable Auto-merge (if selected)

```bash
PR_NUM=$(gh pr view --json number -q '.number')
gh pr merge $PR_NUM --auto --squash
```

## Step 7: Update PR Annotations

```javascript
Skill({ skill: "crew:git:pr:update" });
```

Return PR URL.

</workflow>

<success_criteria>

- [ ] Changes committed
- [ ] PR created (draft or ready)
- [ ] Auto-merge enabled (if selected)

</success_criteria>
