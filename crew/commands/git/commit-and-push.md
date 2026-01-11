---
name: crew:git:commit-and-push
description: Create a conventional commit and push to origin
argument-hint: "[commit message]"
model: haiku
allowed-tools:
  - Skill
---

<commit_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/commit-context.sh 2>&1`
</commit_context>

<objective>

Commit changes and push. Delegates to crew:git:commit and crew:git:push.

</objective>

<workflow>

## Step 1: Commit

```javascript
Skill({ skill: "crew:git:commit", args: args });
```

## Step 2: Push

```javascript
Skill({ skill: "crew:git:push" });
```

</workflow>

<success_criteria>

- [ ] Changes committed
- [ ] Branch pushed

</success_criteria>
