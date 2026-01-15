---
name: push
description: Push commits to remote with smart QA check. Use when asked to "push changes", "push to remote", or "upload commits".
license: MIT
user_invocable: true
command: /push
argument-hint: "[optional: --force-with-lease for rebased branches]"
triggers:
  - "push"
  - "push changes"
  - "push to remote"
  - "upload commits"
---

<objective>
Push commits to remote. Consider running tests/linting first based on change scope.
</objective>

<quick_start>

1. **Assess changes:** Review what's being pushed
2. **Run QA if needed:** Based on change scope (see guidelines below)
3. **Push:** `git push -u origin $(git branch --show-current)`

</quick_start>

<workflow>

**Step 1: Review what's being pushed**

```bash
git log origin/$(git branch --show-current)..HEAD --oneline
git diff --stat origin/$(git branch --show-current)..HEAD
```

**Step 2: Push**

```bash
# Normal push
git push -u origin $(git branch --show-current)

# After rebase (force with lease for safety)
git push --force-with-lease
```

</workflow>

<qa_guidelines>

Use judgment to decide if QA is needed before push:

| Change Type | Run QA? |
|-------------|---------|
| Typo fix, docs only | No |
| Config tweaks | No |
| Code logic changes | Yes |
| New features | Yes |
| Bug fixes | Yes |
| After rebase | Yes |

If uncertain, run QA. Better safe than sorry.

</qa_guidelines>

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

**Required:**
- Use `--force-with-lease` for rebased branches
- Track upstream with `-u` flag for new branches

</constraints>

<success_criteria>

1. [ ] QA passed (if applicable based on change scope)
2. [ ] Not pushing to protected branch
3. [ ] Using `-u` flag for new branches
4. [ ] Using `--force-with-lease` (not `--force`) if rebased

</success_criteria>
