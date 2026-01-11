---
description: Create a domain expertise skill (library/framework knowledge) (project)
argument-hint: "[library or framework name]"
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
          description: "Framework/library patterns (React, Drizzle, etc.)",
        },
        {
          label: "crew",
          description: "Orchestration, workflows, git, agents",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

## Step 2: Create the Skill

Read and follow the workflow in `crew/skills/skill-builder/workflows/create-domain-expertise-skill.md`.

Create the skill in: `{selected_plugin}/skills/` based on the user's selection above.

User request: $ARGUMENTS
