---
description: Verify skill structure and validity (project)
argument-hint: "[skill name or path]"
---

## Step 1: Select Target Plugin

Use AskUserQuestion to determine which plugin contains the skill:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which plugin contains the skill to verify?",
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

## Step 2: Verify the Skill

Read and follow the workflow in `crew/skills/skill-builder/workflows/verify-skill.md`.

Skills location: `{selected_plugin}/skills/` based on the user's selection above.

User request: $ARGUMENTS
