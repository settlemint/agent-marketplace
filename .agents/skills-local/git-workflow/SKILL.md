---
name: git-workflow
description: "Git workflow commands: commit, branch, pr, push, sync, review, fixup, update-pr, commit-push, clean-gone. Use with command argument."
user-invocable: true
argument-hint: <command> [options]
allowed-tools:
  - Bash
  - Read
  - Glob
  - Edit
  - Write
  - Task
  - Grep
  - AskUserQuestion
---

# Git Workflow Skill

Unified git workflow commands for commits, branches, PRs, and reviews.

## Usage

Invoke with a command name as argument:
- Claude: `Skill({ skill: "git-workflow", args: "commit" })`
- Codex: `$git-workflow commit` or `/skills git-workflow commit`

## Available Commands

| Command | Description |
|---------|-------------|
| `commit` | Create conventional commit with all changes staged |
| `branch` | Create feature branch with naming convention |
| `pr` | Create pull request with smart template |
| `push` | Push commits to remote safely |
| `sync` | Sync branch with main via merge or rebase |
| `review` | Run comprehensive code review |
| `fixup` | Fix PR review comments and CI failures |
| `update-pr` | Update PR title and body from commits |
| `commit-push` | Create conventional commit and push |
| `clean-gone` | Remove local branches deleted from remote |

---

## commit

Create a conventional commit with all current changes staged.

In multi-agent and human-in-the-loop workflows, all changes should be committed unless they are clearly cruft. Do not be overly selective.

### Context

```bash
! git status --short
! git diff --stat
! git diff --cached --stat
! git log --oneline -5
```

### Workflow

1. **Review changes** - Check all modified files
2. **Stage all changes** - `git add -A` (stage everything)
3. **Check for secrets** - Verify no .env, .pem, .key, credentials staged
4. **Determine type** - Choose commit type based on changes
5. **Write message** - Use conventional format with descriptive body

### Commit Format

```
type(scope): short description

- Bullet point explaining what changed
- Another bullet point if needed
```

### Commit Types

| Type | When to Use |
|------|-------------|
| `feat` | New feature |
| `fix` | Bug fix |
| `refactor` | Code restructuring without behavior change |
| `docs` | Documentation only |
| `test` | Adding or updating tests |
| `chore` | Build, CI, dependencies |
| `perf` | Performance improvement |

### Commands

```bash
# Stage all changes
git add -A

# Check for sensitive files
git diff --cached --name-only | grep -E '\.(env|pem|key)$|credentials|secret'

# Commit with heredoc for multi-line
git commit -m "$(cat <<'EOF'
feat(auth): add login endpoint

- Added POST /api/auth/login
- Created AuthService with password verification
- Added unit tests for authentication flow
EOF
)"

# Single-line for trivial changes
git commit -m "fix(typo): correct spelling in README"
```

### Sensitive File Handling

If sensitive files are staged, unstage them:
```bash
git reset HEAD <sensitive-file>
```

Then re-run the commit.

### Constraints

**Banned:**
- Committing secrets, credentials, API keys, .env files
- Amending commits that have been pushed
- Being overly selective (commit all work in multi-agent workflows)

**Required:**
- Conventional commit format: `type(scope): description`
- Stage all changes with `git add -A`
- Multi-line body for non-trivial changes (3+ files or logic changes)

### Success Criteria

- [ ] Commit uses `type(scope): description` format
- [ ] All changes staged with `git add -A`
- [ ] No secrets or sensitive files committed
- [ ] Multi-line body for complex changes

---

## branch

Create a new branch following the `username/type/slug` naming convention.

### Context

```bash
! whoami
! git branch --show-current
! git fetch origin main --dry-run 2>&1 | head -3
! git branch --list | head -10
```

### Arguments

- `type`: feat, fix, hotfix, or chore
- `description`: Brief description (converted to kebab-case slug)

### Workflow

1. **Validate type** - Must be: feat, fix, hotfix, or chore
2. **Generate slug** - Convert description to kebab-case, max 30 chars
3. **Fetch latest** - `git fetch origin main`
4. **Create branch** - `git checkout -b ${USERNAME}/${TYPE}/${SLUG} origin/main`

### Branch Types

| Type | Use When |
|------|----------|
| `feat` | New feature or enhancement |
| `fix` | Bug fix |
| `hotfix` | Urgent production fix |
| `chore` | Maintenance, dependencies, config |

