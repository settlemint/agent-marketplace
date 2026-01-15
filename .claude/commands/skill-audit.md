---
description: Audit an existing skill for quality and structure (project)
argument-hint: "[skill name or path]"
---

## Step 1: Select Target Plugin

Use AskUserQuestion to determine which plugin contains the skill:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Which plugin contains the skill to audit?",
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

## Step 2: Audit the Skill

Read and follow the workflow in `devtools/skills/skill-builder/workflows/audit-skill.md`.

Skills location: `{selected_plugin}/skills/` based on the user's selection above.

User request: $ARGUMENTS
