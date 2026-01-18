---
name: pr-create
description: Create pull request with smart defaults and user options
user_invocable: true
command: /pr
---

<context>
!`${SKILL_ROOT}/scripts/context.sh pr`
</context>

<objective>
Stage, commit, push, create PR. Ask user for PR options (draft/ready, auto-merge). Select template based on commit type. Extract context from plan files.
</objective>

<workflow>

## Step 1: Check State

```bash
BRANCH=$(git branch --show-current)
[[ "$BRANCH" == "main" || "$BRANCH" == "master" ]] && echo "Create feature branch first!"
```

If on main → create feature branch first using branch-create workflow.

## Step 2: Stage and Commit

If uncommitted changes exist (check context above):

```bash
git add <relevant-files>
git commit -m "type(scope): description"
```

Use conventional commit format. See `workflows/commit.md` for details.

## Step 3: Smart QA

Check QA status from context above:
- If "Fresh" → skip CI
- If "Stale" → run `bun run ci` and update timestamp

```bash
bun run ci
mkdir -p .claude/state && date +%s > .claude/state/qa-timestamp
```

## Step 3b: Pre-PR Review (Optional)

For comprehensive pre-PR validation, run specialized review agents:

```javascript
// Aspect-based agent selection - choose based on files changed
const reviewers = ['code-reviewer']; // Always

// Add specialized reviewers based on changes
if (hasTestChanges) reviewers.push('test-analyzer');
if (hasTypeChanges) reviewers.push('type-design-analyzer');
reviewers.push('silent-failure-hunter'); // Always check error handling

// Launch parallel reviews (optional - for high-quality PRs)
Task({ subagent_type: "general-purpose", prompt: "Review changes for CLAUDE.md compliance. Only report issues with confidence >= 80." })
Task({ subagent_type: "general-purpose", prompt: "Audit error handling. Flag: unlogged errors, silent failures, unhandled rejections." })
```

**Confidence threshold: 80**
Only fix issues scoring >= 80 confidence before PR creation.

**Skip this step for:**
- Draft PRs
- Small fixes (<10 lines changed)
- Documentation-only changes

## Step 4: Ask PR Options

```javascript
AskUserQuestion({
  questions: [
    {
      question: "PR type?",
      header: "Type",
      options: [
        { label: "Ready for review", description: "Ready to merge when approved" },
        { label: "Draft", description: "Work in progress, not ready for review" }
      ],
      multiSelect: false
    },
    {
      question: "Enable auto-merge?",
      header: "Auto-merge",
      options: [
        { label: "No", description: "Manual merge required after approval" },
        { label: "Yes", description: "Auto-merge with squash when checks pass" }
      ],
      multiSelect: false
    }
  ]
})
```

## Step 5: Push

```bash
git push -u origin $(git branch --show-current)
```

## Step 6: Generate PR Body

**Determine primary commit type:**

```bash
PRIMARY_TYPE=$(git log origin/main..HEAD --format="%s" | head -1 | cut -d'(' -f1)
```

**Select template based on type:**

| Commit Type | Template |
|-------------|----------|
| feat | `templates/pr-feature.md` |
| fix | `templates/pr-fix.md` |
| refactor, docs, chore, test | `templates/pr-refactor.md` |
| other | `templates/pr-body.md` (default) |

**Gather context for placeholders:**

```bash
# Commits
git log origin/main..HEAD --oneline

# Plan files (extract motivation, design decisions)
ls .claude/plans/*.md 2>/dev/null

# Diff stats
git diff --stat origin/main
```

**If plan file exists:** Read it and extract:
- `MOTIVATION` from the problem/motivation section
- `DESIGN_DECISIONS` from the approach/considerations section
- `TEST_PLAN` from the test criteria section

**Fill template placeholders** and generate PR body.

## Step 7: Create PR

```bash
# Ready for review
gh pr create --title "type(scope): description" --body "$(cat <<'EOF'
[filled template content]
EOF
)"

# Draft PR
gh pr create --draft --title "type(scope): description" --body "..."
```

## Step 8: Enable Auto-merge (if selected)

```bash
PR_NUM=$(gh pr view --json number -q '.number')
gh pr merge $PR_NUM --auto --squash
```

## Step 9: Return PR URL

```bash
gh pr view --json url -q '.url'
```

</workflow>

<template_selection>

| Commit Type | Template | Key Sections |
|-------------|----------|--------------|
| `feat` | pr-feature.md | Summary, Why, Design decisions, Changed, Test |
| `fix` | pr-fix.md | Summary, Root cause, Fix, Reproduce, Verify, Risk |
| `refactor` | pr-refactor.md | Summary, Why, Changed, Impact, Verification |
| `docs` | pr-refactor.md | Summary, Why, Changed, Impact, Verification |
| `chore` | pr-refactor.md | Summary, Why, Changed, Impact, Verification |
| `test` | pr-refactor.md | Summary, Why, Changed, Impact, Verification |
| other | pr-body.md | Summary, Why, Changed, Test |

</template_selection>

<plan_extraction>

If `.claude/plans/*.md` exists:

```bash
# Find most recent plan file
PLAN=$(ls -t .claude/plans/*.md 2>/dev/null | head -1)

# Extract sections (pseudo-code)
# MOTIVATION: text between "## Problem" or "## Motivation" heading and next heading
# DESIGN_DECISIONS: text between "## Approach" or "## Design" heading and next heading
# TEST_PLAN: text between "## Test" or "## Verification" heading and next heading
```

Use extracted content to fill template placeholders.

</plan_extraction>

<commands>

```bash
# Push with upstream tracking
git push -u origin $(git branch --show-current)

# Create ready PR
gh pr create --title "feat(scope): description" --body "$(cat <<'EOF'
## Summary
...

## Why
...

## What changed
...

## How to test
...
EOF
)"

# Create draft PR
gh pr create --draft --title "..." --body "..."

# Enable auto-merge
gh pr merge $(gh pr view --json number -q '.number') --auto --squash

# Get PR URL
gh pr view --json url -q '.url'
```

</commands>

<constraints>

**Banned:**
- Creating PR from main/master branch
- PRs without meaningful description
- Skipping user questions for PR options

**Required:**
- Feature branch
- Conventional commit format
- PR body from appropriate template
- User confirmation for draft/auto-merge

</constraints>

<success_criteria>

- [ ] Not on main/master branch
- [ ] Changes committed (conventional format)
- [ ] QA passed (or fresh)
- [ ] User confirmed PR options
- [ ] PR created with template-based description
- [ ] Auto-merge enabled (if selected)
- [ ] PR URL returned

</success_criteria>