### Examples

```bash
# Feature branch
git checkout -b roderik/feat/user-authentication origin/main

# Bug fix
git checkout -b roderik/fix/balance-calculation origin/main

# Hotfix
git checkout -b roderik/hotfix/critical-security-patch origin/main

# Chore
git checkout -b roderik/chore/update-dependencies origin/main
```

### Slug Generation

Convert description to kebab-case:
- "Add user authentication" -> `add-user-authentication`
- "Fix NULL pointer in login" -> `fix-null-pointer-in-login`
- Truncate to 30 characters max

### Constraints

**Banned:**
- Creating branches from stale local main
- Branch names with spaces or special characters
- Starting work on main/master directly

**Required:**
- Always fetch origin/main first
- Follow `username/type/slug` format
- Use kebab-case for slug

### Success Criteria

- [ ] Branch follows `username/type/slug` pattern
- [ ] Created from fresh origin/main
- [ ] Currently on the new branch

---

## pr

Create a pull request with smart template selection based on commit type.

### Context

```bash
! git branch --show-current
! git log origin/main..HEAD --oneline 2>/dev/null | head -10
! git diff --stat origin/main 2>/dev/null | tail -5
! git status --short
```

### Workflow

#### Step 1: Verify State

```bash
BRANCH=$(git branch --show-current)
[[ "$BRANCH" == "main" || "$BRANCH" == "master" ]] && echo "ERROR: Create feature branch first with /branch"
```

If on main -> stop and instruct to use `/branch` first.

#### Step 2: Stage and Commit

If uncommitted changes exist, use `/commit` workflow first.

#### Step 2.5: Sync with Main

Before pushing, sync with main to avoid conflicts:

```javascript
Skill({ skill: "git-workflow", args: "sync --rebase" })
```

#### Step 3: Push Branch

```bash
git push -u origin $(git branch --show-current)
```

#### Step 4: Determine PR Type

Ask user for PR type:
- **Ready for review** - Ready to merge when approved
- **Ready + auto-squash** - Auto-merge with squash when checks pass
- **Draft** - Work in progress, not ready for review

#### Step 5: Select Template

Determine primary commit type from first commit:

```bash
PRIMARY_TYPE=$(git log origin/main..HEAD --format="%s" | head -1 | cut -d'(' -f1)
```

| Commit Type | Template Style |
|-------------|----------------|
| `feat` | Feature template (summary, motivation, changes) |
| `refactor`, `docs`, `chore`, `test` | Refactor template (what/why/impact) |
| `fix`, other | Fix template (problem, solution, testing) |

#### Step 6: Generate PR Body

Fill template with:
- `{{SUMMARY}}` - Brief description from commits
- `{{COMMITS}}` - List of commits
- `{{FILES_CHANGED}}` - Files modified
- `{{WHY}}` - Motivation (extract from plan if exists)

Include implementation plan if available:

```bash
PLAN_FILE=$(ls -t ~/.claude/plans/*.md 2>/dev/null | head -1)
[[ -n "$PLAN_FILE" ]] && PLAN_CONTENT=$(cat "$PLAN_FILE")
```

#### Step 7: Create PR

```bash
# Ready for review
gh pr create --title "type(scope): description" --body "$(cat <<'EOF'
## Summary
- Brief description of changes

## Changes
- List of changes made

## Test Plan
- [ ] Tests pass locally
- [ ] Manual testing completed
EOF
)"

# Draft PR
gh pr create --draft --title "..." --body "..."
```

#### Step 8: Enable Auto-merge (if selected)

```bash
gh pr merge $(gh pr view --json number -q '.number') --auto --squash
```

#### Step 9: Return URL

```bash
gh pr view --json url -q '.url'
```

### Constraints

**Banned:**
- Creating PR from main/master branch
- PRs without meaningful description
- Skipping template-based body

**Required:**
- Feature branch (not main/master)
- Conventional commit format in title
- PR body from appropriate template
- User confirmation for draft/auto-merge

### Success Criteria

- [ ] Not on main/master branch
- [ ] All changes committed
- [ ] Synced with main before pushing
- [ ] Branch pushed to origin
- [ ] User confirmed PR options
- [ ] PR created with template body
- [ ] Auto-merge enabled (if selected)
- [ ] PR URL returned to user

