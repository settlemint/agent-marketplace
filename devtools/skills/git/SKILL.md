---
name: git
description: Git workflows - commits, branches, PRs, push, sync. Routes to appropriate workflow based on task.
license: MIT
user_invocable: true
command: /git
argument-hint: "[commit|branch|pr|push|sync|fix-pr-reviews] [args]"
triggers:
  - "commit"
  - "save changes"
  - "commit my work"
  - "branch"
  - "create branch"
  - "new branch"
  - "start feature"
  - "feature branch"
  - "\\bpr\\b"
  - "pull request"
  - "create pr"
  - "open pr"
  - "submit for review"
  - "push"
  - "push changes"
  - "push to remote"
  - "upload commits"
  - "sync"
  - "sync with main"
  - "merge main"
  - "update branch"
  - "pull latest"
  - "rebase"
  - "fix pr"
  - "fix review"
  - "address review"
  - "resolve comment"
  - "pr feedback"
  - "conventional commit"
  - "update pr"
  - "sync pr"
  - "refresh pr"
  - "pr sync"
---

<objective>
Route git tasks to the appropriate workflow. Handles commits, branches, PRs, push, sync, and PR review fixes.
</objective>

<quick_start>

1. **Identify task** — What git operation is needed?
2. **Read workflow** — Load the appropriate workflow from `workflows/`
3. **Execute** — Follow the workflow steps

</quick_start>

<routing>

| Intent | Workflow | Command |
|--------|----------|---------|
| Create commit | `workflows/commit.md` | `/commit` |
| Create branch | `workflows/branch-create.md` | `/branch` |
| Create PR | `workflows/pr-create.md` | `/pr` |
| Update PR | `workflows/pr-update.md` | `/pr-update` |
| Push to remote | `workflows/push.md` | `/push` |
| Sync with main | `workflows/sync.md` | `/sync` |
| Fix PR reviews | `workflows/pr-fix-reviews.md` | `/fix-pr-reviews` |

</routing>

<decision_tree>

**What do you want to do?**

- "commit changes" / "save work" → Read `workflows/commit.md`
- "create branch" / "new feature" → Read `workflows/branch-create.md`
- "create PR" / "submit for review" → Read `workflows/pr-create.md`
- "update pr" / "sync pr" / "refresh pr" → Read `workflows/pr-update.md`
- "push" / "upload commits" → Read `workflows/push.md`
- "sync" / "merge main" / "rebase" → Read `workflows/sync.md`
- "fix pr" / "address review" / "resolve comments" → Read `workflows/pr-fix-reviews.md`

</decision_tree>

<quick_reference>

```bash
# Commit (conventional format)
git add <files> && git commit -m "type(scope): description"

# Branch (username/type/slug from origin/main)
git checkout -b $(whoami)/feat/feature-name origin/main

# Push (with upstream tracking)
git push -u origin $(git branch --show-current)

# Sync (fetch + merge)
git fetch origin main && git merge origin/main

# PR (with template)
gh pr create --title "type(scope): description" --body "..."

# Fix PR reviews (resolve threads)
# See workflows/pr-fix-reviews.md for full workflow
```

</quick_reference>

<commit_types>

| Type       | Use When                              |
| ---------- | ------------------------------------- |
| `feat`     | New feature                           |
| `fix`      | Bug fix                               |
| `docs`     | Documentation only                    |
| `refactor` | Code change (no feature/fix)          |
| `test`     | Adding/updating tests                 |
| `chore`    | Maintenance, deps, config             |
| `perf`     | Performance improvement               |
| `style`    | Formatting (no code change)           |

</commit_types>

<branch_naming>

**Format:** `username/type/slug`

- **username:** from `whoami`
- **type:** feat, fix, hotfix, chore
- **slug:** kebab-case, max 30 chars

**Examples:**
- `roderik/feat/user-authentication`
- `roderik/fix/null-pointer-login`
- `roderik/chore/bump-dependencies`

</branch_naming>

<pr_templates>

Templates in `templates/` are selected based on primary commit type:

| Commit Type | Template | Key Sections |
|-------------|----------|--------------|
| `feat` | pr-feature.md | Summary, Why, Design decisions, Changed, Test |
| `fix` | pr-fix.md | Summary, Root cause, Fix, Reproduce, Verify, Risk |
| `refactor` | pr-refactor.md | Summary, Why, Changed, Impact, Verification |
| `docs` | pr-refactor.md | Summary, Why, Changed, Impact, Verification |
| `chore` | pr-refactor.md | Summary, Why, Changed, Impact, Verification |
| other | pr-body.md | Summary, Why, Changed, Test |

</pr_templates>

<scripts>

Helper scripts in `scripts/`:

| Script | Purpose |
|--------|---------|
| `context.sh [mode]` | Git context (branch, status, QA freshness) |
| `pr-info.sh` | PR metadata (number, URL, title, state) |
| `pr-threads.sh` | Unresolved PR review threads |
| `pr-checks.sh` | CI status (passed, failed, pending) |
| `pr-resolve.sh` | Resolve PR thread with message |

</scripts>

<constraints>

**Banned:**
- `git add .` without reviewing changes
- `git push --force` (use `--force-with-lease`)
- Pushing to main/master directly
- Committing secrets, credentials, API keys
- Leaving conflict markers in files

**Required:**
- Conventional commit format: `type(scope): description`
- Branch from origin/main (freshly fetched)
- PR body from appropriate template
- Resolve ALL conflicts before committing

</constraints>

<success_criteria>

1. [ ] Identified the correct workflow for the task
2. [ ] Loaded and followed the workflow
3. [ ] Task completed successfully

</success_criteria>
