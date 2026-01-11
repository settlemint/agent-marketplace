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

If `GITBUTLER_ACTIVE=false`:

```
GitButler is not initialized in this repository.

To initialize: but init --target-branch origin/main
```

## Step 2: Show Virtual Branches

```bash
but branch list
```

## Step 3: Show Base Status

```bash
but base check
```

## Step 4: Check for Stale Branches

```bash
# Count stale branches (0 commits ahead)
STALE_COUNT=$(but branch -j | jq '[.branches[] | select(.commitsAhead == 0)] | length')
```

If stale branches found, highlight them:

```
⚠️ Found ${STALE_COUNT} stale branch(es) (0 commits ahead).
   These have been merged and can be cleaned up.
   Run: crew:git:butler:cleanup
```

## Step 5: Suggest Actions

Based on output:

| Situation                | Suggestion                              |
| ------------------------ | --------------------------------------- |
| Upstream ahead           | Run `crew:git:butler:sync` to rebase    |
| Uncommitted changes      | Run `crew:git:butler:commit`            |
| Branch ready             | Run `crew:git:butler:push`              |
| Conflicts detected       | Edit files, then commit resolution      |
| **Stale branches exist** | Run `crew:git:butler:cleanup` to remove |

</workflow>

<success_criteria>

- [ ] Virtual branches listed
- [ ] Base status shown
- [ ] Stale branches highlighted if any
- [ ] Actions suggested for current state

</success_criteria>
