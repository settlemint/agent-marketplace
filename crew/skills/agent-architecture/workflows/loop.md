---
name: crew:loop
description: Start an iteration loop for autonomous task completion
argument-hint: "PROMPT [--max-iterations N] [--completion-promise TEXT]"
---

# Loop Command

Start an autonomous iteration loop that continues until completion criteria are met.

## Arguments

<arguments>$ARGUMENTS</arguments>

## Overview

This is an internal implementation of the Ralph Wiggum technique - a self-referential feedback loop where the same prompt is repeatedly fed to Claude. The prompt never changes between iterations, but Claude's previous work persists in files, allowing autonomous improvement by reading past work.

## Workflow

### Phase 1: Parse Arguments

Extract from arguments:
- `prompt` - The task description (required)
- `--max-iterations N` - Stop after N iterations (default: 10)
- `--completion-promise TEXT` - Phrase that signals completion (optional)

### Phase 2: Initialize Loop State

Create/update unified state file at `.claude/branches/{branch}/state.json`:

```bash
BRANCH=$(git branch --show-current | tr '/' '-')
mkdir -p ".claude/branches/$BRANCH"
```

Update the `loop` section in unified state:

```json
{
  "branch": "feat-example",
  "loop": {
    "active": true,
    "iteration": 1,
    "maxIterations": 10,
    "completionPromise": "COMPLETE",
    "prompt": "The original prompt...",
    "startedAt": "2024-01-01T00:00:00Z"
  }
}
```

### Phase 3: Display Loop Instructions

Output critical instructions for the loop:

```
═══════════════════════════════════════════════════════════
ITERATION LOOP STARTED (1 of {maxIterations})
═══════════════════════════════════════════════════════════

TASK:
{prompt}

COMPLETION CRITERIA:
To complete this loop, output this EXACT text:
  <promise>{completionPromise}</promise>

STRICT REQUIREMENTS:
  ✓ Use <promise> XML tags EXACTLY as shown
  ✓ The statement MUST be completely TRUE
  ✓ Do NOT output false statements to exit
  ✓ If blocked, document blockers instead of lying

HANDOFF INTEGRATION:
  This loop integrates with /crew:handoff
  - Each iteration can create task handoffs
  - Loop state survives workflow transitions
  - Use /crew:cancel-loop to stop early

═══════════════════════════════════════════════════════════
```

### Phase 4: Execute Task

Now work on the task. The Stop hook will:
1. Intercept when you try to complete
2. Check if `<promise>{completionPromise}</promise>` was output
3. If not complete and iterations remain, increment and re-feed the prompt
4. If complete or max iterations reached, end the loop

## Loop State Location

State is stored in unified branch state:
```
.claude/branches/{branch}/state.json
```

The loop state is in the `loop` section of this file. This ensures:
- Loop survives `/crew:handoff` transitions
- Loop survives `/crew:compound` calls
- Loop state is unified with all other branch state
- Multiple branches can have independent loops
- Session recovery restores loop state automatically

## Parameters

| Parameter | Default | Description |
|-----------|---------|-------------|
| `--max-iterations` | 10 | Safety limit on iterations |
| `--completion-promise` | "COMPLETE" | Text that signals genuine completion |

## Best Practices

### 1. Clear Completion Criteria

```bash
/crew:loop "Build REST API for todos.

When complete:
- All CRUD endpoints working
- Tests passing (bun run test)
- CI passing (bun run ci)
- Output: <promise>COMPLETE</promise>" --max-iterations 15
```

### 2. Incremental Goals

```bash
/crew:loop "Implement feature in phases:
Phase 1: Database schema and migrations
Phase 2: API endpoints with validation
Phase 3: Tests with >80% coverage

After EACH phase, run: bun run ci
Output <promise>ALL PHASES DONE</promise> when complete." --max-iterations 20
```

### 3. With Handoffs

```bash
/crew:loop "Implement auth system per .claude/plans/auth.md

After completing each task:
1. Run tests: bun run test
2. Create handoff: /crew:handoff task [description]

Output <promise>AUTH COMPLETE</promise> when all tasks done." --max-iterations 25
```

## When to Use

**Good for:**
- Well-defined tasks with clear success criteria
- Tasks requiring iteration (getting tests to pass)
- Tasks with automatic verification (tests, linters, CI)
- Following a plan with multiple phases

**Not good for:**
- Tasks requiring human judgment
- One-shot operations
- Unclear success criteria
- Exploratory research

## Stopping Early

Use `/crew:cancel-loop` to stop the loop gracefully:
- Creates a handoff documenting progress
- Clears loop state
- Returns control to you

## Integration with Workflows

This loop integrates with the full workflow system:

```
/crew:plan → creates plan file
     ↓
/crew:loop → iterates until complete
     ↓ (during loop)
/crew:handoff → captures task completions
     ↓ (after loop)
/crew:compound → extracts learnings
```

## Usage

```bash
# Basic loop
/crew:loop "Implement feature X" --max-iterations 10

# With completion promise
/crew:loop "Fix all failing tests" --completion-promise "ALL TESTS PASS" --max-iterations 20

# Following a plan
/crew:loop "Execute .claude/plans/my-feature.md" --completion-promise "PLAN COMPLETE" --max-iterations 30
```
