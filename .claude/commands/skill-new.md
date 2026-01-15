---
description: Create a new skill using skill-builder workflow (project)
argument-hint: "[skill name or description]"
---

## Step 1: Select Target Plugin

Use AskUserQuestion to determine which plugin this skill belongs to:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which plugin should this skill be created in?",
      header: "Plugin",
      options: [
        {
          label: "devtools (Recommended)",
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

## Step 2: Create the Skill

Read and follow the workflow in `devtools/skills/skill-builder/workflows/create-new-skill.md`.

Create the skill in: `{selected_plugin}/skills/` based on the user's selection above.

User request: $ARGUMENTS
