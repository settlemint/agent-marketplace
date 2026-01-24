# Parallel Review Dispatch

Template for dispatching focused review agents in parallel during Phase 6.

## Overview

Instead of generic iterations, dispatch three specialized reviewers that run concurrently:

| Agent | Focus | Output |
|-------|-------|--------|
| Simplicity Reviewer | YAGNI, LOC reduction | `VERDICT: PASS \| NEEDS_SIMPLIFICATION` |
| Completeness Reviewer | Spec compliance | `VERDICT: PASS \| INCOMPLETE \| OVERBUILT` |
| Quality Reviewer | Patterns, security, perf | `VERDICT: PASS \| NEEDS_FIXES` |

## Step 1: Create Review Tasks (REQUIRED)

Use native Task tools to create trackable review tasks:

```
TaskCreate({
  subject: "[R001] [P] Simplicity review of changed files",
  description: "Apply simplicity-reviewer.md to changed files. Output VERDICT.",
  activeForm: "Running simplicity review"
})

TaskCreate({
  subject: "[R002] [P] Completeness review against requirements",
  description: "Apply completeness-reviewer.md to verify all requirements implemented. Output VERDICT.",
  activeForm: "Running completeness review"
})

TaskCreate({
  subject: "[R003] [P] Quality review for patterns/security/performance",
  description: "Apply quality-reviewer.md to changed files. Output VERDICT with P1/P2 counts.",
  activeForm: "Running quality review"
})
```

**Key points:**
- `[P]` marker indicates parallelizable (no dependencies)
- `activeForm` shows in spinner while running
- Tasks are tracked via `TaskList()`

## Step 2: Parallel Dispatch (CRITICAL)

**ALL THREE in a SINGLE message = parallel execution:**

```
Task({
  subagent_type: "general-purpose",
  description: "Simplicity review",
  prompt: `You are the Simplicity Reviewer.

1. First, run: TaskUpdate({ taskId: "R001", status: "in_progress" })

2. Read and follow: .agents/skills-local/crew-claude/iterations/simplicity-reviewer.md

3. Apply the review to these changed files: [LIST FILES HERE]

4. Create TaskCreate() for any fix tasks needed

5. Output the review in the specified format with VERDICT

6. Finally, run: TaskUpdate({ taskId: "R001", status: "completed" })`
})

Task({
  subagent_type: "general-purpose",
  description: "Completeness review",
  prompt: `You are the Completeness Reviewer.

1. First, run: TaskUpdate({ taskId: "R002", status: "in_progress" })

2. Read and follow: .agents/skills-local/crew-claude/iterations/completeness-reviewer.md

3. The original user request was: [QUOTE THE REQUEST HERE]

4. Verify all requirements are implemented and tested

5. Create TaskCreate() for any gaps found

6. Output the review in the specified format with VERDICT

7. Finally, run: TaskUpdate({ taskId: "R002", status: "completed" })`
})

Task({
  subagent_type: "general-purpose",
  description: "Quality review",
  prompt: `You are the Quality Reviewer.

1. First, run: TaskUpdate({ taskId: "R003", status: "in_progress" })

2. Read and follow: .agents/skills-local/crew-claude/iterations/quality-reviewer.md

3. Apply the review to these changed files: [LIST FILES HERE]

4. Create TaskCreate() for any P1/P2 findings

5. Output the review in the specified format with VERDICT

6. Finally, run: TaskUpdate({ taskId: "R003", status: "completed" })`
})
```

**WHY SINGLE MESSAGE MATTERS:**
- Multiple Task() in ONE message = parallel execution
- Multiple Task() in SEPARATE messages = sequential execution
- Parallel = 3x faster review

## Step 3: Wait and Verify

After dispatching, verify all tasks complete:

```
TaskList()
```

Expected output:
```
[R001] Simplicity review — completed ✓
[R002] Completeness review — completed ✓
[R003] Quality review — completed ✓
[FIX-001] Remove unused imports... — pending
[FIX-002] Add null handling... — pending
```

## Step 4: Aggregate Results

Combine verdicts from all three reviewers:

```
## Phase 6 Review Aggregation

### Reviewer Verdicts
| Reviewer | Verdict | Key Findings | Fix Tasks |
|----------|---------|--------------|-----------|
| Simplicity | [PASS/NEEDS_SIMPLIFICATION] | [summary] | [count] |
| Completeness | [PASS/INCOMPLETE/OVERBUILT] | [summary] | [count] |
| Quality | [PASS/NEEDS_FIXES] | [summary] | [count] |

### Fix Tasks Created
Run `TaskList()` to see all pending fix tasks

### Overall Status: [PASS / BLOCKED]
```

## Step 5: GATE-6 Output

```
GATE-6 CHECK:
- [x] Simplicity review — PROOF: [VERDICT] - [key findings]
- [x] Completeness review — PROOF: [VERDICT] - [requirements N/N]
- [x] Quality review — PROOF: [VERDICT] - [P1: N, P2: N]
- [x] All review tasks completed — PROOF: TaskList shows R001-R003 completed
- [x] Fix tasks tracked — PROOF: N fix tasks created via TaskCreate
STATUS: PASS | BLOCKED

Blocked by: [list any NEEDS_* verdicts and pending fix tasks]
```

## Iteration Handling

If any reviewer returns a `NEEDS_*` verdict:

1. **View pending fix tasks:** `TaskList()`
2. **Work on fix tasks:**
   ```
   TaskUpdate({ taskId: "FIX-001", status: "in_progress" })
   // ... make the fix ...
   TaskUpdate({ taskId: "FIX-001", status: "completed" })
   ```
3. **Re-run ONLY failed reviewer(s)** — single Task() call
4. **Update gate output** with new verdicts
5. **Repeat** until all PASS or user accepts current state

## Example Flow

```
Phase 6 Start
    │
    ├── TaskCreate × 3: [R001] [P], [R002] [P], [R003] [P]
    │
    ├── TaskList: 3 pending review tasks
    │
    ├── Dispatch 3 reviewers IN SINGLE MESSAGE (parallel)
    │   ├── Simplicity ─── TaskUpdate in_progress → ... → completed → PASS
    │   ├── Completeness ── TaskUpdate in_progress → ... → TaskCreate [FIX-001] → completed → INCOMPLETE
    │   └── Quality ─────── TaskUpdate in_progress → ... → TaskCreate [FIX-002] → completed → PASS
    │
    ├── TaskList: R001-R003 completed, FIX-001/FIX-002 pending
    │
    ├── Work on FIX-001: TaskUpdate in_progress → fix → completed
    │
    ├── Work on FIX-002: TaskUpdate in_progress → fix → completed
    │
    ├── Re-dispatch Completeness only (single Task call)
    │   └── Completeness ── PASS
    │
    ├── TaskList: All completed
    │
    └── GATE-6: STATUS: PASS
```

## Parallelism Checklist

**Before dispatching:**
- [ ] TaskCreate called for all 3 review tasks with [P] marker
- [ ] All three Task() calls prepared for SINGLE message
- [ ] Changed files list ready for simplicity/quality prompts
- [ ] Original request quoted for completeness prompt

**During dispatch:**
- [ ] ALL THREE Task() calls in ONE message (not separate messages!)
- [ ] Each prompt includes TaskUpdate in_progress at start
- [ ] Each prompt includes TaskUpdate completed at end
- [ ] Each prompt includes TaskCreate for findings

**After dispatch:**
- [ ] TaskList() to verify R001-R003 completed
- [ ] Aggregate verdicts from all three
- [ ] Address any fix tasks created
- [ ] Re-run failed reviewers if needed