---

## push

Push commits to remote with safety checks and auto-retry.

### Context

```bash
! git branch --show-current
! git status --short
! git log origin/$(git branch --show-current 2>/dev/null)..HEAD --oneline 2>/dev/null || echo "New branch or no upstream"
```

### Workflow

1. **Sync with main** - Rebase on main to avoid conflicts
2. **Check uncommitted changes** - Warn if working directory is dirty
3. **Verify not on protected branch** - Block push to main/master
4. **Determine push type** - New branch vs existing, rebased vs normal
5. **Execute push** - With appropriate flags
6. **Auto-retry if rejected** - Fetch, rebase, push again

#### Step 1: Sync with Main

Before pushing, sync with main to avoid conflicts:

```javascript
Skill({ skill: "git-workflow", args: "sync --rebase" })
```

This delegates to the sync command which handles fetch, rebase, conflict resolution, and push.

### Push Types

| Situation | Command | Why |
|-----------|---------|-----|
| New branch | `git push -u origin branch` | Sets upstream tracking |
| Normal commits | `git push` | Standard push |
| After rebase | `git push --force-with-lease` | Safer than --force |
| After amend | `git push --force-with-lease` | History rewritten |

### Commands

```bash
BRANCH=$(git branch --show-current)

# Block protected branches
if [[ "$BRANCH" == "main" || "$BRANCH" == "master" ]]; then
  echo "ERROR: Cannot push directly to $BRANCH"
  exit 1
fi

# New branch (set upstream)
git push -u origin "$BRANCH"

# Existing branch (normal push)
git push

# After rebase (force with lease for safety)
git push --force-with-lease
```

### Auto-Retry on Conflict

If push is rejected because remote has new commits:

```bash
BRANCH=$(git branch --show-current)

if ! git push; then
  git fetch origin "$BRANCH"
  if [ -n "$(git log HEAD..origin/$BRANCH --oneline 2>/dev/null)" ]; then
    echo "Remote has new commits. Rebasing..."
    git rebase "origin/$BRANCH"
    git push --force-with-lease
  fi
fi
```

### Constraints

**Banned:**
- `git push --force` (use `--force-with-lease` instead)
- Pushing directly to main/master
- Pushing with uncommitted changes (warn user)

**Required:**
- Use `-u` flag for new branches
- Use `--force-with-lease` after rebase/amend
- Verify not on protected branch

### Success Criteria

- [ ] Synced with main before pushing
- [ ] Not pushing to protected branch
- [ ] Using `-u` flag for new branches
- [ ] Using `--force-with-lease` (not `--force`) if needed
- [ ] Auto-retry with rebase if push rejected
- [ ] Push completed successfully

---

## sync

Sync current branch with main (or specified base) using merge or rebase.

### Context

```bash
! git branch --show-current
! git fetch origin main 2>&1 | head -3
! git log --oneline HEAD..origin/main 2>/dev/null | head -5 || echo "Up to date or no origin/main"
! git status --short
```

### Arguments

- `base`: Base branch to sync with (default: main)
- `--rebase`: Use rebase strategy without prompting (for automated sync before push)
- `--merge`: Use merge strategy without prompting

### Workflow

1. **Fetch latest** from origin
2. **Choose strategy** - Use `--rebase` or `--merge` flag if provided, otherwise ask user
3. **Execute sync** - Handle any conflicts
4. **Push** - Normal for merge, force-with-lease for rebase
5. **Auto-retry if rejected** - Fetch, rebase, push again

### Commands

```bash
# Parse arguments
BASE="main"
STRATEGY=""
for arg in "$@"; do
  case "$arg" in
    --rebase) STRATEGY="rebase" ;;
    --merge) STRATEGY="merge" ;;
    *) BASE="$arg" ;;
  esac
done

# Fetch latest
git fetch origin "$BASE"

# If no strategy flag provided, ask user (see Merge vs Rebase Decision below)
# If --rebase flag: use rebase
# If --merge flag: use merge

# MERGE (preserves history, creates merge commit)
git merge "origin/$BASE" --no-edit

# OR REBASE (linear history, rewrites commits)
git rebase "origin/$BASE"

# Push after merge
git push

# Push after rebase
git push --force-with-lease
```

### Merge vs Rebase Decision

