---
name: crew:git:push
description: Push current branch to origin
allowed-tools:
  - Bash
  - Skill
---

<push_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/push-context.sh 2>&1`
</push_context>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<objective>

Sync with parent (if machete-managed), push to origin, update PR.

</objective>

<workflow>

## Step 1: Sync Stack (if machete-managed)

```bash
if git machete is-managed "$(git branch --show-current)" 2>/dev/null; then
  git fetch origin
  git machete update
fi
```

## Step 2: Push

```bash
git push -u origin $(git branch --show-current)
```

If rejected → `git pull --rebase` first, then retry.
If machete-managed and needs force → `git push --force-with-lease`

## Step 3: Update PR

```javascript
Skill({ skill: "crew:git:pr:update" });
```

</workflow>

<success_criteria>

- [ ] Branch pushed to origin
- [ ] PR updated (if exists)

</success_criteria>
