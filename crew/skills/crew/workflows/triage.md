---
name: crew:triage
description: Triage and categorize findings for the CLI todo system
argument-hint: "[optional: filter by source type or priority]"
---

# Triage Command

Process pending todos with interactive approval.

## Workflow

**IMPORTANT:** Execute this workflow directly in the main thread. Do NOT delegate to an orchestrator agent - this preserves native UI components like AskUserQuestion.

### Phase 1: Load Pending Todos

1. Find all pending todos:

```bash
ls -la .claude/todos/*-pending-*.md 2>/dev/null || echo "No pending todos"
```

1. Create progress tracking:

```
TodoWrite([
  {content: "Load pending todos", status: "completed", activeForm: "Loading todos"},
  {content: "Triage each finding", status: "in_progress", activeForm: "Triaging findings"},
  {content: "Summarize decisions", status: "pending", activeForm: "Summarizing"},
  {content: "Optionally resolve approved", status: "pending", activeForm: "Resolving approved"}
])
```

### Phase 2: Triage Each Finding (Main Thread - Native UI)

For each pending todo file, read it and present to user:

```
AskUserQuestion({
  questions: [{
    question: "[P1/P2/P3] [Category]: [Brief description]\n\nLocation: [file:line]\nProposed fix: [summary]\nEffort: [estimate]",
    header: "Triage",
    options: [
      {label: "Approve", description: "Mark as ready to fix"},
      {label: "Skip", description: "Delete this finding"},
      {label: "Modify priority", description: "Change P1/P2/P3"},
      {label: "See details", description: "Show full todo content"}
    ],
    multiSelect: false
  }]
})
```

**On Approve:** Rename file from `*-pending-*` to `*-ready-*`
**On Skip:** Delete the todo file
**On Modify:** Update priority in filename and content

### Phase 3: Summarize Results

After all todos processed:

```markdown
## Triage Summary

- **Approved:** X findings ready to fix
- **Skipped:** Y findings removed
- **Modified:** Z findings reprioritized

### Ready Todos:

1. [P1] file:line - description
2. [P2] file:line - description
   ...
```

### Phase 4: Resolution Option (Main Thread - Native UI)

```
AskUserQuestion({
  questions: [{
    question: "Would you like to resolve the approved todos now?",
    header: "Resolve",
    options: [
      {label: "Resolve all", description: "Fix all approved todos (parallel agents)"},
      {label: "Resolve P1 only", description: "Fix only critical issues"},
      {label: "Done for now", description: "Save for later with /crew:work"}
    ],
    multiSelect: false
  }]
})
```

If resolving, group todos by file first to prevent parallel agents from overwriting each other:

```javascript
// Step 1: Group todos by the file they modify
const todosByFile = {};
for (const todo of readyTodos) {
  const file = todo.location.split(":")[0];
  if (!todosByFile[file]) todosByFile[file] = [];
  todosByFile[file].push(todo);
}

// Step 2: Launch ONE agent per unique file (not per todo!)
for (const [file, todos] of Object.entries(todosByFile)) {
  Task({
    subagent_type: "pr-comment-resolver",
    prompt: `Fix ALL these issues in ${file}:\n${formatTodosForFile(todos)}`,
    run_in_background: true,
  });
}
```

**CRITICAL:** Multiple todos affecting the same file MUST be handled by one agent to prevent overwrites.

Collect results and update files to `*-complete-*`.

**MANDATORY: Create handoff for resolved todos:**

```javascript
Skill({ skill: "crew:handoff", args: "triage Resolved [N] todos: [brief summary]" });
```

This captures patterns and learnings from the fixes.

**Note:** The handoff command will prompt for compounding, capturing patterns from the fixes.

## Key Principles

1. **Keep UI in main thread** - AskUserQuestion for each triage decision
2. **Agents for resolution only** - Fixing happens in background agents
3. **No coding during triage** - Triage is decision-making, not implementation

## Usage

```bash
/crew:triage                    # Process all pending todos
/crew:triage P1                 # Filter to P1 only
/crew:triage code-review        # Filter by source type
```

## Key Commands After Triage

```bash
ls .claude/todos/*-ready-*.md         # View approved todos
ls .claude/todos/*-pending-*.md       # View remaining pending
```
