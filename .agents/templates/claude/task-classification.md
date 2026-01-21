## Task Classification

Classify before implementation. When in doubt, classify up.

**Execution Mode:** Check `CLAUDE_CODE_REMOTE` env var. If `true` → Remote Mode (autonomous). See Hard Requirements for adjustments.

### Rules
1. New file => at least Simple (never Trivial).
2. Multiple files => at least Standard.
3. Security/auth/payments => Complex.
4. Uncertain => up.

### Categories (minimum steps / may skip)
- **Trivial:** single-line/typo/comment only. Steps: TodoWrite(in_progress) -> Implementation -> Verification -> TodoWrite(completed). May skip: plan refinement, review, deep reasoning.
- **Simple:** single file, clear scope; new file ok. Steps: TodoWrite, Planning (1 pass), Implementation, Testing/syntax check, Verification skill, TodoWrite(completed). May skip: deep reasoning, security review, multi-iteration review.
- **Standard:** multi-file/behavior change. Steps: all phases, minimum 2 iterations each. Skip none.
- **Complex:** architectural/cross-cutting/security-sensitive. Steps: all phases, 5+ iterations each. Skip none.

### Checklists (output immediately after classification)

#### Trivial
```
CLASSIFICATION: Trivial

REQUIRED SKILLS (invoke Skill() tool before GATE-3):
- [ ] verification-before-completion

REQUIRED PHASES:
- [ ] Phase 3: Implementation (TodoWrite -> Code -> TodoWrite)
- [ ] Phase 7: Verification (min 1 iteration)

ITERATION TRACKING:
- Plan Refinement: 0 required
- Review: 0 required
- Verification: 1 required | Completed: ___
```

#### Simple
```
CLASSIFICATION: Simple
MODE: [Local|Remote] ← check CLAUDE_CODE_REMOTE

REQUIRED SKILLS (invoke Skill() tool - checklist is not loading):
- [ ] verification-before-completion — invoke before GATE-3
- [ ] test-driven-development — invoke before GATE-3
- [ ] ask-questions-if-underspecified — invoke before GATE-2 (Local: ask always | Remote: ask only if ambiguous)

REQUIRED PHASES (output gate with PROOF before each):
- [ ] Phase 1: Planning (1 pass) → GATE-1
- [ ] Phase 2: Plan Refinement (1 pass) → GATE-2 ⚠️ DON'T SKIP
- [ ] Phase 3: Implementation → GATE-3
- [ ] Phase 5: Testing → GATE-5
- [ ] Phase 6: Review (1 pass) → GATE-6 ⚠️ DON'T SKIP
- [ ] Phase 7: Verification → GATE-7

ITERATION TRACKING:
- Plan Refinement: 1 required | Completed: ___
- Review: 1 required | Completed: ___
- Verification: 1 required | Completed: ___

SELF-CHECKS:
- Before GATE-2: search context for `Skill.*ask-questions`. If not found, STOP.
- Before GATE-3: search context for `Skill.*test-driven`. If not found, STOP.
- Before GATE-5: verify test file exists or explain why tests N/A.
- Before GATE-6: search context for `Skill.*review`. If not found, STOP.
```

#### Standard
```
CLASSIFICATION: Standard
MODE: [Local|Remote] ← check CLAUDE_CODE_REMOTE

REQUIRED SKILLS (invoke Skill() tool - checklist is not loading):
- [ ] verification-before-completion — invoke before GATE-3
- [ ] test-driven-development — invoke before GATE-3
- [ ] ask-questions-if-underspecified — invoke before GATE-2 (Local: ask always | Remote: ask only if ambiguous)

REQUIRED PHASES (output gate with PROOF before each):
- [ ] Phase 1: Planning → GATE-1
- [ ] Phase 2: Plan Refinement (2+) → GATE-2 ⚠️ TRACK ITERATIONS
- [ ] Phase 3: Implementation → GATE-3
- [ ] Phase 4: Cleanup → GATE-4
- [ ] Phase 5: Testing → GATE-5
- [ ] Phase 6: Review (2+) → GATE-6 ⚠️ TRACK ITERATIONS
- [ ] Phase 7: Verification (2+) → GATE-7 ⚠️ TRACK ITERATIONS

ITERATION TRACKING:
- Plan Refinement: 2+ required | Completed: ___
- Review: 2+ required | Completed: ___
- Verification: 2+ required | Completed: ___

SELF-CHECKS:
- Before GATE-2: search context for `Skill.*ask-questions`. If not found, STOP.
- Before GATE-3: search context for `Skill.*test-driven`. If not found, STOP.
- Before GATE-5: verify test file exists or explain why tests N/A.
- Before GATE-6: search context for `Skill.*review`. If not found, STOP.
```

#### Complex
```
CLASSIFICATION: Complex
MODE: [Local|Remote] ← check CLAUDE_CODE_REMOTE

REQUIRED SKILLS (invoke Skill() tool - checklist is not loading):
- [ ] verification-before-completion — invoke before GATE-3
- [ ] test-driven-development — invoke before GATE-3
- [ ] ask-questions-if-underspecified — invoke before GATE-2 (Local: ask always | Remote: ask only if ambiguous)
- [ ] systematic-debugging — invoke if modifying existing code
- [ ] differential-review — invoke before GATE-6

REQUIRED PHASES (output gate with PROOF before each):
- [ ] Phase 1: Planning (with mcp__codex) → GATE-1
- [ ] Phase 2: Plan Refinement (5+) → GATE-2 ⚠️ TRACK ITERATIONS
- [ ] Phase 3: Implementation → GATE-3
- [ ] Phase 4: Cleanup → GATE-4
- [ ] Phase 5: Testing → GATE-5
- [ ] Phase 6: Review (5+, security) → GATE-6 ⚠️ TRACK ITERATIONS
- [ ] Phase 7: Verification (5+) → GATE-7 ⚠️ TRACK ITERATIONS

ITERATION TRACKING:
- Plan Refinement: 5+ required | Completed: ___
- Review: 5+ required | Completed: ___
- Verification: 5+ required | Completed: ___

SELF-CHECKS:
- Before GATE-2: search context for `Skill.*ask-questions`. If not found, STOP.
- Before GATE-3: search context for `Skill.*test-driven`. If not found, STOP.
- Before GATE-5: verify test file exists or explain why tests N/A.
- Before GATE-6: search context for `Skill.*review` or `Skill.*differential-review`. If not found, STOP.
```
