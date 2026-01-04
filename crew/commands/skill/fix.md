---
description: Repair skills, resolve skill blockers, tune skill configuration
argument-hint: "[skill name or issue description]"
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/fix-context.sh`

## Input

<fix_target>$ARGUMENTS</fix_target>

## Native Tools

### AskUserQuestion - Determine Fix Type

```javascript
AskUserQuestion({
  questions: [{
    question: "What skill issue would you like to fix?",
    header: "Target",
    options: [
      {label: "Skill issue (Recommended)", description: "Repair a broken or incorrect skill"},
      {label: "Skill validation", description: "Validate skill structure and patterns"},
      {label: "Describe issue", description: "I'll explain what needs fixing"}
    ],
    multiSelect: false
  }]
})
```

### TodoWrite - Track Progress

```javascript
TodoWrite({
  todos: [
    {content: "Identify skill issue", status: "in_progress", activeForm: "Identifying issue"},
    {content: "Analyze skill structure", status: "pending", activeForm: "Analyzing structure"},
    {content: "Implement fix", status: "pending", activeForm: "Implementing fix"},
    {content: "Validate fix", status: "pending", activeForm: "Validating fix"}
  ]
})
```

### Task - Spawn Fix Agents

```javascript
Task({
  subagent_type: "skill-healer",
  prompt: `CONTEXT: Fixing skill issue
SCOPE: Analyze and heal skill: ${skillName}
CONSTRAINTS: Use Context7 for correct patterns
OUTPUT: Before/after diffs for proposed changes

Tools:
- Glob/Grep/Read for skill files
- Context7 MCP for library docs`,
  description: "Skill healing",
  run_in_background: false
})
```

## Process

### Phase 1: Determine Fix Type

```javascript
AskUserQuestion({
  questions: [{
    question: "What skill issue would you like to fix?",
    header: "Target",
    options: [
      {label: "Skill issue (Recommended)", description: "Repair a broken or incorrect skill"},
      {label: "Skill validation", description: "Validate skill structure and patterns"},
      {label: "Describe issue", description: "I'll explain what needs fixing"}
    ],
    multiSelect: false
  }]
})
```

### Phase 2: Analyze and Fix Skill

Use the skill-healer agent:

```javascript
Task({
  subagent_type: "skill-healer",
  prompt: `CONTEXT: Skill maintenance
SCOPE: Analyze and heal skill: ${skillName}
CONSTRAINTS: Identify what's wrong, research correct patterns
OUTPUT: Before/after diffs for each change

Tools:
- Glob({pattern: "crew/skills/${skillName}/**/*.md"})
- Read for file contents
- Grep for pattern search

MCP: Context7 for correct library patterns
mcp__plugin_crew_context7__query-docs({
  context7CompatibleLibraryID: "/library/id",
  topic: "correct-api"
})`,
  description: "Skill healing",
  run_in_background: false
})

// Review proposed changes, then apply
```

### Phase 3: Validate

```javascript
// Validate skill structure
Glob({pattern: `crew/skills/${skillName}/**/*.md`})

// Check required sections exist
Read({file_path: `crew/skills/${skillName}/SKILL.md`})

// Update progress
TodoWrite({
  todos: [
    // ... previous completed
    {content: "Validate fix", status: "completed", activeForm: "Validating fix"}
  ]
})
```

### Phase 4: Confirm Completion

```javascript
AskUserQuestion({
  questions: [{
    question: "Skill fix applied. What's next?",
    header: "Next",
    options: [
      {label: "Commit changes (Recommended)", description: "Create a commit with the fix"},
      {label: "More fixes needed", description: "Continue with additional issues"},
      {label: "Review changes", description: "Show diff before committing"},
      {label: "Done", description: "Exit without committing"}
    ],
    multiSelect: false
  }]
})
```

## Success Criteria

- [ ] AskUserQuestion determines skill issue type
- [ ] TodoWrite tracks all fixes
- [ ] Skill-healer agent used for diagnosis
- [ ] Native tools used (not bash grep/find/cat)
- [ ] MCP tools used for documentation (Context7)
- [ ] Skill structure validated
- [ ] AskUserQuestion confirms completion
