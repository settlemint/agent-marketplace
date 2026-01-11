---
name: crew:git:butler:branch
description: Create a new GitButler virtual branch
argument-hint: "[branch name]"
allowed-tools:
  - Bash
  - AskUserQuestion
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<objective>

Create a new virtual branch for parallel feature development.

</objective>

<workflow>

## Step 1: Check GitButler Active

If `GITBUTLER_ACTIVE=false`:

```
GitButler is not initialized. Run: but init --target-branch origin/main
```

Exit if not active.

## Step 2: Get Branch Name

If no argument provided, ask:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What type of branch?",
      header: "Type",
      options: [
        { label: "Feature (Recommended)", description: "New functionality" },
        { label: "Fix", description: "Bug fix" },
        { label: "Refactor", description: "Code improvement" },
        { label: "Chore", description: "Maintenance task" },
      ],
      multiSelect: false,
    },
  ],
});
```

Then generate name: `{type}-{description}` (kebab-case)

## Step 3: Create Branch

```bash
but branch new ${branchName}
```

## Step 4: Confirm

```bash
but branch list
```

Show the new branch and remind user:

- Changes are auto-assigned based on rules
- Use `but rub FILE BRANCH` to manually assign files
- Use `crew:git:butler:commit` when ready to commit

</workflow>

<success_criteria>

- [ ] Virtual branch created
- [ ] Branch appears in list
- [ ] User informed about next steps

</success_criteria>
