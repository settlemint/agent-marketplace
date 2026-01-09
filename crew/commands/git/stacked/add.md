---
name: crew:git:stacked:add
description: Add current or specified branch to the machete stack
argument-hint: "[branch-name] [--onto parent]"
allowed-tools:
  - Bash
  - AskUserQuestion
  - Skill
---

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<objective>

Add branch to machete layout. Ask for parent. Optionally add qualifiers.

</objective>

<workflow>

## Step 1: Determine Branch

```bash
branch="${1:-$(git branch --show-current)}"
```

## Step 2: Check if Already Managed

```bash
if git machete is-managed "$branch" 2>/dev/null; then
    echo "Branch '$branch' is already in layout"
    git machete status
    exit 0
fi
```

## Step 3: Initialize Layout if Needed

If no layout:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "No machete layout found. How to initialize?",
      header: "Layout",
      options: [
        {
          label: "Discover (Recommended)",
          description: "Auto-detect all branches",
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

If "Discover": `Skill({ skill: "crew:git:stacked:discover" })`

## Step 4: Select Parent Branch

```javascript
AskUserQuestion({
  questions: [
    {
      question: `Which branch should '${branch}' be stacked on?`,
      header: "Parent",
      options: [
        { label: "main", description: "Stack directly on main" },
        // Add other branches from layout
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
      question: "Add qualifiers?",
      header: "Qualifiers",
      options: [
        { label: "None", description: "Standard behavior" },
        { label: "rebase=no push=no", description: "Not my branch" },
        { label: "slide-out=no", description: "Never auto-slide-out" },
      ],
      multiSelect: false,
    },
  ],
});
```

If qualifiers: `git machete anno "$branch" "$qualifiers"`

## Step 7: Verify

```bash
git machete status --list-commits
```

</workflow>

<success_criteria>

- [ ] Branch added to layout
- [ ] Correct parent selected
- [ ] Status shows correct structure

</success_criteria>