| Aspect | Merge | Rebase |
|--------|-------|--------|
| History | Preserves branches | Linear, clean |
| Commit | Creates merge commit | Rewrites commits |
| Push | Normal push | Force push required |
| Shared branch | Safe | Dangerous |
| Solo feature | OK | Preferred |

**Use MERGE when:**
- Branch is shared with others
- Want to preserve full history
- Already pushed many commits

**Use REBASE when:**
- Solo feature branch
- Want clean linear history
- Few commits, not yet pushed (or OK with force-push)

### Conflict Resolution

**Conflict markers:**
```
<<<<<<< HEAD
your changes
=======
incoming changes
>>>>>>> origin/main
```

**Resolution options:**
- Keep yours: Remove incoming section
- Keep theirs: Remove your section
- Keep both: Combine logically
- Rewrite: Create new version

**After resolving:**

```bash
# For merge
git add <resolved-files>
git commit -m "merge: resolve conflicts with main"

# For rebase
git add <resolved-files>
git rebase --continue
```

### Abort Options

```bash
# Abort merge in progress
git merge --abort

# Abort rebase in progress
git rebase --abort

# Reset to before sync
git reset --hard ORIG_HEAD
```

### Constraints

**Banned:**
- `git push --force` (use `--force-with-lease`)
- Rebasing shared/public branches
- Leaving conflict markers in files
- Committing with unresolved conflicts

**Required:**
- Fetch before merge/rebase
- Resolve ALL conflicts before continuing
- Use `--force-with-lease` after rebase
- Verify build passes after conflict resolution

### Success Criteria

- [ ] Fetched latest from origin
- [ ] Merged/rebased without unresolved conflicts
- [ ] No conflict markers in any files
- [ ] Build/tests pass after sync
- [ ] Auto-retry with rebase if push rejected
- [ ] Pushed successfully

---

## review

Execute a comprehensive code review using specialized review agents.

### Context

```bash
! git branch --show-current
! git merge-base HEAD main 2>/dev/null || echo "main"
! git diff --name-only $(git merge-base HEAD main 2>/dev/null || echo "HEAD~1") HEAD 2>/dev/null | head -20
```

### Review Workflow

#### Stage 1: Code Review (Domain Checklists)

Spawn the `code-reviewer` agent to apply domain-specific checklists:

```javascript
Task({
  subagent_type: "build-mode:code-reviewer",
  description: "Apply domain checklists",
  prompt: `Review the following files for code quality:

Files: ${ARGUMENTS || "changed files on current branch"}

Apply relevant domain checklists:
- Frontend (React patterns, accessibility, data fetching)
- API (input validation, error responses, auth)
- Data layer (schemas, transactions, indexes)
- Testing (behavior focus, realistic data, coverage)

Report findings with priorities (P1: must fix, P2: should fix, P3: nice to have).`
})
```

#### Stage 2: Quality Review (Style/Patterns/Maintainability)

Spawn the `quality-reviewer` agent for 3-pass quality analysis:

```javascript
Task({
  subagent_type: "build-mode:quality-reviewer",
  description: "Review code quality",
  prompt: `Review code quality for:

Files: ${ARGUMENTS || "changed files on current branch"}

3-pass review:
1. Style - naming, formatting, magic numbers
2. Patterns - DRY, single responsibility, abstraction level
3. Maintainability - change impact, dependencies, testability

Only report issues with 80%+ confidence. Distinguish must-fix from nice-to-have.`
})
```

#### Stage 3: Security Review (OWASP Analysis)

Spawn the `security-reviewer` agent for security audit:

```javascript
Task({
  subagent_type: "build-mode:security-reviewer",
  description: "Security audit",
  prompt: `Security review for:

Files: ${ARGUMENTS || "changed files on current branch"}

Check against OWASP Top 10:
- Injection vulnerabilities (SQL, XSS, command)
- Authentication/authorization issues
- Cryptographic failures
- Security misconfigurations
- Hardcoded secrets

Report P0 (critical), P1 (high), P2 (medium) issues.`
})
```

#### Stage 4: Error Handling Review

Spawn the `silent-failure-hunter` agent to check error handling:

```javascript
Task({
  subagent_type: "build-mode:silent-failure-hunter",
  description: "Check error handling",
  prompt: `Hunt for silent failures in:

Files: ${ARGUMENTS || "changed files on current branch"}

