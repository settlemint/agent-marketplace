---
name: crew:build
description: Execute work plans with iteration loops and progress tracking
argument-hint: "[plan file, specification, or todo file path]"
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/build-context.sh`

## Input

<work_document>$ARGUMENTS</work_document>

## Native Tools

### TodoWrite - Track Progress (CRITICAL)

```javascript
TodoWrite({
  todos: [
    {content: "Load work document", status: "in_progress", activeForm: "Loading document"},
    {content: "Set up branch", status: "pending", activeForm: "Setting up branch"},
    {content: "Implement phase 1", status: "pending", activeForm: "Implementing phase 1"},
    {content: "Run tests", status: "pending", activeForm: "Running tests"},
    {content: "Run quality checks", status: "pending", activeForm: "Running quality checks"},
    {content: "Create PR", status: "pending", activeForm: "Creating PR"}
  ]
})
```

**Update IMMEDIATELY after each task. Never batch updates.**

### Task - Spawn Parallel Agents

```javascript
// Quality checks in SINGLE message
Task({
  subagent_type: "typescript-reviewer",
  prompt: `CONTEXT: Quality check for ${feature}
SCOPE: Review: ${changedFiles}
OUTPUT: P1/P2/P3 findings`,
  description: "TS review",
  run_in_background: true
})

Task({
  subagent_type: "security-sentinel",
  prompt: `CONTEXT: Security audit
SCOPE: ${changedFiles}
OUTPUT: Vulnerabilities`,
  description: "Security",
  run_in_background: true
})
```

### AskUserQuestion - Decision Points

```javascript
AskUserQuestion({
  questions: [{
    question: "Tests passed. Ready to proceed?",
    header: "Ship",
    options: [
      {label: "Create PR (Recommended)", description: "Commit, push, open PR"},
      {label: "Commit only", description: "Save without PR"},
      {label: "Review changes", description: "Show diff first"},
      {label: "More work needed", description: "Continue editing"}
    ],
    multiSelect: false
  }]
})
```

## Process

### Phase 1: Load Work Document

```javascript
// Start tracking
TodoWrite({
  todos: [
    {content: "Load work document", status: "in_progress", activeForm: "Loading document"},
    // ...
  ]
})

// Read the plan
Read({file_path: ".claude/plans/${planSlug}.md"})

// If not found, ask
AskUserQuestion({
  questions: [{
    question: "Which plan should we build?",
    header: "Plan",
    options: [
      // List available plans from Glob
    ],
    multiSelect: false
  }]
})
```

### Phase 2: Parse and Create Tasks

```javascript
// Extract tasks from plan acceptance criteria
// Create granular TodoWrite

TodoWrite({
  todos: [
    {content: "Load work document", status: "completed", activeForm: "Loading document"},
    {content: "Set up branch", status: "in_progress", activeForm: "Setting up branch"},
    // Tasks from plan:
    {content: "[Task 1 from plan]", status: "pending", activeForm: "Implementing task 1"},
    {content: "[Task 2 from plan]", status: "pending", activeForm: "Implementing task 2"},
    {content: "Run tests", status: "pending", activeForm: "Running tests"},
    {content: "Run quality agents", status: "pending", activeForm: "Running quality checks"},
    {content: "Create PR", status: "pending", activeForm: "Creating PR"}
  ]
})
```

### Phase 3: Environment Setup

```javascript
// Ensure on feature branch
Bash({command: "git checkout -b feature/${slug} 2>/dev/null || git checkout feature/${slug}"})

// Update progress
TodoWrite({
  todos: [
    {content: "Load work document", status: "completed", activeForm: "Loading document"},
    {content: "Set up branch", status: "completed", activeForm: "Setting up branch"},
    {content: "[Task 1]", status: "in_progress", activeForm: "Implementing task 1"},
    // ...
  ]
})
```

### Phase 4: Implementation Loop

For each task in the plan:

```javascript
// 1. Mark in_progress
TodoWrite({todos: [/* ... task in_progress */]})

