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

```javascript
if (GITBUTLER_ACTIVE === false) {
  // Output: "GitButler is not initialized. Run: but init --target-branch origin/main"
  // Exit
}
```

## Step 2: Get Branch Name

If argument provided, use it directly as the branch name.

If no argument provided, generate a descriptive name:

```javascript
// Analyze context - what task is the user working on?
// Create a clear name using this format:
const branchName = `${type}/${shortDescriptiveName}`;

// Examples:
// - feat/add-gitbutler-detection
// - fix/branch-creation-conflict
// - refactor/simplify-hook-logic
// - chore/update-dependencies
```

**Naming rules:**

- Use kebab-case (lowercase with hyphens)
- Max 40 characters total
- Be specific but concise
- No user prefix (GitButler manages ownership differently)

## Step 3: Create Branch

```javascript
Bash({ command: `but branch new "${branchName}"` });
```

## Step 4: Verify Branch is Active

**CRITICAL:** After creating, MUST verify the new branch is now active.

```javascript
const result = Bash({ command: "but branch list" });
// Parse to find active branch (marked with *)
// If the new branch is NOT active, something went wrong
if (!result.includes(`*${branchName}`)) {
  // Output: "⚠️ Warning: ${branchName} was created but is NOT active!"
  // Output: "The active branch is still: ${currentActive}"
  // Output: "Commits will go to the wrong branch. Apply the new branch first."
  Bash({ command: `but branch apply "${branchName}"` });
}
```

## Step 5: Confirm

```javascript
Bash({ command: "but branch list" });
```

Show the new branch and verify:

- The new branch is now **active** (commits will go here)
- Changes are auto-assigned based on rules
- Use `but rub FILE BRANCH` to manually assign files
- Use `crew:git:butler:commit` when ready to commit

</workflow>

<success_criteria>

- [ ] Virtual branch created
- [ ] Branch appears in list as active
- [ ] User informed about next steps

</success_criteria>
