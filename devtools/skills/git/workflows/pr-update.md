---
name: pr-update
description: Update PR title and body from commits
---

<context>
!`${SKILL_ROOT}/scripts/context.sh pr`
</context>

<objective>
Update existing PR title and body to reflect all commits. Automatically called after push.
</objective>

<workflow>

## Step 1: Validate PR

```bash
PR_NUM=$(gh pr view --json number -q '.number' 2>/dev/null)
```

If no PR found → exit with message "No PR for current branch. Use /pr to create one."

## Step 2: Gather Context

```bash
# Get base branch
BASE=$(gh pr view --json baseRefName -q '.baseRefName')

# Get all commit messages since divergence
git log origin/${BASE}..HEAD --pretty=format:"%s"

# Get commit count
COMMIT_COUNT=$(git rev-list origin/${BASE}..HEAD --count)

# Check for plan files
ls .claude/plans/*.md 2>/dev/null
```

## Step 3: Generate Title

**Rules:**

- Single commit → use commit message verbatim
- Multiple commits → `type(scope): summary` with most significant type

**Type priority (most → least significant):**

1. `feat` - new features
2. `fix` - bug fixes
3. `refactor` - code restructuring
4. `docs` - documentation
5. `chore` - maintenance

**Example:**

```
# Single commit
"feat(api): add user authentication"

# Multiple commits (2 feat, 1 fix, 1 docs)
"feat(api): user authentication and rate limiting"
```

## Step 4: Generate Body

**Select template based on primary commit type:**

| Commit Type | Template |
|-------------|----------|
| feat | `templates/pr-feature.md` |
| fix | `templates/pr-fix.md` |
| refactor, docs, chore, test | `templates/pr-refactor.md` |
| other | `templates/pr-body.md` |

**Gather content for placeholders:**

```bash
# Summary from commits
git log origin/${BASE}..HEAD --oneline

# Diff stats
git diff --stat origin/${BASE}

# Plan file content (if exists)
PLAN=$(ls -t .claude/plans/*.md 2>/dev/null | head -1)
```

**Extract from plan file (if exists):**

- `MOTIVATION` - from problem/motivation section
- `DESIGN_DECISIONS` - from approach/considerations section
- `TEST_PLAN` - from test criteria section

**Fill template placeholders and remove HTML comments.**

## Step 5: Update PR

```bash
PR_NUM=$(gh pr view --json number -q '.number')

# Update title
gh pr edit $PR_NUM --title "type(scope): description"

# Update body (use HEREDOC for proper formatting)
gh pr edit $PR_NUM --body "$(cat <<'EOF'
## Summary

...filled content...

## Why

...filled content...
EOF
)"
```

</workflow>

<commands>

```bash
# Check if PR exists
gh pr view --json number -q '.number' 2>/dev/null

# Get base branch
gh pr view --json baseRefName -q '.baseRefName'

# Get commits since base
git log origin/main..HEAD --pretty=format:"%s"
git log origin/main..HEAD --oneline

# Get diff stats
git diff --stat origin/main

# Update PR title
gh pr edit $PR_NUM --title "feat(scope): description"

# Update PR body
gh pr edit $PR_NUM --body "$(cat <<'EOF'
## Summary
...
EOF
)"
```

</commands>

<constraints>

**Banned:**

- Updating PR on main/master branch
- Empty or generic titles like "Update" or "Changes"
- Removing existing PR description entirely

**Required:**

- Conventional commit format for title
- Template-based body generation
- Preserve any manually added sections at end of body

</constraints>

<success_criteria>

- [ ] PR exists for current branch
- [ ] Title reflects primary commit type and scope
- [ ] Body generated from appropriate template
- [ ] Plan context included (if plan file exists)

</success_criteria>
