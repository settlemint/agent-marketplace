---
name: crew:git:pr:create
description: Commit, push, and open a PR
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
  - TodoWrite
  - WebFetch
  - WebSearch
  - MCPSearch
  - Skill
---

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
5. **Repository PR template** (if exists): See `<pr_template_detection>`

</context_sources>

<pr_template_detection>

**Check for existing PR templates in the repository:**

```bash
# GitHub PR template locations (check in order)
templates=(
    ".github/PULL_REQUEST_TEMPLATE.md"
    ".github/pull_request_template.md"
    "PULL_REQUEST_TEMPLATE.md"
    "pull_request_template.md"
    "docs/PULL_REQUEST_TEMPLATE.md"
    ".github/PULL_REQUEST_TEMPLATE/default.md"
)

for template in "${templates[@]}"; do
    if [[ -f "$template" ]]; then
        echo "Found PR template: $template"
        break
    fi
done
```

**If repository template exists:**

1. Parse the template structure (headings, checkboxes, sections)
2. Merge with crew templates, preserving repository-specific sections
3. Fill in content from commits, plan file, and diff analysis

**Template priority:**

1. Repository template (if exists) — for repo-specific sections
2. Crew templates — for content generation patterns
3. Generated content — fills both

**Example merge:**

Repository template has:

```markdown
## Description

<!-- Describe your changes -->

## Checklist

- [ ] Tests added
- [ ] Documentation updated
```

Crew fills in:

```markdown
## Description

This PR adds user authentication with JWT tokens...

## Checklist

- [x] Tests added
- [x] Documentation updated
```

</pr_template_detection>

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

<notes>
Writing style per @rules/writing-style.md. Machete patterns per @rules/machete-workflow.md.
</notes>

<process>

1. Check state: `git branch --show-current && git status --short`
2. If on main → create feature branch
3. Stage & commit: `git add . && git commit -m "type(scope): msg"`
4. **Gather PR context:**
   - Check for plan file: `ls .claude/plans/*.md 2>/dev/null`
   - If plan exists, extract: motivation, design decisions, considerations
   - Analyze commits to select template and summarize changes
5. **Check stacking (if branch not in machete layout):**

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

**Note:** After PR is created, step 11 will call `crew:git:pr:update` which runs
`git machete github update-pr-descriptions --related` to update all parent PRs
with the new stack chain.

6. Ask PR details:

```javascript
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

7. Generate PR body using selected template:
   - **Summary**: Synthesize from commits and plan
   - **Why**: Pull from plan's motivation/rationale section
   - **Design decisions**: Pull from plan's approach/considerations
   - **What changed**: From commit messages and diff
   - **How to test**: From plan's test criteria or generate from changes
   - Remove template HTML comments (`<!-- ... -->`) but preserve machete markers
   - Keep checklist items

8. **Create PR:**

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

9. **Enable auto-merge (if selected):**

```bash
# Get PR number
PR_NUM=$(gh pr view --json number -q '.number')

# Enable auto-merge with squash
gh pr merge $PR_NUM --auto --squash
```

Note: Auto-merge requires repository to have this feature enabled in settings.

10. **Update PR annotations:**

```javascript
Skill({ skill: "crew:git:pr:update" });
```

11. Return PR URL.

</process>

<pr_title_format>

Match the primary commit type:

- Single commit: Use commit message as title
- Multiple commits: `type(scope): summary of changes`
- Mixed types: Use the most significant type (feat > fix > refactor > docs > chore)

</pr_title_format>

<machete_integration>

**Machete markers are auto-added when using machete commands.**

The `update-pr` skill called in step 10 handles all machete annotation updates, including:
- `git machete github anno-prs` - Annotate PRs with stack info
- `git machete github update-pr-descriptions --related` - Update all related PRs

See @rules/machete-workflow.md for marker format.

</machete_integration>
