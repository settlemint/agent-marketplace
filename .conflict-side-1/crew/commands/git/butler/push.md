---
name: crew:git:butler:push
description: Push GitButler virtual branch to remote
argument-hint: "[branch name]"
allowed-tools:
  - Bash
  - AskUserQuestion
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<objective>

Push a virtual branch to remote, making it a normal Git branch for review.

</objective>

<workflow>

## Step 1: Check GitButler Active

If `GITBUTLER_ACTIVE=false`:

```
GitButler is not initialized. Use regular git push.
```

Exit if not active.

## Step 2: List Branches if No Argument

```bash
but branch list
```

If multiple branches, ask which to push:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which branch to push?",
      header: "Branch",
      options: branches.map((b) => ({
        label: b.name,
        description: `${b.commits} commits`,
      })),
      multiSelect: false,
    },
  ],
});
```

## Step 3: Push Branch

```bash
but push ${branchName}
```

## Step 4: Confirm and Next Steps

```bash
but branch list
```

Inform user:

- Branch is now on remote
- Create PR with `gh pr create` or `crew:git:pr:create`
- Or use `but publish` for GitButler's PR creation

</workflow>

<success_criteria>

- [ ] Branch pushed to remote
- [ ] User informed about PR creation options

</success_criteria>
