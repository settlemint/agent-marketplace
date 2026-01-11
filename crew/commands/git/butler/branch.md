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

If argument provided, use it directly as the branch name.

If no argument provided, generate a descriptive name:

1. **Analyze the context** - What task is the user working on?
2. **Create a clear name** using this format:

```
{type}/{short-descriptive-name}

Examples:
- feat/add-gitbutler-detection
- fix/branch-creation-conflict
- refactor/simplify-hook-logic
- chore/update-dependencies
```

**Naming rules:**

- Use kebab-case (lowercase with hyphens)
- Max 40 characters total
- Be specific but concise
- No user prefix (GitButler manages ownership differently)

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
