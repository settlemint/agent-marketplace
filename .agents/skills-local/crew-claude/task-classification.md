## Task Classification

Classify before implementation. When in doubt, classify up.

**Execution Mode:** Check `CLAUDE_CODE_REMOTE` env var. If `true` → Remote Mode (autonomous). See Hard Requirements for adjustments.

### Rules
1. New file => at least Simple (never Trivial).
2. Multiple files => Standard.
3. Security/auth/payments => Standard (with extra security review).
4. Uncertain => up.

### Categories (minimum steps / may skip)
- **Trivial:** single-line/typo/comment only. Steps: Create gate tasks (Implementation, Verification, CI, Integration only) -> TaskCreate -> TaskUpdate(in_progress) -> Implementation -> Update Implementation -> Verification -> Update Verification, CI, Integration -> TaskUpdate(completed). May skip: plan refinement, review, deep reasoning.
- **Simple:** single file, clear scope; new file ok. Steps: Create 8 gate tasks (skip Cleanup) -> TaskCreate -> TaskUpdate(in_progress), Planning (1 pass) -> Update Planning, Implementation -> Update Implementation, Testing/syntax check -> Update Testing, Verification skill, codex review -> Update Review, Verification, CI, Integration, TaskUpdate(completed). May skip: deep reasoning, multi-iteration review.
- **Standard:** multi-file/behavior change/architectural/security-sensitive. Steps: Create all 9 gate tasks -> all phases with gate task updates, 5+ iterations each, mcp__codex for planning, differential-review, codex review. Skip none.

### Task Management Tools

**Primary (Claude Code with Tasks support):**
- `TaskCreate` - Create tasks with subject, description, activeForm
- `TaskUpdate` - Update status (pending → in_progress → completed), add dependencies
- `TaskList` - View all tasks and their status
- `TaskGet` - Retrieve full task details by ID

**Fallback (older Conductor without Tasks):**
- `TodoWrite({ status: "in_progress" })` - Mark work starting
- `TodoWrite({ status: "completed" })` - Mark work done

**Detection:** If TaskCreate/TaskList tools are unavailable, use TodoWrite fallback.

### After Classification: Create Gate Tasks via TodoWrite

Output only `CLASSIFICATION: [type]` then immediately create gate tasks. No verbose checklists.

#### Trivial — 4 gates
```typescript
TodoWrite([
  { content: "Implementation", status: "pending", activeForm: "Implementing" },
  { content: "Verification", status: "pending", activeForm: "Verifying" },
  { content: "CI", status: "pending", activeForm: "Running CI" },
  { content: "Integration", status: "pending", activeForm: "Running integration tests" },
])
```
Skills: verification-before-completion

#### Simple — 8 gates (skip Cleanup)
```typescript
TodoWrite([
  { content: "Planning", status: "pending", activeForm: "Planning" },
  { content: "Refinement", status: "pending", activeForm: "Refining" },
  { content: "Implementation", status: "pending", activeForm: "Implementing" },
  { content: "Testing", status: "pending", activeForm: "Testing" },
  { content: "Review", status: "pending", activeForm: "Reviewing" },
  { content: "Verification", status: "pending", activeForm: "Verifying" },
  { content: "CI", status: "pending", activeForm: "Running CI" },
  { content: "Integration", status: "pending", activeForm: "Running integration tests" },
])
```
Skills: verification-before-completion, test-driven-development, ask-questions-if-underspecified

#### Standard — 9 gates with iteration sub-tasks
```typescript
TodoWrite([
  { content: "Planning", status: "pending", activeForm: "Planning" },
  { content: "Refinement", status: "pending", activeForm: "Refining" },
  { content: "Implementation", status: "pending", activeForm: "Implementing" },
  { content: "Cleanup", status: "pending", activeForm: "Cleaning up" },
  { content: "Testing", status: "pending", activeForm: "Testing" },
  { content: "Review", status: "pending", activeForm: "Reviewing" },
  { content: "Verification", status: "pending", activeForm: "Verifying" },
  { content: "CI", status: "pending", activeForm: "Running CI" },
  { content: "Integration", status: "pending", activeForm: "Running integration tests" },
])
```
Skills: verification-before-completion, test-driven-development, ask-questions-if-underspecified, systematic-debugging (if modifying existing code), differential-review

**Iteration sub-tasks (Standard only):** When starting Refinement, Review, or Verification, create 5 iteration sub-tasks:
```typescript
// Example for Refinement
TodoWrite([
  { content: "Refinement", status: "in_progress", activeForm: "Refining" },
  { content: "Refinement iteration 1", status: "pending", activeForm: "Iteration 1" },
  { content: "Refinement iteration 2", status: "pending", activeForm: "Iteration 2" },
  { content: "Refinement iteration 3", status: "pending", activeForm: "Iteration 3" },
  { content: "Refinement iteration 4", status: "pending", activeForm: "Iteration 4" },
  { content: "Refinement iteration 5", status: "pending", activeForm: "Iteration 5" },
])
```
Parent gate can only be completed when all iteration sub-tasks are completed.

#### Plan Mode — Planning and Refinement only; remaining gates after approval
```typescript
TodoWrite([
  { content: "Planning", status: "pending", activeForm: "Planning" },
  { content: "Refinement", status: "pending", activeForm: "Refining" },
])
// After plan approval, create Implementation through Integration gates
```
