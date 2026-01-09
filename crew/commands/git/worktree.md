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
**Create the worktree:**

```bash
# Determine base branch
base="${base_choice === 'main' ? 'main' : '$(git branch --show-current)'}"

# Create worktree with phantom
phantom create <branchName> --base $base

# Get the worktree path for display
wtPath=$(phantom where <branchName>)
echo "Worktree created at: $wtPath"
```

</phase>

<phase name="open-editor">
**Open editor in the new worktree (non-blocking):**

```bash
# Open editor in the new worktree
# Uses configured editor (phantom preferences get editor)
# Defaults to VS Code if not set
phantom edit <branchName> 2>/dev/null || true
```

**Note:** Editor opens asynchronously. If it fails, continue without error.
</phase>

<phase name="confirm-and-instruct">
**Tell user exactly what to do next:**

```
✅ Worktree created successfully!

**Branch:** <branchName>
**Location:** <path>

**IMPORTANT: To continue working in the new worktree:**

Option 1 - New terminal:
  cd <path>
  claude

Option 2 - Phantom shell (if using iTerm/Terminal):
  phantom shell <branchName>

Option 3 - Editor opened automatically
  The editor should have opened at the worktree location.
  Start a new Claude Code session there.

⚠️ Do NOT use 'git checkout' or 'git switch' - worktrees have dedicated branches.
```

</phase>

</process>

<success_criteria>

- [ ] Username prefix in branch name
- [ ] Worktree created with phantom
- [ ] Editor opened automatically (phantom edit)
- [ ] Clear instructions shown for how to switch to worktree
- [ ] User informed that auto-switch doesn't work in Claude Code
- [ ] Branch name follows conventions (username/type/description)

</success_criteria>