Find:
- Empty catch blocks
- Silent returns on error
- Broad exception catching
- Missing error propagation
- Swallowed rejections

Classify: P0 (must fix), P1 (should fix), P2 (consider).`
})
```

### Aggregation

After all reviews complete, aggregate findings:

```markdown
## Review Summary

### Critical Issues (P0)
[List all P0 issues from all reviewers]

### High Priority (P1)
[List all P1 issues]

### Medium Priority (P2)
[List all P2 issues]

### Low Priority (P3)
[List all P3 issues]

### Verdict: [PASS / NEEDS FIXES]
- Pass: No P0 issues, P1 issues are minor
- Needs Fixes: Any P0 issues or multiple P1 issues
```

### Quick Options

For targeted reviews, use arguments:

- `--security-only` - Only security-reviewer
- `--quality-only` - Skip security and error handling
- `--quick` - Only code-reviewer with reduced scope

### Constraints

**Banned:**
- Skipping security review for auth/payment code
- Reporting low-confidence issues as P0/P1
- Leaving P0 issues unaddressed

**Required:**
- Run all 4 review stages for full review
- Aggregate findings by priority
- Provide clear PASS/NEEDS FIXES verdict

### Success Criteria

- [ ] All review stages completed
- [ ] No P0 (critical) issues
- [ ] P1 issues acknowledged and planned
- [ ] Summary report generated

---

## fixup

Fix all unresolved PR review comments and CI failures with educational feedback.

### Context

```bash
! git branch --show-current
! git status --short
! gh pr view --json number,title,state,reviewDecision 2>/dev/null || echo "No PR found"
! gh pr checks 2>/dev/null | head -20 || echo "No checks"
# Get unresolved review threads (uses GraphQL API - reviewThreads field doesn't exist in gh pr view)
! .agents/skills-local/git-workflow/scripts/get-unresolved-threads.sh 2>/dev/null | head -30 || echo "No unresolved threads"
# Get PR issue comments (general comments like Codex/Gemini reviews, not inline threads)
! .agents/skills-local/git-workflow/scripts/get-issue-comments.sh --actionable 2>/dev/null | head -30 || echo "No issue comments"
```

### Workflow

#### 1. Parse Context

Extract from the data above:
- Unresolved review threads (file path, line, comment) - inline code comments
- Issue comments (general PR comments like Codex/Gemini reviews) - often contain code suggestions
- Failed CI checks
- Current branch state

#### 2. Fix Issues

For each unresolved thread, issue comment, or CI failure:
1. Read the file mentioned (for threads) or parse the code suggestion (for issue comments)
2. Understand the reviewer's concern
3. Make the appropriate code fix
4. Consider if reviewer was correct, partially correct, or incorrect

**Issue comments** (like Codex or Gemini reviews) often contain:
- Code suggestions with file paths and line numbers
- Priority labels (P0, P1, P2)
- Specific fix recommendations in code blocks

#### 3. Run Local Validation

Before pushing, verify locally:
```bash
bun run lint
bun run test
bun run ci  # if available
```

#### 3.5. Sync Before Push

Before pushing fixes, sync with main:

```javascript
Skill({ skill: "git-workflow", args: "sync --rebase" })
```

#### 4. Commit and Push

Use single responsibility - delegate to commit-push:

```javascript
Skill({ skill: "git-workflow", args: "commit-push fix: address PR review comments" })
```

Or manually:
```bash
git add -A
git commit -m "fix: address PR review comments"
git push --force-with-lease
```

#### 5. Resolve Threads with Educational Feedback

For EACH unresolved thread, provide feedback using symbols:

- **checkmark** Reviewer was correct - Acknowledge and explain what you learned
- **half-circle** Reviewer was partially correct - Explain the nuance
- **x** Reviewer was incorrect - Teach respectfully why

**Resolve thread via GraphQL:**

```bash
# Get thread IDs from context (already fetched above) or fetch again
THREADS=$(.agents/skills-local/git-workflow/scripts/get-unresolved-threads.sh)
THREAD_ID=$(echo "$THREADS" | jq -r '.id' | head -1)

# Resolve the thread
.agents/skills-local/git-workflow/scripts/resolve-thread.sh "$THREAD_ID"
```

**Example feedback patterns:**

