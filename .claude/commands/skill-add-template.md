---
description: Add a template to an existing skill (project)
argument-hint: "[skill name] [template description]"
---

## Step 1: Select Target Plugin

Use AskUserQuestion to determine which plugin contains the skill:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which plugin contains the skill?",
      header: "Plugin",
      options: [
        {
          label: "devtools (Recommended)",
          description: "Framework/library patterns (React, Drizzle, etc.)",
        },
        {
          label: "flow",
          description: "Orchestration, workflows, git, agents",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 2: Add the Template

Read and follow the workflow in `devtools/skills/skill-builder/workflows/add-template.md`.

Skills location: `{selected_plugin}/skills/` based on the user's selection above.

User request: $ARGUMENTS
