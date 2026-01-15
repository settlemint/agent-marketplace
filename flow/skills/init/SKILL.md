---
name: flow:init
description: Initialize flow in the current project. Use when setting up workflow tracking for a new project.
triggers:
  - "init flow"
  - "initialize flow"
  - "setup flow"
  - "start flow"
---

<objective>

Initialize the flow plugin in the current project. Creates necessary state files and configuration.

**Output:** `.claude/flow/config.json` and `.claude/flow/state.json`

</objective>

<quick_start>

```javascript
// Load this skill
Skill({ skill: "flow:init" });
```

Then follow the workflow to initialize flow in your project.

</quick_start>

<workflow>

## Phase 1: Check Existing State

1. Check if `.claude/flow/` directory exists
2. If exists, ask user whether to reset or continue

## Phase 2: Create Structure

Create the flow directory structure:

```
.claude/flow/
├── config.json       # Flow configuration
├── state.json        # Current workflow state
└── history/          # Workflow history
```

## Phase 3: Initialize Configuration

Create `config.json` with project settings:

```json
{
  "projectName": "directory name",
  "initialized": "ISO date",
  "version": "1.0.0",
  "settings": {
    "autoTrack": true,
    "saveHistory": true,
    "suggestSkills": true
  }
}
```

## Phase 4: Initialize State

Create `state.json` with empty state:

```json
{
  "currentWorkflow": null,
  "workflows": [],
  "lastActivity": null
}
```

## Phase 5: Confirm

Display confirmation message with:

- Configuration location
- Available skills
- Next steps

</workflow>

<related_skills>

After initialization, you can use:

```javascript
Skill({ skill: "flow:status" }); // Check status
Skill({ skill: "flow:workflow:start" }); // Start a workflow
Skill({ skill: "flow:analyze" }); // Analyze codebase
```

</related_skills>

<success_criteria>

- [ ] `.claude/flow/config.json` created
- [ ] `.claude/flow/state.json` created
- [ ] `.claude/flow/history/` directory created
- [ ] Confirmation displayed to user

</success_criteria>
