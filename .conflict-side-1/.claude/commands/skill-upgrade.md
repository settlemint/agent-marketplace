---
description: Upgrade a simple skill to router pattern (project)
argument-hint: "[skill name]"
---

## Step 1: Select Target Plugin

Use AskUserQuestion to determine which plugin contains the skill:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which plugin contains the skill to upgrade?",
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

## Step 2: Upgrade the Skill

Read and follow the workflow in `crew/skills/skill-builder/workflows/upgrade-to-router.md`.

Skills location: `{selected_plugin}/skills/` based on the user's selection above.

User request: $ARGUMENTS
