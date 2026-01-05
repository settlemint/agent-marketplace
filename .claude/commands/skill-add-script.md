---
description: Add a script to an existing skill (project)
argument-hint: "[skill name] [script description]"
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
          label: "crew (Recommended)",
          description: "Orchestration, workflows, git, agents",
        },
        {
          label: "devtools",
          description: "Framework/library patterns (React, Drizzle, etc.)",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 2: Add the Script

Read and follow the workflow in `crew/skills/skill-builder/workflows/add-script.md`.

Skills location: `{selected_plugin}/skills/` based on the user's selection above.

User request: $ARGUMENTS