```
[checkmark] Good catch! The null check was missing. Fixed in abc123.

[half-circle] Valid concern but useMemo is premature here since component rarely re-renders. Added comment explaining tradeoff.

[x] This pattern is intentional for TypeScript discriminated unions. The 'redundant' check enables type narrowing. Added clarifying comment.
```

#### 6. Verify All Threads Resolved

```bash
.agents/skills-local/git-workflow/scripts/count-unresolved-threads.sh
```

Should return 0.

#### 7. Wait for CI and Retry if Needed

If CI fails after push:
1. Read the failure logs: `gh pr checks --watch`
2. Fix the issue
3. Commit with descriptive message
4. Push again

Max 3 CI retry iterations before escalating.

### Constraints

**Banned:**
- Dismissing reviewer comments without addressing them
- Pushing without running local validation
- Resolving threads without educational feedback

**Required:**
- Address ALL unresolved threads
- Run local validation before push
- Provide educational feedback when resolving

### Success Criteria

- [ ] All review comments addressed with code fixes
- [ ] All threads resolved on GitHub with educational feedback
- [ ] Synced with main before pushing
- [ ] All CI checks passing
- [ ] No new issues introduced

---

## update-pr

Update an existing PR's title and body based on current commits.

### Context

```bash
! gh pr view --json number,title,baseRefName 2>/dev/null || echo "No PR found"
! git log origin/main..HEAD --oneline 2>/dev/null | head -10
! git diff --stat origin/main 2>/dev/null | tail -5
```

### Workflow

#### Step 1: Validate PR Exists

```bash
PR_NUM=$(gh pr view --json number -q '.number' 2>/dev/null)
[[ -z "$PR_NUM" ]] && echo "ERROR: No PR found for current branch"
```

If no PR found -> stop and instruct to use `/pr` first.

#### Step 2: Analyze Existing Body

Fetch current PR body and identify preserved sections:

```bash
gh pr view --json body -q '.body'
```

**Parse for preserved content:**
- `# User description` block
- Review agent sections (cubic, Greptile, Gemini)
- Implementation Plan collapsible

#### Step 3: Decide Update Mode

**Use Full Regenerate mode if:**
- `--regenerate` flag is passed, OR
- Body has no structured sections, OR
- Body is dominated by auto-generated noise

**Otherwise use Incremental Update mode.**

#### Step 4: Gather Current Commits

```bash
BASE=$(gh pr view --json baseRefName -q '.baseRefName')
git log origin/${BASE}..HEAD --pretty=format:"%s" | head -20
git diff --stat origin/${BASE}
```

#### Step 5: Generate Title

- Single commit -> use commit message as title
- Multiple commits -> `type(scope): summary of changes`
- Mixed types -> use most significant (feat > fix > refactor > docs > chore)

#### Step 6: Generate/Update Body

**For Incremental Update:**
1. Keep preserved sections exactly as-is
2. Update `## Commits` with current commit list
3. Update `## Files Changed` with current diff stat
4. Update Implementation Plan if local plan exists
5. Keep review agent sections at the end

**For Full Regenerate:**
1. Select template based on primary commit type
2. Fill placeholders
3. Append preserved review agent findings

**Include plan if available:**

```bash
PLAN_FILE=$(ls -t ~/.claude/plans/*.md 2>/dev/null | head -1)
[[ -n "$PLAN_FILE" ]] && PLAN_CONTENT=$(cat "$PLAN_FILE")
```

#### Step 7: Update PR

```bash
gh pr edit $PR_NUM --title "type(scope): description"
gh pr edit $PR_NUM --body "$(cat <<'EOF'
[assembled body]
EOF
)"
```

#### Step 8: Confirm Update

```bash
gh pr view --json url -q '.url'
```

### Template Structure

```markdown
## Summary
- Brief description of changes

## Commits
- list of commits

## Files Changed
- diff stat

<details>
<summary>Implementation Plan</summary>

[Plan content if available]

</details>
```

### Constraints

**Banned:**
- Destroying user-written content
- Removing review agent findings without `--regenerate`
- Updating PR that doesn't exist
- Replacing good structure with worse structure

**Required:**
- Preserve review agent findings by default
- Title matches primary commit type
- Incremental update unless `--regenerate` or body is broken

### Success Criteria

