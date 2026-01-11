---
name: crew:git:butler:commit
description: Commit changes using GitButler MCP (preferred) or CLI
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

Commit changes using GitButler. **ALWAYS prefer the MCP tool** - it handles file assignment automatically and avoids ephemeral ID issues with `but rub`.

</objective>

<critical_warning>

**ALWAYS USE MCP TOOL FOR COMMITS**

The MCP tool (`mcp__gitbutler__gitbutler_update_branches`) is the preferred method because:

1. It handles file assignment automatically
2. It avoids ephemeral ID issues with `but rub`
3. It generates semantic commit messages

**NEVER use loops with `but rub`** - the short IDs (g0, m1, etc.) change after every operation, causing subsequent commands to fail.

</critical_warning>

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
const branchMatch = args?.match(/--branch\s+(\S+)/);
const targetBranch = branchMatch ? branchMatch[1] : null;
const commitMessage = args?.replace(/--branch\s+\S+/, "").trim() || null;
```

## Step 3: Ensure Target Branch is Active (if specified)

If a target branch is specified, verify it exists and is active:

```javascript
if (targetBranch) {
  // Check if branch exists
  const branchList = Bash({ command: "but branch list" });

  if (!branchList.includes(targetBranch)) {
    // Create the branch if it doesn't exist
    Bash({ command: `but branch new "${targetBranch}"` });
  }

  // Verify the target branch is active (marked with *)
  const status = Bash({ command: "but status" });
  // If target branch is not active, the MCP tool will commit to wrong branch
  // Warn user and suggest creating/activating the branch
}
```

## Step 4: Verify Active Branch

Check which branch will receive the commit:

```javascript
Bash({ command: "but status" });
// Look for branch marked with * - that's where commits go
// If wrong branch, create a new one:
// Bash({ command: "but branch new feat/correct-branch" });
```

## Step 3: Check for Sensitive Files

```javascript
Bash({
  command:
    "git status --porcelain | grep -E '\\.(env|pem|key)$|credentials|secrets' || true",
});
// If matches found, warn: "⚠️ Sensitive files detected - review before committing"
```

## Step 4: Commit Using MCP (PREFERRED)

**This is the recommended approach:**

```javascript
mcp__gitbutler__gitbutler_update_branches({
  fullPrompt: "The original user request that led to these changes",
  changesSummary: "- Added X\n- Modified Y\n- Fixed Z",
  currentWorkingDirectory: "/path/to/project",
});
```

The MCP tool will:

- Assign changes to the active branch automatically
- Generate semantic commit messages
- Handle the entire commit workflow

## Step 5: Alternative - CLI Commit

Only if MCP is not available:

```javascript
Bash({ command: `but commit -m "type(scope): description"` });
```

Or let GitButler AI-generate the message:

```javascript
Bash({ command: "but commit" });
```

## Step 6: Confirm

```javascript
Bash({ command: "but status" });
```

</workflow>

<manual_assignment_warning>

**If you must manually assign files (NOT RECOMMENDED):**

The short IDs in `but status` are **ephemeral** - they change after EVERY operation.

```bash
# WRONG - Will fail after first rub
but rub g0 branch && but rub m0 branch

# CORRECT - One at a time with status refresh
but status           # Get IDs
but rub g0 branch    # Assign one
but status           # Get NEW IDs (they changed!)
but rub h0 branch    # Use new ID
```

**Just use the MCP tool instead - it's much simpler.**

</manual_assignment_warning>

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
- [ ] MCP tool used (preferred) or CLI as fallback
- [ ] Commit created successfully

</success_criteria>
