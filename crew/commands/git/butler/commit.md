---
name: crew:git:butler:commit
description: Commit changes using GitButler MCP or CLI with conventional format
argument-hint: "[commit message]"
allowed-tools:
  - Bash
  - AskUserQuestion
  - mcp__gitbutler__gitbutler_update_branches
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<objective>

Commit changes using GitButler. Prefer MCP tool for AI-driven workflows, CLI for manual commits.

</objective>

<workflow>

## Step 1: Check GitButler Active

If `GITBUTLER_ACTIVE=false`:

```
GitButler is not initialized. Use regular git or run: but init
```

Exit if not active.

## Step 2: Verify Active Branch

**CRITICAL:** MCP commits go to the currently ACTIVE branch (marked with `*`).

```bash
but branch list
# Look for the * marker to identify active branch
```

If the active branch is wrong for this commit:

```javascript
AskUserQuestion({
  questions: [
    {
      question: `Commits will go to "${activeBranch}". Is this correct?`,
      header: "Target Branch",
      options: [
        { label: "Yes, commit here", description: "Proceed with commit" },
        {
          label: "No, create new branch",
          description: "Create a new branch first",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

If user chooses new branch:

```bash
but branch new <feature-name>
# New branch is now active
```

## Step 3: Check for Sensitive Files

```bash
git status --porcelain | grep -E '\.(env|pem|key)$|credentials|secrets' && \
  echo "⚠️ Sensitive files detected - review before committing"
```

## Step 4: Commit Using MCP (Preferred for AI workflows)

Use the GitButler MCP tool to auto-commit changes with context:

```javascript
mcp__gitbutler__gitbutler_update_branches({
  fullPrompt: "The original user request that led to these changes",
  changesSummary: "- Added X\n- Modified Y\n- Fixed Z",
  currentWorkingDirectory: "/path/to/project",
});
```

The MCP tool will:

- Auto-assign changes to appropriate virtual branches
- Generate semantic commit messages
- Handle the commit workflow automatically

## Step 5: Alternative - CLI Commit (Manual)

If MCP not available or for manual control:

```bash
but commit -m "type(scope): description"
```

Or let GitButler AI-generate the message:

```bash
but commit
```

## Step 6: Confirm

```bash
but branch list
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

- [ ] Active branch verified before commit
- [ ] No sensitive files committed
- [ ] Conventional format used
- [ ] Commit created successfully

</success_criteria>