- [ ] PR exists for current branch
- [ ] User description preserved (unless `--regenerate`)
- [ ] Review agent sections preserved
- [ ] Commits list reflects current branch state
- [ ] Files changed reflects current diff
- [ ] Title updated if commits changed
- [ ] PR URL returned to user

---

## commit-push

Create a conventional commit and push to remote. This command delegates to `commit` and `push` for single responsibility.

### Context

```bash
! git branch --show-current
! git status --short
! git log origin/$(git branch --show-current 2>/dev/null)..HEAD --oneline 2>/dev/null || echo "New branch"
```

### Workflow

#### Step 1: Commit Changes

Delegate to commit command:

```javascript
Skill({ skill: "git-workflow", args: "commit $ARGUMENTS" })
```

This will:
- Stage all changes with `git add -A`
- Check for sensitive files
- Create conventional commit with proper message

#### Step 2: Push to Remote

Delegate to push command:

```javascript
Skill({ skill: "git-workflow", args: "push" })
```

This will:
- Verify not on protected branch
- Push with `-u` flag for new branches
- Auto-retry with rebase if rejected

### Manual Fallback

If delegation is not available, execute directly:

```bash
# Stage all changes
git add -A

# Commit
git commit -m "$(cat <<'EOF'
type(scope): description

- Change details
EOF
)"

# Push
BRANCH=$(git branch --show-current)
git push -u origin "$BRANCH" || git push
```

### Constraints

**Banned:**
- Skipping the commit step
- Pushing directly to main/master
- Using `--force` instead of `--force-with-lease`

**Required:**
- Use commit logic for commit (single responsibility)
- Use push logic for push (single responsibility)
- Follow conventional commit format

### Success Criteria

- [ ] All changes staged and committed
- [ ] Commit uses conventional format
- [ ] No secrets committed
- [ ] Push completed successfully
- [ ] Both commit and push workflows followed

---

## clean-gone

Clean up local branches that have been deleted from the remote repository.

### Context

```bash
! git fetch --prune 2>&1 | head -5
! git branch -vv | grep ': gone]' | awk '{print $1}' || echo "No gone branches"
! git branch --list | wc -l
```

### Workflow

1. **Fetch with prune** - Update remote tracking and remove stale references
2. **Identify gone branches** - Find branches marked as [gone]
3. **Remove worktrees** - Handle any associated worktrees
4. **Delete branches** - Remove the local branches

### Commands

```bash
# Fetch and prune stale remote-tracking branches
git fetch --prune

# List branches with their tracking status
git branch -vv

# Find branches marked as [gone]
git branch -vv | grep ': gone]' | awk '{print $1}'

# Delete a gone branch
git branch -D <branch-name>
```

### Full Cleanup Script

```bash
# Fetch and prune
git fetch --prune

# Get list of gone branches
GONE_BRANCHES=$(git branch -vv | grep ': gone]' | awk '{print $1}')

if [ -z "$GONE_BRANCHES" ]; then
  echo "No branches to clean up"
  exit 0
fi

echo "Branches to remove:"
echo "$GONE_BRANCHES"

# Remove each branch
for branch in $GONE_BRANCHES; do
  # Check for associated worktree
  WORKTREE=$(git worktree list | grep "$branch" | awk '{print $1}')
  if [ -n "$WORKTREE" ]; then
    echo "Removing worktree: $WORKTREE"
    git worktree remove "$WORKTREE" --force
  fi

  echo "Deleting branch: $branch"
  git branch -D "$branch"
done

echo "Cleanup complete"
```

### What Gets Cleaned

| Status | Meaning | Action |
|--------|---------|--------|
| `[gone]` | Remote branch deleted | Delete local branch |
| `[ahead X]` | Local commits not pushed | Keep (warn user) |
| `[behind X]` | Remote has new commits | Keep |

### Safety

This command only deletes branches where:
- The remote tracking branch no longer exists
- The branch is marked as `[gone]` by git

It will NOT delete:
- Branches with unpushed commits (unless they're gone)
- The current branch
- main/master branches

### Constraints

**Banned:**
- Deleting branches with unpushed work without warning
- Deleting the current branch

**Required:**
- Fetch with prune first
- Show user what will be deleted
- Handle worktrees properly

### Success Criteria

- [ ] Fetched with prune
- [ ] Identified all [gone] branches
- [ ] Removed associated worktrees
- [ ] Deleted gone branches
- [ ] Reported results to user
