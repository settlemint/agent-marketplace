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

1. Check if `.claude/flow/` already exists
2. Create directory structure: `config.json`, `state.json`, `history/`
3. Confirm initialization to user

</quick_start>

<workflow>

## Phase 1: Check Existing State

Check if `.claude/flow/` exists. If so, ask user whether to reset or continue.

## Phase 2: Create Structure

Create `.claude/flow/` with: `config.json`, `state.json`, `history/`

## Phase 3: Initialize Files

**config.json**: Project name, version, settings (autoTrack, saveHistory, suggestSkills)

**state.json**: currentWorkflow (null), workflows ([]), lastActivity (null)

## Phase 4: Confirm

Display configuration location, available skills, and next steps.

</workflow>

<related_skills>

```javascript
Skill({ skill: "flow:status" }); // Check status
Skill({ skill: "flow:workflow:start" }); // Start a workflow
Skill({ skill: "flow:analyze" }); // Analyze codebase
```

</related_skills>

<success_criteria>

- [ ] Flow directory structure created
- [ ] Confirmation displayed to user

</success_criteria>