// 2. Find relevant files
Glob({pattern: "src/**/*.ts"})
Grep({pattern: "relevantPattern", type: "ts"})

// 3. For structural patterns, use ast-grep skill
Bash({command: 'sg -p "async function $FUNC($$$)" -l typescript'})

// 4. Read and understand
Read({file_path: "/project/src/file.ts"})

// 5. Implement with Edit/Write
Edit({file_path: path, old_string: "...", new_string: "..."})

// 6. Run tests after EACH change
Bash({command: "bun run test", description: "Run tests"})

// 7. Mark completed immediately
TodoWrite({todos: [/* ... task completed */]})
```

### Phase 5: Quality Checks

Launch quality agents in **SINGLE message**:

```javascript
Task({
  subagent_type: "typescript-reviewer",
  prompt: `CONTEXT: Quality check for ${feature}
SCOPE: Review changed files: ${changedFiles.join(', ')}
CONSTRAINTS: Type safety, patterns, testability
OUTPUT: P1/P2/P3 findings with file:line

Tools: Glob, Grep, Read (not bash)`,
  description: "TypeScript review",
  run_in_background: true
})

Task({
  subagent_type: "security-sentinel",
  prompt: `CONTEXT: Security audit for ${feature}
SCOPE: Audit: ${changedFiles.join(', ')}
CONSTRAINTS: OWASP Top 10
OUTPUT: Vulnerabilities with severity

MCP: Codex for deep threat analysis`,
  description: "Security audit",
  run_in_background: true
})

Task({
  subagent_type: "code-simplicity-reviewer",
  prompt: `CONTEXT: Simplicity check for ${feature}
SCOPE: ${changedFiles.join(', ')}
CONSTRAINTS: YAGNI, complexity
OUTPUT: Simplification opportunities`,
  description: "Simplicity review",
  run_in_background: true
})

// Collect results
const tsResults = TaskOutput({task_id: "ts-id", block: true})
const secResults = TaskOutput({task_id: "sec-id", block: true})
const simpResults = TaskOutput({task_id: "simp-id", block: true})
```

### Phase 6: Address Findings

If quality issues found:

```javascript
TodoWrite({
  todos: [
    // ... previous completed
    {content: "Fix type error in auth.ts:42", status: "in_progress", activeForm: "Fixing type error"},
    {content: "Address security finding", status: "pending", activeForm: "Fixing security issue"},
    {content: "Create PR", status: "pending", activeForm: "Creating PR"}
  ]
})
```

### Phase 7: Final Validation

```javascript
// Run full CI
Bash({command: "bun run ci", description: "Run CI checks"})
```

### Phase 8: Ship It

```javascript
AskUserQuestion({
  questions: [{
    question: "All checks pass. Ready to ship?",
    header: "Ship",
    options: [
      {label: "Create PR (Recommended)", description: "Commit, push, and open PR"},
      {label: "Commit only", description: "Create commit without PR"},
      {label: "Review diff", description: "Show changes before committing"},
      {label: "More work needed", description: "Continue editing"}
    ],
    multiSelect: false
  }]
})

// If creating PR:
Bash({
  command: `git add . && git commit -m "$(cat <<'EOF'
feat(${scope}): ${description}

${body}
EOF
)" && git push -u origin ${branch}`,
  description: "Commit and push"
})

Bash({
  command: `gh pr create --title "${title}" --body "$(cat <<'EOF'
## Summary
${summary}

## Test Plan
${testPlan}
EOF
)"`,
  description: "Create PR"
})
```

## Success Criteria

- [ ] TodoWrite tracks ALL progress (updated after EVERY task)
- [ ] Native tools used for file operations (not bash find/grep/cat)
- [ ] Tests run after EACH significant change
- [ ] Quality agents launched in parallel (single message)
- [ ] MCP tools used where appropriate
- [ ] AskUserQuestion at key decision points
- [ ] PR created with conventional commit
