---
name: crew:git:butler:status
description: Show GitButler virtual branches and base status
allowed-tools:
  - Bash
  - AskUserQuestion
  - Skill
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<objective>

Show virtual branch status and upstream integration state. Suggest actions for common situations.

</objective>

<workflow>

## Step 1: Check GitButler Active

```javascript
if (GITBUTLER_ACTIVE === false) {
  // Output: "GitButler is not initialized in this repository."
  // Output: "To initialize: but init --target-branch origin/main"
  // Exit
}
```

## Step 2: Show Virtual Branches

```javascript
Bash({ command: "but branch list" });
```

## Step 3: Show Base Status

```javascript
Bash({ command: "but base check" });
```

## Step 4: Check for Stale Branches

```javascript
const result = Bash({
  command:
    "but branch -j | jq '[.branches[] | select(.commitsAhead == 0)] | length'",
});
const staleCount = parseInt(result.trim(), 10);

if (staleCount > 0) {
  // Output: "⚠️ Found ${staleCount} stale branch(es) (0 commits ahead)."
  // Output: "   These have been merged and can be cleaned up."
  // Output: "   Run: crew:git:butler:cleanup"
}
```

## Step 5: Suggest Actions

Based on output, suggest appropriate next steps:

| Situation                | Suggestion                                    |
| ------------------------ | --------------------------------------------- |
| Upstream ahead           | `Skill({ skill: "crew:git:butler:sync" })`    |
| Uncommitted changes      | `Skill({ skill: "crew:git:butler:commit" })`  |
| Branch ready             | `Skill({ skill: "crew:git:butler:push" })`    |
| Conflicts detected       | Edit files, then commit resolution            |
| **Stale branches exist** | `Skill({ skill: "crew:git:butler:cleanup" })` |

</workflow>

<success_criteria>

- [ ] Virtual branches listed
- [ ] Base status shown
- [ ] Stale branches highlighted if any
- [ ] Actions suggested for current state

</success_criteria>
