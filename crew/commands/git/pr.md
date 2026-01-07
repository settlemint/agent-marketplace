---
name: crew:git:pr
description: Commit, push, and open a PR
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, WebFetch, WebSearch, MCPSearch, Skill
---

<constraints>

**CRITICAL: NEVER output plain text questions. Use AskUserQuestion tool for all user choices.**

</constraints>

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh 2>&1`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh 2>&1`
</stack_context>

<pr_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/pr-context.sh 2>&1`
</pr_context>

<context_sources>

**Gather context from these sources to populate the PR:**

1. **Plan file** (if exists): `.claude/plans/*.md` - Contains the why, design decisions, considerations
2. **Commit messages**: `git log origin/main..HEAD` - What was actually done
3. **Diff analysis**: `git diff origin/main..HEAD --stat` - What files changed
4. **Task/todo context**: Any active todos from the session

</context_sources>

<templates>

Select template based on primary commit type:

| Commit Type          | Template                                               |
| -------------------- | ------------------------------------------------------ |
| `feat`               | `skills/git/templates/pr-feature.md` - Full template   |
| `fix`                | `skills/git/templates/pr-fix.md` - Bug fix template    |
| `refactor/docs/test` | `skills/git/templates/pr-refactor.md` - Light template |
| Mixed/other          | `skills/git/templates/pr-default.md` - Minimal         |

**Analyze commits to determine template:**

```bash
git log origin/main..HEAD --pretty=format:"%s" | head -10
```

</templates>

<writing_style>

Follow SettleMint style guide (see `crew:workflow:content-style-editor`):

- **Active voice** - "This PR adds..." not "A feature was added..."
- **Sentence case headings** - "Design decisions" not "Design Decisions"
- **No banned words** - Avoid: seamless, leverage, utilize, dive into, game-changing, cutting-edge, unlock
- **Be specific** - "Fixes null pointer in user lookup" not "Fixes bug"
- **Use Oxford commas** - "A, B, and C" not "A, B and C"
- **No unnecessary adverbs** - Cut "actually", "very", "really", "just"

</writing_style>

<process>

1. Check state: `git branch --show-current && git status --short`
2. If on main → create feature branch
3. Stage & commit: `git add . && git commit -m "type(scope): msg"`
4. **Gather PR context:**
   - Check for plan file: `ls .claude/plans/*.md 2>/dev/null`
   - If plan exists, extract: motivation, design decisions, considerations
   - Analyze commits to select template and summarize changes
5. **Gather reviewer suggestions:**

```bash
# Get repo collaborators with push access
gh api repos/{owner}/{repo}/collaborators --jq '.[].login' | head -10

# Get last editors of changed files (for relevant expertise)
git log --pretty=format:"%ae" --diff-filter=M -- $(git diff --name-only origin/main..HEAD) | sort | uniq -c | sort -rn | head -5
```

6. **Check stacking (if branch not in machete layout):**

   If `<stack_context>` shows "is NOT in machete layout", ask about stacking FIRST:

```javascript
// Get available parent branches from machete status or git branches
// Prioritize: open PRs, then branches with recent activity
const parentOptions = [
  { label: "main", description: "Stack directly on main branch" },
  // Add other branches from machete layout or open PRs
  // e.g., { label: "feat/auth-v2", description: "PR #5097: Auth improvements" }
];

AskUserQuestion({
  questions: [
    {
      question: "Add this branch to a stack?",
      header: "Stacking",
      options: [
        { label: "No", description: "Create standalone PR against main" },
        ...parentOptions.slice(0, 3), // Show available parent branches
      ],
      multiSelect: false,
    },
  ],
});
```

If user selects a parent branch (not "No"), run:

```bash
git machete add $(git branch --show-current) --onto <selected-parent>
```

**Note:** After PR is created, step 12 will call `crew:git:update-pr` which runs
`git machete github update-pr-descriptions --related` to update all parent PRs
with the new stack chain.

7. Ask PR details:

```javascript
// Build reviewer options from GitHub collaborators and recent editors
const reviewerOptions = [
  { label: "None", description: "Skip reviewer assignment" },
  // Add suggested reviewers from collaborators/editors
  ...suggestedReviewers.map((r) => ({
    label: r.login,
    description: r.reason, // "Collaborator" or "Recent editor of changed files"
  })),
];

AskUserQuestion({
  questions: [
    {
      question: "PR type?",
      header: "Type",
      options: [
        { label: "Ready for review", description: "Ready to merge" },
        { label: "Draft", description: "Work in progress" },
      ],
      multiSelect: false,
    },
    {
      question: "Who should review this PR?",
      header: "Reviewers",
      options: reviewerOptions.slice(0, 4), // Max 4 options
      multiSelect: true,
    },
    {
      question: "Enable auto-merge when checks pass?",
      header: "Auto-merge",
      options: [
        { label: "No", description: "Manual merge required" },
        {
          label: "Yes",
          description: "Auto-merge with squash when checks pass",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

8. Generate PR body using selected template:
   - **Summary**: Synthesize from commits and plan
   - **Why**: Pull from plan's motivation/rationale section
   - **Design decisions**: Pull from plan's approach/considerations
   - **What changed**: From commit messages and diff
   - **How to test**: From plan's test criteria or generate from changes
   - Remove template HTML comments (`<!-- ... -->`) but preserve machete markers
   - Keep checklist items

9. **Create PR:**

**If machete-managed:**

```bash
git machete github create-pr [--draft]
git machete github anno-prs
```

**If traditional:**

```bash
git push -u origin $(git branch --show-current)
gh pr create --title "type(scope): description" --body "$(cat <<'EOF'
[Generated PR body from template]
EOF
)" [--draft]
```

10. **Apply reviewers (if selected):**

```bash
# Get PR number
PR_NUM=$(gh pr view --json number -q '.number')

# Add reviewers (skip if "None" selected)
gh pr edit $PR_NUM --add-reviewer "reviewer1,reviewer2"
```

11. **Enable auto-merge (if selected):**

```bash
# Enable auto-merge with squash
gh pr merge $PR_NUM --auto --squash
```

Note: Auto-merge requires repository to have this feature enabled in settings.

12. **Update PR annotations:**

```javascript
Skill({ skill: "crew:git:update-pr" });
```

13. Return PR URL.

</process>

<pr_title_format>

Match the primary commit type:

- Single commit: Use commit message as title
- Multiple commits: `type(scope): summary of changes`
- Mixed types: Use the most significant type (feat > fix > refactor > docs > chore)

</pr_title_format>

<machete_integration>

If PR is part of a stack (machete-managed):

- Title will include stack indicator from `git machete github anno-prs`
- Body will include auto-generated chain of upstream PRs between `<!-- start git-machete generated -->` and `<!-- end git-machete generated -->`
- **Preserve machete markers** - never remove or modify content between these markers

**After updating PR content:**

```bash
# Update machete sections in all related PRs (upstream and downstream)
git machete github update-pr-descriptions --related
```

This ensures the stack chain is current in all related PRs.

</machete_integration>
