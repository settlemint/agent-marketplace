## Task Classification

Classify before implementation. When in doubt, classify up.

**Execution Mode:** Check `CLAUDE_CODE_REMOTE` env var. If `true` → Remote Mode (autonomous). See Hard Requirements for adjustments.

### Rules
1. New file => at least Simple (never Trivial).
2. Multiple files => Standard.
3. Security/auth/payments => Standard (with extra security review).
4. Uncertain => up.

### Categories (minimum steps / may skip)
- **Trivial:** single-line/typo/comment only. Steps: Create gate tasks (GATE-3,7,8,9 only) -> TaskCreate -> TaskUpdate(in_progress) -> Implementation -> Update [GATE-3] -> Verification -> Update [GATE-7,8,9] -> TaskUpdate(completed). May skip: plan refinement, review, deep reasoning.
- **Simple:** single file, clear scope; new file ok. Steps: Create 8 gate tasks (skip GATE-4) -> TaskCreate -> TaskUpdate(in_progress), Planning (1 pass) -> Update [GATE-1], Implementation -> Update [GATE-3], Testing/syntax check -> Update [GATE-5], Verification skill, codex review -> Update [GATE-6,7,8,9], TaskUpdate(completed). May skip: deep reasoning, multi-iteration review.
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
  { content: "[GATE-3] Implementation", status: "pending", activeForm: "Implementing" },
  { content: "[GATE-7] Verification", status: "pending", activeForm: "Verifying" },
  { content: "[GATE-8] CI", status: "pending", activeForm: "Running CI" },
  { content: "[GATE-9] Integration", status: "pending", activeForm: "Running integration tests" },
])
```
Skills: verification-before-completion

#### Simple — 8 gates (skip GATE-4)
```typescript
TodoWrite([
  { content: "[GATE-1] Planning", status: "pending", activeForm: "Planning" },
  { content: "[GATE-2] Refinement", status: "pending", activeForm: "Refining" },
  { content: "[GATE-3] Implementation", status: "pending", activeForm: "Implementing" },
  { content: "[GATE-5] Testing", status: "pending", activeForm: "Testing" },
  { content: "[GATE-6] Review", status: "pending", activeForm: "Reviewing" },
  { content: "[GATE-7] Verification", status: "pending", activeForm: "Verifying" },
  { content: "[GATE-8] CI", status: "pending", activeForm: "Running CI" },
  { content: "[GATE-9] Integration", status: "pending", activeForm: "Running integration tests" },
])
```
Skills: verification-before-completion, test-driven-development, ask-questions-if-underspecified

#### Standard — 9 gates with iteration sub-tasks
```typescript
TodoWrite([
  { content: "[GATE-1] Planning", status: "pending", activeForm: "Planning" },
  { content: "[GATE-2] Refinement", status: "pending", activeForm: "Refining" },
  { content: "[GATE-3] Implementation", status: "pending", activeForm: "Implementing" },
  { content: "[GATE-4] Cleanup", status: "pending", activeForm: "Cleaning up" },
  { content: "[GATE-5] Testing", status: "pending", activeForm: "Testing" },
  { content: "[GATE-6] Review", status: "pending", activeForm: "Reviewing" },
  { content: "[GATE-7] Verification", status: "pending", activeForm: "Verifying" },
  { content: "[GATE-8] CI", status: "pending", activeForm: "Running CI" },
  { content: "[GATE-9] Integration", status: "pending", activeForm: "Running integration tests" },
])
```
Skills: verification-before-completion, test-driven-development, ask-questions-if-underspecified, systematic-debugging (if modifying existing code), differential-review

**Iteration sub-tasks (Standard only):** When starting GATE-2, GATE-6, or GATE-7, create 5 iteration sub-tasks:
```typescript
// Example for GATE-2 Refinement
TodoWrite([
  { content: "[GATE-2] Refinement", status: "in_progress", activeForm: "Refining" },
  { content: "[GATE-2.1] Refinement iteration 1", status: "pending", activeForm: "Iteration 1" },
  { content: "[GATE-2.2] Refinement iteration 2", status: "pending", activeForm: "Iteration 2" },
  { content: "[GATE-2.3] Refinement iteration 3", status: "pending", activeForm: "Iteration 3" },
  { content: "[GATE-2.4] Refinement iteration 4", status: "pending", activeForm: "Iteration 4" },
  { content: "[GATE-2.5] Refinement iteration 5", status: "pending", activeForm: "Iteration 5" },
])
```
Parent gate can only be completed when all iteration sub-tasks are completed.

#### Plan Mode — GATE-1,2 only; remaining gates after approval
```typescript
TodoWrite([
  { content: "[GATE-1] Planning", status: "pending", activeForm: "Planning" },
  { content: "[GATE-2] Refinement", status: "pending", activeForm: "Refining" },
])
// After plan approval, create [GATE-3] through [GATE-9]
```
