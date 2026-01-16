---
name: push
description: Push commits to remote with QA awareness
---

<context>
!`${SKILL_ROOT}/scripts/context.sh`
</context>

<objective>
Push commits to remote. Use `--force-with-lease` after rebase. Consider QA based on change scope.
</objective>

<workflow>

1. **Check context:** Parse QA status from context above
2. **Assess changes:** Review what's being pushed
3. **Run QA if needed:** Based on change scope (see guidelines)
4. **Push:** With appropriate flags

</workflow>

<qa_guidelines>

| Change Type | Run QA? |
|-------------|---------|
| Typo fix, docs only | No |
| Config tweaks | No |
| Code logic changes | Yes |
| New features | Yes |
| Bug fixes | Yes |
| After rebase | Yes |

If QA status shows "Fresh" in context → skip CI.
If QA status shows "Stale" → run `bun run ci` first.

</qa_guidelines>

<commands>

```bash
# Review what's being pushed
git log origin/$(git branch --show-current)..HEAD --oneline
git diff --stat origin/$(git branch --show-current)..HEAD

# Normal push (new branch)
git push -u origin $(git branch --show-current)

# Normal push (existing tracking)
git push

# After rebase (force with lease for safety)
git push --force-with-lease

# Update QA timestamp after successful run
mkdir -p .claude/state && date +%s > .claude/state/qa-timestamp
```

</commands>

<multi_agent_safety>

In multi-Claude environments:

- Check `git status` for uncommitted work from other agents
- Use `--force-with-lease` instead of `--force` (fails if remote changed)
- Never use `git push --force` without explicit user confirmation

</multi_agent_safety>

<constraints>

**Banned:**
- `git push --force` without explicit user confirmation
- Pushing to main/master directly
- Skipping QA when context shows "Stale"

**Required:**
- Use `--force-with-lease` for rebased branches
- Track upstream with `-u` flag for new branches

</constraints>

<pr_update>

## Step 5: Update PR (if exists)

After successful push, check if a PR exists and update it:

```bash
# Check if PR exists for current branch
PR_NUM=$(gh pr view --json number -q '.number' 2>/dev/null)
```

If PR exists → read and follow `workflows/pr-update.md` to sync title/body with commits.

If no PR → skip (user can create one with `/pr`).

</pr_update>

<success_criteria>

- [ ] QA passed (if context showed "Stale")
- [ ] Not pushing to protected branch
- [ ] Using `-u` flag for new branches
- [ ] Using `--force-with-lease` (not `--force`) if rebased
- [ ] PR updated (if exists)

</success_criteria>
