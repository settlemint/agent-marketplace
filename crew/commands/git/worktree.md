---
name: crew:git:worktree
description: Create a new phantom worktree for isolated development
argument-hint: "[branch name or feature description]"
allowed-tools:
  - Read
  - Bash
  - AskUserQuestion
  - TodoWrite
skills:
  - crew:phantom
---

<phantom_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/phantom-context.sh`
</phantom_context>

<notes>
This is the CANONICAL location for worktree creation. Other commands delegate here.
Branch names use pattern: username/type/description
</notes>

<process>

<phase name="ask-type">
**Ask for worktree type:**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What type of worktree do you want to create?",
      header: "Type",
      options: [
        { label: "Feature", description: "New feature development (feat/)" },
        { label: "Bug fix", description: "Fix an existing bug (fix/)" },
        { label: "Hotfix", description: "Critical production fix (hotfix/)" },
        { label: "Experiment", description: "Test an approach (experiment/)" },
      ],
      multiSelect: false,
    },
    {
      question: "What should it be based on?",
      header: "Base",
      options: [
        {
          label: "main",
          description: "Start fresh from main branch (Recommended)",
        },
        { label: "Current branch", description: "Branch from current work" },
      ],
      multiSelect: false,
    },
  ],
});
```

</phase>

<phase name="generate-name">
**Generate branch name with username prefix:**

```javascript
// Get username from system
const username = Bash({ command: "whoami" }).trim();

// Auto-generate branch name with username prefix
const typeMap = {
  Feature: "feat",
  "Bug fix": "fix",
  Hotfix: "hotfix",
  Experiment: "experiment",
};
const type = typeMap[selectedType];
const slug = slugify(description); // kebab-case, max 30 chars
const suggestedName = `${username}/${type}/${slug}`;

AskUserQuestion({
  questions: [
    {
      question: `Use this branch name: ${suggestedName}?`,
      header: "Name",
      options: [
        { label: "Use suggested", description: suggestedName },
        { label: "Customize", description: "Enter a different name" },
      ],
      multiSelect: false,
    },
  ],
});

const branchName = customName || suggestedName;
```

</phase>

<phase name="create-worktree">
**Create the worktree and switch to it:**

```bash
# Determine base branch
base="${base_choice === 'main' ? 'main' : '$(git branch --show-current)'}"

# Create worktree with phantom
phantom create <branchName> --base $base

# Get the worktree path and switch to it
wtPath=$(phantom where <branchName>)
cd "$wtPath"

# Verify we're in the worktree
pwd
git branch --show-current
```

</phase>

<phase name="confirm-switch">
**Confirm the switch:**

```
Switched to worktree: <branchName>
Location: <path>
Branch: <branchName>

Ready to continue working in this worktree.
```

</phase>

</process>

<success_criteria>

- [ ] Username prefix in branch name
- [ ] Worktree created with phantom
- [ ] User informed of location and how to switch
- [ ] Branch name follows conventions (username/type/description)

</success_criteria>
