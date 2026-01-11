---
name: crew:git:branch:new
description: Create a new branch with username prefix naming convention
argument-hint: "[description] [--type feat|fix|hotfix|chore] [--base main|current]"
allowed-tools:
  - Bash
  - AskUserQuestion
---

<butler_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/gitbutler-context.sh`
</butler_context>

<gitbutler_incompatible>

**This command does not work with GitButler.**

If `GITBUTLER_ACTIVE=true` from `<butler_context>`:

```
Traditional git branches conflict with GitButler virtual branches.

GitButler manages branches as virtual branches in a single workspace.
Creating git branches directly can cause conflicts with the workspace state.

Use this instead:
- `crew:git:butler:branch` - Create a virtual branch

To use traditional branches, first disable GitButler in this repository.
```

Exit immediately. Do not proceed with branch creation.

</gitbutler_incompatible>

<objective>

Create branch: `username/type/slug` from specified base. Ask type if not provided. Confirm name.

</objective>

<workflow>

## Step 1: Determine Type

```javascript
// If --type not provided, ask
if (!type) {
  AskUserQuestion({
    questions: [
      {
        question: "What type of branch?",
        header: "Type",
        options: [
          { label: "Feature (Recommended)", description: "feat/" },
          { label: "Bug fix", description: "fix/" },
          { label: "Hotfix", description: "hotfix/" },
          { label: "Chore", description: "chore/" },
        ],
        multiSelect: false,
      },
    ],
  });
}
```

## Step 2: Generate Name

```javascript
const username = Bash({ command: "whoami" }).trim();
const typePrefix =
  { Feature: "feat", "Bug fix": "fix", Hotfix: "hotfix", Chore: "chore" }[
    type
  ] || type;
const slug = slugify(description); // kebab-case, max 30 chars
const branchName = `${username}/${typePrefix}/${slug}`;
```

## Step 3: Create Branch

```bash
# --base main (default): from origin/main
git fetch origin main && git checkout -b ${branchName} origin/main

# --base current: from current HEAD (for stacked branches)
git checkout -b ${branchName}
```

</workflow>

<success_criteria>

- [ ] Branch name follows `username/type/slug` pattern
- [ ] Created from correct base (main or current)

</success_criteria>
