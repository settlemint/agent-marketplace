---
name: git
description: Git workflows - commits, branches, PRs. Use when asked to "commit changes", "create PR", or "fix merge conflict". Smart QA before push with conventional commit format.
license: MIT
triggers:
  - "commit"
  - "branch"
  - "\\bpr\\b"
  - "pull request"
  - "push"
  - "sync"
  - "conventional commit"
---

<objective>
Git workflow with smart QA. Conventional commits, feature branches, clean PRs.
</objective>

<quick_start>

1. **Commit:** `git add . && git commit -m "type(scope): description"`
2. **Push:** Check QA freshness, then `git push -u origin $(git branch --show-current)`
3. **PR:** Load `workflows/pr-create.md`
4. **Fix reviews:** Load `workflows/pr-fix-reviews.md`

</quick_start>

<routing>

| Task             | Resource                      |
| ---------------- | ----------------------------- |
| Create PR        | `workflows/pr-create.md`      |
| Fix PR comments  | `workflows/pr-fix-reviews.md` |
| New branch       | `workflows/branch-create.md`  |
| Commit format    | `references/conventions.md`   |
| Branch naming    | `references/conventions.md`   |
| PR body template | `templates/pr-body.md`        |

</routing>

<inline_operations>

**Commit:**

```bash
git add <files>
git commit -m "type(scope): description"
# Types: feat, fix, docs, refactor, test, chore
```

**Push:**

```bash
# Check QA freshness first (see smart_qa)
git push -u origin $(git branch --show-current)
```

**Sync with main:**

```bash
git fetch origin main
git rebase origin/main
# If conflicts: resolve, git add, git rebase --continue
git push --force-with-lease
```

**Undo last commit (unpushed only):**

```bash
# Check: git log origin/$(git branch --show-current)..HEAD
git reset --soft HEAD~1
```

**Clean stale branches:**

```bash
git fetch --prune
git branch -vv | grep ': gone]' | awk '{print $1}' | xargs -r git branch -d
```

</inline_operations>

<smart_qa>

Before push or PR creation, check if QA is fresh:

```bash
QA_FILE=".claude/state/qa-timestamp"
if [[ -f "$QA_FILE" ]]; then
    AGE=$(($(date +%s) - $(cat "$QA_FILE")))
    [[ $AGE -lt 300 ]] && echo "QA fresh (${AGE}s ago)" || echo "QA stale"
fi
```

**Decision:**

- QA fresh (< 5 min): Skip, proceed with push/PR
- QA stale: Run `bun run ci`, then update timestamp
- Typo fix: Skip QA (common sense)
- Substantial changes: Always run QA

**Update timestamp after running CI:**

```bash
mkdir -p .claude/state && date +%s > .claude/state/qa-timestamp
```

</smart_qa>

<multi_agent_safety>

**Critical: Never Reset Concurrent Work**

In multi-Claude environments (like Conductor), other agents may have uncommitted changes:

**Before any destructive git operation:**

1. Run `git status` to see all changes (yours and others')
2. Check `.claude/branches/` for active sessions
3. NEVER run `git reset --hard` or `git clean -fd`
4. NEVER force push without explicit user confirmation

**Granular Commits**

Commit after each logical unit of work:

| Unit Type | Commit Separately          |
| --------- | -------------------------- |
| Feature   | One feature = one commit   |
| Bug fix   | One fix = one commit       |
| Refactor  | One refactor = one commit  |
| Test      | Related tests = one commit |

Don't batch unrelated changes. Other agents may need to cherry-pick or revert.

**Branch Awareness**

```bash
# Check for other active branches
git branch -a

# Check for concurrent agent sessions
ls -la .claude/branches/

# Coordinate via state files
cat .claude/branches/$(git branch --show-current)/state.json
```

**Protected Operations**

These require explicit user confirmation in multi-agent environments:

| Operation          | Risk                                    |
| ------------------ | --------------------------------------- |
| `git reset`        | May discard others' work                |
| `git rebase`       | Rewrites history, breaks other branches |
| `git push --force` | Overwrites remote, blocks collaborators |
| `git clean -fd`    | Deletes untracked files from all agents |
| Delete branches    | May delete active work                  |

**Safe Alternatives:**

```bash
# Instead of reset --hard
git stash  # Save your changes without affecting others

# Instead of force push
git push --force-with-lease  # Fails if remote changed

# Instead of clean -fd
git status  # Review first, then selectively remove
```

**Commit Message with Agent Context**

When multiple agents work on same branch:

```bash
git commit -m "feat(auth): add login endpoint

- Added POST /api/auth/login
- Created AuthService with password verification

Agent: Claude-1 (session abc123)"
```

</multi_agent_safety>

<constraints>
**Banned:**
- `git reset --hard` in multi-agent environments
- `git push --force` without explicit user confirmation
- `git add .` without reviewing changes first
- Committing secrets, credentials, or API keys
- Amending commits that have been pushed to remote

**Required:**

- Conventional commit format: `type(scope): description`
- Run QA checks before push (or verify freshness)
- Stage files selectively (not `git add .`)
- Include version bump in plugin.json for each commit
  </constraints>

<anti_patterns>

- Batching unrelated changes in a single commit
- Force pushing to main/master branch
- Using `git clean -fd` without checking for others' work
- Rebasing public branches without coordination
- Committing large generated files or node_modules
  </anti_patterns>

<granular_commit_pattern>

After completing each task:

1. **Stage only related files:**

   ```bash
   git add src/models/user.ts src/models/user.test.ts
   # NOT: git add .
   ```

2. **Commit with conventional format:**

   ```bash
   git commit -m "feat(user): add user model with validation

   - Created User schema with Drizzle
   - Added email and name validation
   - Wrote unit tests for all validators"
   ```

3. **Bump version in affected plugin.json:**
   - patch: 1.1.0 → 1.1.1 (bug fixes)
   - minor: 1.1.0 → 1.2.0 (new features)
   - major: 1.1.0 → 2.0.0 (breaking changes)

4. **Do NOT commit unrelated changes:**

   ```bash
   # Check what you're committing
   git diff --cached --stat

   # Unstage unrelated files
   git reset HEAD path/to/unrelated/file.ts
   ```

</granular_commit_pattern>

<scripts>

| Script          | Purpose                        |
| --------------- | ------------------------------ |
| `context.sh`    | Unified context (branch, QA)   |
| `pr-info.sh`    | Get PR metadata                |
| `pr-threads.sh` | Get unresolved review comments |
| `pr-checks.sh`  | Get CI check status            |
| `pr-resolve.sh` | Resolve a thread on GitHub     |

</scripts>

<success_criteria>

1. [ ] Commit uses `type(scope): description` format
2. [ ] Branch follows `username/type/short-description` pattern
3. [ ] No secrets committed
4. [ ] QA passed (or fresh) before push/PR
5. [ ] Version bump included in plugin.json
</success_criteria>

<evolution>
**Extension Points:**
- Add project-specific commit scopes and types
- Create custom PR templates for different change types
- Extend QA checks with project-specific validations

**Timelessness:** Git workflows are foundational; conventional commits and feature branches will remain standard practice.
</evolution>
