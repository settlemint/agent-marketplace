---
name: crew:git:undo
description: Undo last commit (keeps changes staged)
allowed-tools:
  - Bash
---

<undo_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/undo-context.sh`
</undo_context>

<objective>

Undo last commit, keeping changes staged. STOP if already pushed.

</objective>

<workflow>

## Step 1: Check Safety

If `<undo_context>` shows "COMMIT ALREADY PUSHED" → STOP. Requires force-push.

## Step 2: Undo Commit

```bash
git reset --soft HEAD~1
git status
```

</workflow>

<recovery>

```bash
git reflog  # find SHA
git cherry-pick <sha>
```

</recovery>

<success_criteria>

- [ ] Commit undone (changes remain staged)

</success_criteria>
