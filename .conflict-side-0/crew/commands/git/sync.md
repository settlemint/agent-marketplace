---
name: crew:git:sync
description: Sync current branch with main (or parent if stacked)
allowed-tools:
  - Bash
  - Skill
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<sync_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/sync-context.sh`
</sync_context>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<gitbutler_redirect>

**When GitButler is active, use the butler sync workflow.**

If `GITBUTLER_ACTIVE=true` from `<butler_context>`:

```
GitButler is active. Redirecting to butler sync workflow.
```

Delegate to `crew:git:butler:sync` and exit:

```javascript
Skill({ skill: "crew:git:butler:sync" });
```

</gitbutler_redirect>

<objective>

Sync branch: rebase onto parent (if machete) or main. Push and update PR.

</objective>

<workflow>

## Step 1: Determine Sync Method

Check `<stack_context>` to determine sync approach.

## Step 2a: If Machete-Managed

```bash
if git machete is-managed "$(git branch --show-current)" 2>/dev/null; then
  git fetch origin
  git machete update           # Rebase onto parent
  git push --force-with-lease
fi
```

Do NOT use `git rebase origin/main` - that flattens the stack!

## Step 2b: If Regular Branch

```bash
git stash push -m "sync-stash" 2>/dev/null || true
git fetch origin main
git rebase origin/main
git stash pop 2>/dev/null || true
```

## Step 3: Update PR (if exists)

```bash
pr_number=$(gh pr view --json number -q '.number' 2>/dev/null || echo "")
if [[ -n "$pr_number" ]]; then
  git push --force-with-lease origin "$(git branch --show-current)"
  if git machete is-managed "$(git branch --show-current)" 2>/dev/null; then
    git machete github anno-prs
    git machete github update-pr-descriptions --related
  fi
fi
```

</workflow>

<on_conflict>

Report conflicting files. Do NOT auto-resolve. Tell user: `git rebase --continue` after fixing.

</on_conflict>

<success_criteria>

- [ ] Branch synced with parent/main
- [ ] PR updated (if exists)

</success_criteria>
