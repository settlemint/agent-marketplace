---
name: crew:git:stacked:add
description: Add current or specified branch to the machete stack
argument-hint: "[branch-name] [--onto parent]"
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

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<process>

## Step 1: Determine Branch to Add

```bash
branch="${1:-$(git branch --show-current)}"
echo "Adding branch: $branch"
```

## Step 2: Check if Already Managed

```bash
if git machete is-managed "$branch" 2>/dev/null; then
    echo "Branch '$branch' is already in the machete layout"
    git machete status
    exit 0
fi
```

## Step 3: Initialize Layout if Needed

If no layout exists:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "No machete layout found. How to initialize?",
      header: "Layout",
      options: [
        {
          label: "Discover (Recommended)",
          description: "Auto-detect all branches from history",
        },
        {
          label: "Start with this branch",
          description: "Create layout with just this branch",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

If "Discover":

```javascript
Skill({ skill: "crew:git:stacked:discover" });
```

If "Start with this branch":

```bash
echo "main" > .git/machete
echo "    $branch" >> .git/machete
```

## Step 4: Select Parent Branch

Get available parent options from machete context or open PRs:

```javascript
AskUserQuestion({
  questions: [
    {
      question: `Which branch should '${branch}' be stacked on?`,
      header: "Parent",
      options: [
        { label: "main", description: "Stack directly on main branch" },
        // Dynamic options from open PRs or existing layout branches
        // { label: "feature-base", description: "PR #123: Auth improvements" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 5: Add to Stack

```bash
git machete add "$branch" --onto "$parent"
```

## Step 6: Add Qualifiers (Optional)

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Add any qualifiers to this branch?",
      header: "Qualifiers",
      options: [
        { label: "None", description: "Standard behavior" },
        {
          label: "rebase=no push=no",
          description: "Not my branch, skip rebase/push",
        },
        { label: "slide-out=no", description: "Never auto-slide-out" },
      ],
      multiSelect: false,
    },
  ],
});
```

If qualifiers selected:

```bash
git machete anno "$branch" "$qualifiers"
```

## Step 7: Verify and Show Status

```bash
echo "=== Branch added to stack ==="
git machete status --list-commits
```

</process>

<qualifiers_reference>

| Qualifier      | Effect                           | When to Use                       |
| -------------- | -------------------------------- | --------------------------------- |
| `rebase=no`    | Skip rebase during traverse      | Branch you don't own              |
| `push=no`      | Skip push during traverse        | Branch you don't own              |
| `slide-out=no` | Don't auto-slide-out when merged | Branch that should stay in layout |

**Combining qualifiers:**

```bash
git machete anno feature-x "PR #123 rebase=no push=no"
```

**Removing qualifiers:**

```bash
git machete anno feature-x ""
# Or keep just PR annotation:
git machete anno feature-x "PR #123"
```

</qualifiers_reference>

<stacking_strategies>

**Linear stack:**

```
main
    feature-part-1
        feature-part-2
            feature-part-3
```

**Fan-out from main:**

```
main
    feature-a
    feature-b
    feature-c
```

**Mixed:**

```
main
    feature-base
        feature-part-1
        feature-part-2
    hotfix
```

</stacking_strategies>

<after_adding>

After adding a branch to the stack:

1. **Create PR:** `Skill({ skill: "crew:git:pr:create" })`
2. **Sync stack:** `Skill({ skill: "crew:git:stacked:traverse" })`
3. **View status:** `Skill({ skill: "crew:git:stacked:status" })`

</after_adding>

<success_criteria>

- [ ] Branch added to machete layout
- [ ] Correct parent branch selected
- [ ] Qualifiers applied (if needed)
- [ ] Status shows correct tree structure

</success_criteria>
