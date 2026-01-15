---
name: push
description: Push commits to remote with smart QA check. Use when asked to "push changes", "push to remote", or "upload commits".
license: MIT
user_invocable: true
argument-hint: "[optional: --force-with-lease for rebased branches]"
triggers:
  - "push"
  - "push changes"
  - "push to remote"
  - "upload commits"
---

<objective>
Push commits to remote. Check QA freshness first, run CI if stale.
</objective>

<quick_start>

1. **Check QA freshness:** Was `bun run ci` run in last 5 minutes?
2. **Run QA if stale:** `bun run ci` and update timestamp
3. **Push:** `git push -u origin $(git branch --show-current)`

</quick_start>

<workflow>

**Step 1: Check QA freshness**

```bash
QA_FILE=".claude/state/qa-timestamp"
if [[ -f "$QA_FILE" ]]; then
    AGE=$(($(date +%s) - $(cat "$QA_FILE")))
    if [[ $AGE -lt 300 ]]; then
        echo "QA fresh (${AGE}s ago) - safe to push"
    else
        echo "QA stale - run CI first"
    fi
else
    echo "No QA timestamp - run CI first"
fi
```

**Step 2: Run QA if needed**

```bash
bun run ci
mkdir -p .claude/state && date +%s > .claude/state/qa-timestamp
```

**Step 3: Push**

```bash
# Normal push
git push -u origin $(git branch --show-current)

# After rebase (force with lease for safety)
git push --force-with-lease
```

</workflow>

<smart_qa>

| Scenario | Action |
| -------- | ------ |
| QA fresh (< 5 min) | Skip, proceed with push |
| QA stale (> 5 min) | Run `bun run ci` first |
| Typo fix only | Skip QA (common sense) |
| Substantial changes | Always run QA |
| After rebase | Run QA, use `--force-with-lease` |

</smart_qa>

<multi_agent_safety>

In multi-Claude environments:

```bash
# Check for other agents' uncommitted work
git status

# Check for active sessions
ls -la .claude/branches/

# Use force-with-lease (never force)
git push --force-with-lease  # Fails if remote changed
```

**Never use:**
- `git push --force` (overwrites remote, blocks others)

</multi_agent_safety>

<constraints>

**Banned:**
- `git push --force` without explicit user confirmation
- Pushing to main/master directly
- Pushing without QA check (unless trivial change)

**Required:**
- Check QA freshness before push
- Use `--force-with-lease` for rebased branches
- Track upstream with `-u` flag

</constraints>

<success_criteria>

1. [ ] QA passed (or verified fresh)
2. [ ] Not pushing to protected branch
3. [ ] Using `-u` flag for new branches
4. [ ] Using `--force-with-lease` (not `--force`) if rebased

</success_criteria>
