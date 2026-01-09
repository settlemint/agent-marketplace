---
name: crew:git:branch-new
description: Create a new branch with username prefix naming convention
argument-hint: "[description] [--base main|current]"
allowed-tools:
  - Bash
  - AskUserQuestion
---

<notes>
CANONICAL location for branch creation with username prefix.
Pattern: username/type/description (e.g., roderik/feat/user-auth)
</notes>

<process>

<phase name="ask-type">
**Ask for branch type:**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What type of branch is this?",
      header: "Type",
      options: [
        { label: "Feature", description: "New feature (feat/)" },
        { label: "Bug fix", description: "Fix a bug (fix/)" },
        { label: "Hotfix", description: "Critical fix (hotfix/)" },
        { label: "Chore", description: "Maintenance (chore/)" },
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
const username = Bash({ command: "whoami" }).trim();
const typeMap = {
  Feature: "feat",
  "Bug fix": "fix",
  Hotfix: "hotfix",
  Chore: "chore",
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

<phase name="create-branch">
**Create the branch:**

```bash
# If --base main specified (or default for simple branches)
git fetch origin main && git checkout -b <branchName> origin/main

# If --base current (for stacked branches)
git checkout -b <branchName>
```

</phase>

</process>

<success_criteria>

- [ ] Username prefix in branch name
- [ ] User confirmed or customized name
- [ ] Branch created from correct base

</success_criteria>
