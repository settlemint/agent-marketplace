---
name: crew:git:sync
description: Sync current branch with main
allowed-tools:
  - Bash
  - Skill
---

<sync_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/sync-context.sh`
</sync_context>

<objective>

Sync branch: rebase onto main. Push and update PR.

</objective>

<workflow>

## Step 1: Rebase onto main

```bash
git stash push -m "sync-stash" 2>/dev/null || true
git fetch origin main
git rebase origin/main
git stash pop 2>/dev/null || true
```

## Step 2: Update PR (if exists)

```bash
pr_number=$(gh pr view --json number -q '.number' 2>/dev/null || echo "")
if [[ -n "$pr_number" ]]; then
  git push --force-with-lease origin "$(git branch --show-current)"
fi
```

</workflow>

<on_conflict>

Report conflicting files. Do NOT auto-resolve. Tell user: `git rebase --continue` after fixing.

</on_conflict>

<success_criteria>

- [ ] Branch synced with main
- [ ] PR updated (if exists)

</success_criteria>
