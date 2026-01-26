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

### Checklists (output immediately after classification)

#### Trivial
```
CLASSIFICATION: Trivial

GATE TASKS (create after classification):
- [ ] TaskCreate [GATE-3] Implementation
- [ ] TaskCreate [GATE-7] Verification (blockedBy: GATE-3)
- [ ] TaskCreate [GATE-8] CI (blockedBy: GATE-7)
- [ ] TaskCreate [GATE-9] Integration (blockedBy: GATE-8)

REQUIRED SKILLS (invoke Skill() tool before [GATE-3] completion):
- [ ] verification-before-completion

REQUIRED PHASES (update gate task to completed with proof):
- [ ] Phase 3: Implementation → update [GATE-3] to completed
- [ ] Phase 7: Verification → update [GATE-7] to completed
- [ ] Phase 8: CI Validation → update [GATE-8] to completed
- [ ] Phase 9: Integration Tests → update [GATE-9] to completed

ITERATION TRACKING:
- Plan Refinement: 0 required
- Review: 0 required
- Verification: 1 required | Completed: ___
```

#### Simple
```
CLASSIFICATION: Simple
MODE: [Local|Remote] ← check CLAUDE_CODE_REMOTE

GATE TASKS (create after classification — Simple skips GATE-4 Cleanup):
- [ ] TaskCreate [GATE-1] Planning
- [ ] TaskCreate [GATE-2] Refinement (blockedBy: GATE-1)
- [ ] TaskCreate [GATE-3] Implementation (blockedBy: GATE-2)
- [ ] TaskCreate [GATE-5] Testing (blockedBy: GATE-3)  // GATE-4 skipped for Simple
- [ ] TaskCreate [GATE-6] Review (blockedBy: GATE-5)
- [ ] TaskCreate [GATE-7] Verification (blockedBy: GATE-6)
- [ ] TaskCreate [GATE-8] CI (blockedBy: GATE-7)
- [ ] TaskCreate [GATE-9] Integration (blockedBy: GATE-8)

REQUIRED SKILLS (invoke Skill() tool - checklist is not loading):
- [ ] verification-before-completion — invoke before [GATE-3] completion
- [ ] test-driven-development — invoke before [GATE-3] completion
- [ ] ask-questions-if-underspecified — invoke before [GATE-2] completion (Local: ask always | Remote: ask only if ambiguous)

REQUIRED PHASES (update gate task to completed with proof in description):
- [ ] Phase 1: Planning (1 pass) → update [GATE-1] to completed
- [ ] Phase 2: Plan Refinement (1 pass) → update [GATE-2] to completed ⚠️ DON'T SKIP
- [ ] Phase 3: Implementation → update [GATE-3] to completed
- [ ] Phase 5: Testing → update [GATE-5] to completed
- [ ] Phase 6: Review (1 pass, codex) → update [GATE-6] to completed ⚠️ DON'T SKIP CODEX
- [ ] Phase 7: Verification → update [GATE-7] to completed
- [ ] Phase 8: CI Validation → update [GATE-8] to completed
- [ ] Phase 9: Integration Tests → update [GATE-9] to completed

ITERATION TRACKING:
- Plan Refinement: 1 required | Completed: ___
- Review: 1 required | Completed: ___
- Verification: 1 required | Completed: ___

SELF-CHECKS:
- Before [GATE-2] completion: search context for `Skill.*ask-questions`. If not found, STOP.
- Before [GATE-3] completion: search context for `Skill.*test-driven`. If not found, STOP.
- Before [GATE-5] completion: verify test file exists or explain why tests N/A.
- Before [GATE-6] completion: search context for `Skill.*review`. If not found, STOP.
- Before [GATE-6] completion: verify `codex review --uncommitted` will be run. If skipped, STOP.
```

#### Standard
```
CLASSIFICATION: Standard
MODE: [Local|Remote] ← check CLAUDE_CODE_REMOTE

GATE TASKS (create all 9 after classification with blockedBy chain):
- [ ] TaskCreate [GATE-1] Planning
- [ ] TaskCreate [GATE-2] Refinement (blockedBy: GATE-1)
- [ ] TaskCreate [GATE-3] Implementation (blockedBy: GATE-2)
- [ ] TaskCreate [GATE-4] Cleanup (blockedBy: GATE-3)
- [ ] TaskCreate [GATE-5] Testing (blockedBy: GATE-4)
- [ ] TaskCreate [GATE-6] Review (blockedBy: GATE-5)
- [ ] TaskCreate [GATE-7] Verification (blockedBy: GATE-6)
- [ ] TaskCreate [GATE-8] CI (blockedBy: GATE-7)
- [ ] TaskCreate [GATE-9] Integration (blockedBy: GATE-8)

REQUIRED SKILLS (invoke Skill() tool - checklist is not loading):
- [ ] verification-before-completion — invoke before [GATE-3] completion
- [ ] test-driven-development — invoke before [GATE-3] completion
- [ ] ask-questions-if-underspecified — invoke before [GATE-2] completion (Local: ask always | Remote: ask only if ambiguous)
- [ ] systematic-debugging — invoke if modifying existing code
- [ ] differential-review — invoke before [GATE-6] completion

REQUIRED PHASES (update gate task to completed with proof in description):
- [ ] Phase 1: Planning (with mcp__codex) → update [GATE-1] to completed
- [ ] Phase 2: Plan Refinement (5+) → update [GATE-2] to completed ⚠️ TRACK ITERATIONS
- [ ] Phase 3: Implementation → update [GATE-3] to completed
- [ ] Phase 4: Cleanup → update [GATE-4] to completed
- [ ] Phase 5: Testing → update [GATE-5] to completed
- [ ] Phase 6: Review (5+, security, codex) → update [GATE-6] to completed ⚠️ TRACK ITERATIONS
- [ ] Phase 7: Verification (5+) → update [GATE-7] to completed ⚠️ TRACK ITERATIONS
- [ ] Phase 8: CI Validation → update [GATE-8] to completed
- [ ] Phase 9: Integration Tests → update [GATE-9] to completed

ITERATION TRACKING:
- Plan Refinement: 5+ required | Completed: ___
- Review: 5+ required | Completed: ___
- Verification: 5+ required | Completed: ___

SELF-CHECKS:
- Before [GATE-2] completion: search context for `Skill.*ask-questions`. If not found, STOP.
- Before [GATE-3] completion: search context for `Skill.*test-driven`. If not found, STOP.
- Before [GATE-5] completion: verify test file exists or explain why tests N/A.
- Before [GATE-6] completion: search context for `Skill.*review` or `Skill.*differential-review`. If not found, STOP.
- Before [GATE-6] completion: verify `codex review --uncommitted` will be run. If skipped, STOP.
```
