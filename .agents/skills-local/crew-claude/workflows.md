## Development Workflow

Mandatory for implementation tasks. Creating any new file = implementation task. Only exception: pure research/exploration with no artifacts.

### Plan Mode Workflow

When `system-reminder` indicates "Plan mode is active":

1. Output `CLASSIFICATION: [type]`
2. Create gate tasks via TodoWrite: `[GATE-1] Planning`, `[GATE-2] Refinement`
3. Mark [GATE-1] in_progress → do research → mark completed
4. Mark [GATE-2] in_progress → write plan → mark completed
5. Call ExitPlanMode
6. After approval: create remaining gates ([GATE-3] through [GATE-9])

---

### Task Management

Use TodoWrite for all task tracking. Task list is the source of truth.

**Task format:** `[T001] [P] Description with file path`
- `[P]` = parallelizable (different files, no dependencies)

**Sub-agents:** Multiple `Task()` calls in one message = parallel execution

**Principles**
- Use latest package versions (@latest/:latest)
- MANY small tasks > few large tasks

### Phase 1: Planning
Mark [GATE-1] in_progress, then completed when done.
- Gather context (Explore Task for large codebases)
- Check docs (mcp__context7__*) and web (mcp__exa__*)
- Draft plan with file paths and tasks

### Phase 2: Plan Refinement
Mark [GATE-2] in_progress. **Standard tasks:** create 5 iteration sub-tasks.
- `Skill({ skill: "ask-questions-if-underspecified" })`
- Use `AskUserQuestion` tool (Local: always ask; Remote: only if ambiguous)
- Mark each iteration sub-task completed as you go
- Mark [GATE-2] completed when all iterations done

### Phase 3: Implementation
Mark [GATE-3] in_progress, then completed when skills loaded and tasks created.
- `Skill({ skill: "test-driven-development" })`
- `Skill({ skill: "verification-before-completion" })`
- Create implementation tasks: `[T001] [P] Description with file path`
- RED → GREEN → REFACTOR for each task
- If 2+ tasks marked `[P]`, dispatch parallel Task agents

### Phase 4: Cleanup
Mark [GATE-4] in_progress, then completed.
- `code-simplifier`, `deslop`, `knip` (JS/TS only)

### Phase 5: Testing
Mark [GATE-5] in_progress, then completed with test output.
- Run `bun run ci` from repository root
- Show exit code

### Phase 6: Review
Mark [GATE-6] in_progress. **Standard tasks:** create 5 iteration sub-tasks.
- `Skill({ skill: "review" })`
- `codex review --uncommitted` (required for Simple+)
- Mark each iteration sub-task completed as you go
- Mark [GATE-6] completed when all iterations done

### Codex AI Review (Simple/Standard)

Run after review skill: `codex review --uncommitted`
- Fix P1/P2 issues before proceeding

### Phase 7: Verification
Mark [GATE-7] in_progress. **Standard tasks:** create 5 iteration sub-tasks.
- Execute `Skill({ skill: "verification-before-completion" })`
- Run verification commands with exit code 0
- Mark each iteration sub-task completed as you go
- Mark [GATE-7] completed when all iterations done

### Phase 8: CI Validation
Mark [GATE-8] in_progress, then completed with CI results.
- Run `bun run ci` from repository root
- Show exit code 0

### Phase 9: Integration Tests
Mark [GATE-9] in_progress, then completed.
- Run `bun run test:integration` (if available)
- Show exit code 0 or note N/A

**Completion:** Task list must show all gates completed before claiming done.
