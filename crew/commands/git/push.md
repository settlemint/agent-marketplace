---
name: crew:git:push
description: Push current branch to origin
argument-hint: "[branch name]"
allowed-tools:
  - Bash
  - Skill
---

<push_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/push-context.sh 2>&1`
</push_context>

<objective>

Push to origin, update PR.

</objective>

<workflow>

## Step 1: Push

```bash
git push -u origin $(git branch --show-current)
```

If rejected → `git pull --rebase` first, then retry.

## Step 2: Update PR

```javascript
Skill({ skill: "crew:git:pr:update" });
```

</workflow>

<success_criteria>

- [ ] Branch pushed to origin
- [ ] PR updated (if exists)

</success_criteria>
