---
name: crew:git:butler:commit
description: Commit changes using GitButler MCP or CLI with conventional format
argument-hint: "[--branch <name>] [commit message]"
allowed-tools:
  - Bash
  - AskUserQuestion
  - mcp__gitbutler__gitbutler_update_branches
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<objective>

Commit changes using GitButler. When a target branch is specified, explicitly assign files to that branch before committing. This preserves parallel work while ensuring changes go to the correct branch.

</objective>

<workflow>

## Step 1: Check GitButler Active

```javascript
if (GITBUTLER_ACTIVE === false) {
  // Output: "GitButler is not initialized. Use regular git or run: but init"
  // Exit
}
```

## Step 2: Parse Arguments

```javascript
// Parse optional --branch argument
const targetBranch = args.includes("--branch")
  ? args.split("--branch")[1].trim().split(" ")[0]
  : null;
const commitMessage = args.replace(/--branch\s+\S+/, "").trim();
```

## Step 3: Get Modified Files and Branches

```javascript
// Get list of modified/staged files
const modifiedFiles = Bash({
  command: "git status --porcelain | awk '{print $2}'",
});

// Get available branches
const branches = Bash({ command: "but branch list" });
```

## Step 4: Assign Files to Target Branch (if specified)

**When a target branch is specified, assign ALL modified files to that branch:**

```javascript
if (targetBranch) {
  // Verify branch exists
  if (!branches.includes(targetBranch)) {
    AskUserQuestion({
      questions: [
        {
          question: `Branch "${targetBranch}" not found. Create it?`,
          header: "Branch",
          options: [
            { label: "Create branch", description: `Create ${targetBranch}` },
            { label: "Choose existing", description: "Pick from list" },
          ],
          multiSelect: false,
        },
      ],
    });

    if (createNew) {
      Bash({ command: `but branch new "${targetBranch}"` });
    }
  }

  // Assign each modified file to target branch
  for (const file of modifiedFiles) {
    Bash({ command: `but rub "${file}" "${targetBranch}"` });
  }
}
```

## Step 5: Verify Assignment (if no target specified)

If no target branch specified, verify the active branch is correct:

```javascript
if (!targetBranch) {
  const activeBranch = parseActiveBranch(branches); // Branch marked with *

  AskUserQuestion({
    questions: [
      {
        question: `Changes will be committed. Active branch is "${activeBranch}". Correct?`,
        header: "Confirm",
        options: [
          { label: "Yes, commit", description: "Proceed with commit" },
          { label: "Assign to different branch", description: "Choose branch" },
        ],
        multiSelect: false,
      },
    ],
  });

  if (chooseDifferent) {
    // Show branch picker and assign files
    for (const file of modifiedFiles) {
      Bash({ command: `but rub "${file}" "${selectedBranch}"` });
    }
  }
}
```

## Step 6: Check for Sensitive Files

```javascript
Bash({
  command:
    "git status --porcelain | grep -E '\\.(env|pem|key)$|credentials|secrets' || true",
});
// If matches found, warn: "⚠️ Sensitive files detected - review before committing"
```

## Step 7: Commit Using MCP (Preferred for AI workflows)

Use the GitButler MCP tool to commit:

```javascript
mcp__gitbutler__gitbutler_update_branches({
  fullPrompt: "The original user request that led to these changes",
  changesSummary: "- Added X\n- Modified Y\n- Fixed Z",
  currentWorkingDirectory: "/path/to/project",
});
```

The MCP tool will:

- Commit changes to their assigned branches
- Generate semantic commit messages
- Handle the commit workflow automatically

## Step 8: Alternative - CLI Commit (Manual)

If MCP not available or for manual control:

```javascript
Bash({
  command: `but commit -m "${commitMessage || "type(scope): description"}"`,
});
```

Or let GitButler AI-generate the message:

```javascript
Bash({ command: "but commit" });
```

## Step 9: Confirm

```javascript
Bash({ command: "but branch list" });
```

</workflow>

<commit_format>

Use conventional commit format:

```
type(scope): description
```

| Type     | Use For       |
| -------- | ------------- |
| feat     | New feature   |
| fix      | Bug fix       |
| refactor | Code change   |
| docs     | Documentation |
| chore    | Maintenance   |

</commit_format>

<success_criteria>

- [ ] Target branch identified (explicit or confirmed)
- [ ] Files assigned to correct branch (if target specified)
- [ ] No sensitive files committed
- [ ] Conventional format used
- [ ] Commit created successfully

</success_criteria>
