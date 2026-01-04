---
name: crew:fix
description: Repair skills, resolve blockers, tune the system
argument-hint: "[skill name, issue description, or 'all' to fix pending todos]"
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/fix-context.sh`

## Input

<fix_target>$ARGUMENTS</fix_target>

## Native Tools

### AskUserQuestion - Determine Fix Type

```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like to fix?",
    header: "Target",
    options: [
      {label: "Pending todos (Recommended)", description: "Work through .claude/todos/ findings"},
      {label: "Skill issue", description: "Repair a broken or incorrect skill"},
      {label: "PR comments", description: "Resolve unresolved PR review comments"},
      {label: "Bug report", description: "Validate and fix a reported bug"},
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
    {content: "Identify fix target", status: "in_progress", activeForm: "Identifying target"},
    {content: "Analyze issue", status: "pending", activeForm: "Analyzing issue"},
    {content: "Implement fix", status: "pending", activeForm: "Implementing fix"},
    {content: "Validate fix", status: "pending", activeForm: "Validating fix"},
    {content: "Run CI", status: "pending", activeForm: "Running CI"}
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
    question: "What would you like to fix?",
    header: "Target",
    options: [
      {label: "Pending todos (Recommended)", description: "Work through .claude/todos/ findings"},
      {label: "Skill issue", description: "Repair a broken or incorrect skill"},
      {label: "PR comments", description: "Resolve unresolved PR review comments"},
      {label: "Bug report", description: "Validate and fix a reported bug"},
      {label: "Describe issue", description: "I'll explain what needs fixing"}
    ],
    multiSelect: false
  }]
})
```

### Phase 2: Route to Workflow

**Fix Pending Todos:**

```javascript
// Find pending todos
Glob({pattern: ".claude/todos/*-pending-*.md"})

// Create TodoWrite for tracking
TodoWrite({
  todos: [
    {content: "Fix P1: [finding 1]", status: "in_progress", activeForm: "Fixing P1 issue"},
    {content: "Fix P2: [finding 2]", status: "pending", activeForm: "Fixing P2 issue"},
    // ... one per finding
  ]
})

// For each pending todo:
// 1. Read the finding
Read({file_path: ".claude/todos/001-pending-p1-type-error.md"})

// 2. Implement the fix
Edit({file_path: "...", old_string: "...", new_string: "..."})

// 3. Rename: *-pending-* → *-complete-*
Bash({command: "mv .claude/todos/001-pending-p1-type-error.md .claude/todos/001-complete-p1-type-error.md"})
```

**Fix Skill Issue:**

Use the skill-healer agent:

```javascript
Task({
  subagent_type: "skill-healer",
  prompt: `CONTEXT: Skill maintenance
SCOPE: Analyze and heal skill: ${skillName}
CONSTRAINTS: Identify what's wrong, research correct patterns
OUTPUT: Before/after diffs for each change

Tools:
- Glob({pattern: ".claude/skills/${skillName}/**/*.md"})
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

**Fix PR Comments:**

Use the pr-comment-resolver agent:

```javascript
Task({
  subagent_type: "pr-comment-resolver",
  prompt: `CONTEXT: PR review resolution
SCOPE: Resolve comments on PR: ${prNumber}
CONSTRAINTS: Address each comment, prepare commits
OUTPUT: List of changes made per comment

Tools:
- Glob/Grep/Read for file exploration
- Edit for changes
- Bash for git commands`,
  description: "PR comment resolution",
  run_in_background: false
})
```

**Fix Bug Report:**

Use the bug-reproduction-validator agent:

```javascript
Task({
  subagent_type: "bug-reproduction-validator",
  prompt: `CONTEXT: Bug validation and fix
SCOPE: Validate and fix bug: ${bugDescription}
CONSTRAINTS: Reproduce first, then fix
OUTPUT: Reproduction steps, root cause, fix

Tools:
- Glob/Grep/Read for codebase exploration
- Bash for running tests
- Edit for fix implementation`,
  description: "Bug fix",
  run_in_background: false
})
```

### Phase 3: Validate

```javascript
// Run CI
Bash({command: "bun run ci", description: "Run CI checks"})

// Update progress
TodoWrite({
  todos: [
    // ... previous completed
    {content: "Run CI", status: "completed", activeForm: "Running CI"}
  ]
})
```

### Phase 4: Confirm Completion

```javascript
AskUserQuestion({
  questions: [{
    question: "Fix applied and CI passing. What's next?",
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

- [ ] AskUserQuestion determines fix type
- [ ] TodoWrite tracks all fixes
- [ ] Appropriate agent used for fix type
- [ ] Native tools used (not bash grep/find/cat)
- [ ] MCP tools used for documentation (Context7)
- [ ] CI passing
- [ ] AskUserQuestion confirms completion
