---
name: crew:git:commit-and-push
description: Create a conventional commit and push to origin
argument-hint: "[--branch <name>] [commit message]"
allowed-tools:
  - Skill
---

<commit_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/commit-context.sh 2>&1`
</commit_context>

<objective>

Commit changes and push. Delegates to crew:git:commit and crew:git:push. Passes through --branch argument for GitButler support.

</objective>

<workflow>

## Step 1: Commit

```javascript
// Pass through args (including --branch for GitButler)
Skill({ skill: "crew:git:commit", args: args });
```

## Step 2: Push

```javascript
// Extract branch name if provided, pass to push
const branchMatch = args?.match(/--branch\s+(\S+)/);
const branchArg = branchMatch ? branchMatch[1] : "";
Skill({ skill: "crew:git:push", args: branchArg });
```

</workflow>

<success_criteria>

- [ ] Changes committed
- [ ] Branch pushed

</success_criteria>
