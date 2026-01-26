---
name: crew-claude
description: Complete development workflow for Claude Code
---

# Crew Claude

Complete development workflow for Claude Code. Defines philosophy, task classification, hard requirements, anti-patterns, and 9-gate development process.

---

## 1. Philosophy

This codebase will outlive you. Every shortcut you take becomes someone else's burden. Every hack compounds into technical debt that slows the whole team down.

You are not just writing code. You are shaping the future of this project. The patterns you establish will be copied. The corners you cut will be cut again.

Fight entropy. Leave the codebase better than you found it.

### Non-negotiables
- Ship production-grade, scalable (>1000 users) implementations; avoid MVP/minimal shortcuts.
- Optimize for long-term sustainability: maintainable, reliable designs.
- Make changes the single canonical implementation in the primary codepath; delete legacy/dead/duplicate paths as part of delivery.
- Use direct, first-class integrations; do not introduce shims, wrappers, glue code, or adapter layers.
- Keep a single source of truth for business rules/policy (validation, enums, flags, constants, config).
- Clean API invariants: define required inputs, validate up front, fail fast.
- Use latest stable libs/docs; if unsure, do a web search.

### Coding Style
- Target <=500 LOC (hard cap 750; imports/types excluded).
- Keep UI/markup nesting <=3 levels; extract components/helpers when JSX/templating repeats, responsibilities pile up, or variant/conditional switches grow.

### Security Guards
- No delete/move/overwrite without explicit user request; for deletions prefer `trash` over `rm`.
- Don't expose secrets in code/logs; use env/secret stores.
- Validate/sanitize untrusted input to prevent injection, path traversal, SSRF, and unsafe uploads.
- Enforce AuthN/AuthZ and tenant boundaries; least privilege.
- Be cautious with new dependencies; flag supply-chain/CVE risk.

---

## 2. Task Classification

Classify before implementation. When in doubt, classify up.

**Execution Mode:** Check `CLAUDE_CODE_REMOTE` env var. If `true` → Remote Mode (autonomous). See Hard Requirements for adjustments.

### Rules
1. New file => at least Simple (never Trivial).
2. Multiple files => Standard.
3. Security/auth/payments => Standard (with extra security review).
4. Uncertain => up.

### Categories
- **Trivial:** single-line/typo/comment only. May skip: plan refinement, review.
- **Simple:** single file, clear scope; new file ok. May skip: deep reasoning.
- **Standard:** multi-file/behavior change/architectural/security-sensitive. Skip none.

### After Classification: Create Gate Tasks via TodoWrite

Output only `CLASSIFICATION: [type]` then immediately create gate tasks. No verbose checklists.

#### Trivial — gates + execution tasks
```typescript
TodoWrite([
  { content: "Implementation", status: "pending", activeForm: "Implementing" },
  { content: "Run verification commands", status: "pending", activeForm: "Running verification" },
  { content: "Verification", status: "pending", activeForm: "Verifying" },
  { content: "CI", status: "pending", activeForm: "Running CI" },
  { content: "Integration", status: "pending", activeForm: "Running integration tests" },
])
```

#### Simple — gates + execution tasks (skip Cleanup)
```typescript
TodoWrite([
  { content: "Planning", status: "pending", activeForm: "Planning" },
  { content: "Refinement", status: "pending", activeForm: "Refining" },
  { content: "Write failing tests (TDD red)", status: "pending", activeForm: "Writing failing tests" },
  { content: "Implementation", status: "pending", activeForm: "Implementing" },
  { content: "Make tests pass (TDD green)", status: "pending", activeForm: "Making tests pass" },
  { content: "Testing", status: "pending", activeForm: "Testing" },
  { content: "Run codex review --uncommitted", status: "pending", activeForm: "Running codex review" },
  { content: "Fix P1/P2 codex issues", status: "pending", activeForm: "Fixing codex issues" },
  { content: "Review", status: "pending", activeForm: "Reviewing" },
  { content: "Run verification commands", status: "pending", activeForm: "Running verification" },
  { content: "Verification", status: "pending", activeForm: "Verifying" },
  { content: "CI", status: "pending", activeForm: "Running CI" },
  { content: "Integration", status: "pending", activeForm: "Running integration tests" },
])
```

#### Standard — 9 gates + ALL execution tasks
```typescript
TodoWrite([
  { content: "Planning", status: "pending", activeForm: "Planning" },
  { content: "Ask clarifying questions", status: "pending", activeForm: "Asking questions" },
  { content: "Refinement", status: "pending", activeForm: "Refining" },
  { content: "Write failing tests (TDD red)", status: "pending", activeForm: "Writing failing tests" },
  { content: "Implementation", status: "pending", activeForm: "Implementing" },
  { content: "Make tests pass (TDD green)", status: "pending", activeForm: "Making tests pass" },
  { content: "Run deslop on changed files", status: "pending", activeForm: "Running deslop" },
  { content: "Run code-simplifier", status: "pending", activeForm: "Running code-simplifier" },
  { content: "Cleanup", status: "pending", activeForm: "Cleaning up" },
  { content: "Testing", status: "pending", activeForm: "Testing" },
  { content: "Run review skill workflow", status: "pending", activeForm: "Running review workflow" },
  { content: "Run reviewers skill prompts", status: "pending", activeForm: "Running reviewers prompts" },
  { content: "Run codex review --uncommitted", status: "pending", activeForm: "Running codex review" },
  { content: "Fix P1/P2 codex issues", status: "pending", activeForm: "Fixing codex issues" },
  { content: "Run codeql security scan", status: "pending", activeForm: "Running codeql scan" },
  { content: "Fix codeql findings", status: "pending", activeForm: "Fixing codeql findings" },
  { content: "Review", status: "pending", activeForm: "Reviewing" },
  { content: "Run verification commands", status: "pending", activeForm: "Running verification" },
  { content: "Verification", status: "pending", activeForm: "Verifying" },
  { content: "CI", status: "pending", activeForm: "Running CI" },
  { content: "Integration", status: "pending", activeForm: "Running integration tests" },
  { content: "Run workflow-improver analysis", status: "pending", activeForm: "Running workflow analysis" },
])
```

**Execution tasks require evidence:** Each execution task must show command output, diff, or scan results before marking complete.

#### Plan Mode — Planning and Refinement only; remaining gates after approval
```typescript
TodoWrite([
  { content: "Planning", status: "pending", activeForm: "Planning" },
  { content: "Refinement", status: "pending", activeForm: "Refining" },
])
// After plan approval, create remaining gates + execution tasks based on classification
```

---

## 3. Hard Requirements (No Exceptions)

### Execution Mode Detection

Check `CLAUDE_CODE_REMOTE` environment variable at session start:
- `CLAUDE_CODE_REMOTE=true` → **Remote Mode** (autonomous, minimal interaction)
- Otherwise → **Local Mode** (interactive, full questioning)

**Remote Mode Adjustments:**
- Phase 2 questioning is **optional** - only ask if genuinely ambiguous
- "Requirements are clear" is **allowed** (not a banned phrase)
- `ask-questions-if-underspecified` skill: load but only act if ambiguity score > 7/10
- All other gates, skills, and quality requirements remain **unchanged**

**ALWAYS**
- **Output classification checklist as ABSOLUTE FIRST action** - before any tools, exploration, or planning.
- **If Plan Mode active, classification precedes exploration** - create gate tasks and update Planning after classification.
- **Classification determines which gates are required** - Trivial needs fewer, Standard needs more.
- **Task tracking before implementation:** Use `TaskCreate` to create tasks, `TaskUpdate({ status: "in_progress" })` before starting work.
- **Task completion after implementation:** Use `TaskUpdate({ status: "completed" })` after each task is done.
- **Task dependencies:** Use `TaskUpdate({ addBlockedBy: [...] })` to establish task ordering.
- **Fallback:** If Tasks tools unavailable (older Conductor), use `TodoWrite({ status: "in_progress/completed" })`.
- **Create gate tasks after classification** — see Task Classification section for exact TodoWrite patterns.
- Provide verification evidence (command output/test results with exit code 0) before claiming done.
- **Use `AskUserQuestion` tool for ALL clarifying questions** - never plain text questions.
- **Use `AskUserQuestion` tool for ALL decision-seeking questions** - phrases that seek user input MUST use the tool:
  - "Would you like..." → AskUserQuestion
  - "Should we/I..." (when seeking decision) → AskUserQuestion
  - "Do you want..." → AskUserQuestion
  - "Could you clarify..." → AskUserQuestion
  - "Which option..." → AskUserQuestion
- **Consider parallel Task agents** when 2+ independent implementation tasks exist.
- **Use Task `mode` parameter** appropriately: `plan` for risky changes, `bypassPermissions` for trusted autonomous work.
- **Parallelize independent tasks** after plan approval — tasks without `blockedBy` can run in parallel via multiple `Task()` calls in one message. See `dispatching-parallel-agents` skill.

**NEVER**
- **Start exploration/planning without classification output** - classification is FIRST.
- **Proceed with tool calls before stating classification** - no exceptions.
- Skip phases/gates because "simple" or "trivial".
- Skip Phase 2 (Plan Refinement) or Phase 6 (Review) - commonly forgotten.
- Write production code before creating/updating tasks (TaskCreate or TodoWrite fallback).
- Claim completion without evidence.
- Skip task dependency setup when tasks have ordering requirements.
- Skip skills or "acknowledge" them without loading via Skill() tool.
- Say "Done", "should work", or "looks good" without evidence.
- Proceed past a gate without meeting requirements.
- Mark a gate task completed without meeting all requirements.
- Complete a gate task without proof in description.
- **Ask clarifying questions in plain text** - MUST use `AskUserQuestion` tool.
- **Ask decision questions in plain text** - if your message contains "Would you like", "Should we", "Do you want", or similar decision-seeking phrases followed by "?", you MUST use `AskUserQuestion` tool instead of inline text.
- **Execute independent tasks sequentially** when parallel agents could be used.
- You do NOT have the permission to change linter settings, and ignore statements are severely discouraged. Especially the no barrel files rule!

### No Text Checklists (MANDATORY)

**Text checklists don't work.** Claude forgets requirements that aren't tracked as Tasks/Todos.

Every required action MUST be a TodoWrite item. Never state requirements only in prose or markdown checkboxes.

**Wrong:**
```markdown
- [ ] Run codex review
- [ ] Fix P1/P2 issues
```

**Right:**
```typescript
TodoWrite([
  { content: "Run codex review --uncommitted", status: "pending", activeForm: "Running codex review" },
  { content: "Fix P1/P2 codex issues", status: "pending", activeForm: "Fixing codex issues" },
])
```

**Execution tasks require evidence:** Each task must show command output, diff, or results before marking complete.

### Test Backfilling (MANDATORY)

When modifying existing code:
- **If file has no tests → add tests BEFORE modifying**
- Applies to: bug fixes, refactors, behavior changes, any file touch
- TDD execution tasks ("Write failing tests", "Make tests pass") enforce this

### Classification Output (MANDATORY)

Output ONLY this single line, then create gate tasks via TodoWrite:

```
CLASSIFICATION: [Trivial|Simple|Standard]
```

No verbose checklists. The task list IS the tracking mechanism.

### Gate Task Creation (MANDATORY)

Immediately after classification, create gate tasks AND execution tasks via TodoWrite. See Task Classification section for exact patterns per classification type.

| Classification | What to Create |
|---------------|----------------|
| **Trivial** | 4 gates + verification execution task |
| **Simple** | 8 gates + TDD tasks + codex review tasks + verification task |
| **Standard** | 9 gates + ALL execution tasks (TDD, deslop, code-simplifier, review skill, reviewers, codex review, codeql, verification, workflow-improver) |
| **Plan Mode** | Planning, Refinement initially; remaining gates + execution tasks after approval |

**Key principle:** If it's not a TodoWrite item, it won't happen.

### Gate Task Status

| Status | When | Description |
|--------|------|-------------|
| pending | Not started | — |
| in_progress | Working on it | — |
| completed | Done with proof | — |

### Phase Gates (MANDATORY - ALL OF THEM)

Before each phase, update the corresponding gate task. Do not proceed if BLOCKED. Do not skip gates.

⚠️ **Gate task neglect is a failure mode.** You must update EVERY applicable gate task, not just early ones.

⚠️ **Gate rushing is a failure mode.** Each gate completed requires proof in the description.

**Gate requirements (gate cannot complete until execution tasks show evidence):**

- **Planning**: `PASS: Classification=[type] | Research=[tools used]`
  - Requirements: classification stated + research complete (mcp__octocode__* for code, mcp__context7__* for docs, mcp__exa__* for web).

- **Refinement**: `PASS: Questions=[count or N/A if Remote]`
  - Requirements: "Ask clarifying questions" task completed with evidence. **Local:** `AskUserQuestion` tool used. **Remote:** questions optional unless genuinely ambiguous.

- **Implementation**: `PASS: TDD=[red+green done] | Backfill=[done/N/A]`
  - Requirements: "Write failing tests (TDD red)" task completed + "Make tests pass (TDD green)" task completed + backfill check done.

- **Cleanup**: `PASS: Deslop=[done] | Simplifier=[done]`
  - Requirements: "Run deslop on changed files" task completed with diff shown + "Run code-simplifier" task completed (Standard only).

- **Testing**: `PASS: Tests=[N passed, N failed] | Exit=[code]`
  - Requirements: test output with exit code shown.

- **Review**: `PASS: Review=[done] | Reviewers=[done] | Codex=[P1:N P2:N fixed] | CodeQL=[done]`
  - Requirements (Simple): "Run codex review --uncommitted" + "Fix P1/P2 codex issues" tasks completed with evidence.
  - Requirements (Standard): Above + "Run review skill workflow" + "Run reviewers skill prompts" + "Run codeql security scan" + "Fix codeql findings" all completed with evidence.

- **Verification**: `PASS: Commands=[run] | Exit=[0]`
  - Requirements: "Run verification commands" task completed with exit code 0 shown.

- **CI**: `PASS: CI=[command] | Exit=[0]`
  - Requirements: `bun run ci` executed with exit code 0 shown.
  - **NOTE:** CI commands use turborepo—run from repository root folder.
  - **NOTE:** Infrastructure services may be required—launch with `bun dev:up`.

- **Integration**: `PASS: Integration=[Exit 0 or N/A]`
  - Requirements: `bun run test:integration` executed with exit code 0 (or N/A if unavailable).
  - **Prerequisite:** CI must pass first.

- **Session End (Standard only)**: `PASS: Workflow-improver=[done]`
  - Requirements: "Run workflow-improver analysis" task completed with session analysis output shown.

**Execution ≠ Loading:** Calling `Skill()` just loads instructions. The execution task tracks actually DOING what the skill documents.

### Pre-Completion Gate

Before claiming done, the task list must show all gate tasks as completed. No exceptions.

**Banned phrases:** "looks good", "should work", "Done!", "it's just a port", "manual review", "pre-existing", "not related to my changes"

**Failure deflection (ZERO TOLERANCE):** Any claim that failures are "pre-existing" or "not related to my changes" is FORBIDDEN. Main always passes. If anything fails, you broke it.

### Plan Mode Integration

When `system-reminder` indicates "Plan mode is active":

1. **First**: Output classification checklist (same as always)
2. **Then**: Create gate tasks and update Planning to in_progress, then completed when research done
3. **Then**: Update Refinement to in_progress, then completed when plan written
4. **Finally**: Call ExitPlanMode when plan is complete

**Plan Mode maps to workflow phases:**
- Planning → Phase 1 (Planning)
- Refinement → Phase 2 (Plan Refinement)
- After approval → Phase 3+ (Implementation onwards, create remaining gate tasks)

**Plan Mode does NOT exempt you from:**
- Classification output (still FIRST)
- Gate task creation (create Planning and Refinement minimum, rest after approval)
- Skill loading (ask-questions-if-underspecified before Refinement completion)
- AskUserQuestion tool usage (never plain text questions)

---

## 4. Anti-Patterns (Never)

### Workflow Bypass
- Trivial bypass: "task is simple" to skip workflow -> classify first and follow minimum steps.
- Direct implementation: code before task tracking -> call `TaskCreate` + `TaskUpdate({ status: "in_progress" })` first (or `TodoWrite` fallback).
- Classification avoidance: no classification before implementation -> state classification before first task creation.
- Task dependency skip: ignoring task ordering -> use `TaskUpdate({ addBlockedBy: [...] })` for dependent tasks.
- Task status neglect: not updating task status -> always set in_progress before work, completed after.

### Text Checklist Theater (CRITICAL)

**Text checklists don't work.** Claude forgets requirements that aren't tracked as Tasks/Todos.

- **Text requirements:** stating requirements in prose without creating todos → EVERY requirement must be a TodoWrite item
- **Markdown checkboxes:** outputting `- [ ] Do X` without calling TodoWrite → call TodoWrite, not markdown
- **Self-check in context:** "search context for X" → use TodoWrite execution tasks, not context search
- **Gate without execution tasks:** creating Review gate without "Run codex review" task → execution must be tracked
- **Skill load without execute:** calling `Skill()` but not doing what it documents → TodoWrite tracks EXECUTION, not loading
- **Marking execution complete without evidence:** "Run codeql scan" marked done without showing output → must show results

**The rule:** If it's not a TodoWrite item, it won't happen. Period.

### Skill Failures
- Skill avoidance: no execution tasks for skills → create execution tasks like "Run codex review --uncommitted"
- Skill mention vs execute: "I'll use TDD" without executing TDD workflow → complete "Write failing tests" and "Make tests pass" tasks
- **Load without execute:** invoked Skill() but didn't complete the execution task → loading is step 1, execution (with evidence) is what counts
- **TDD theater:** marked "Write failing tests" complete without showing failing test output → evidence required
- **Fake ask-questions:** marked "Ask clarifying questions" complete without using AskUserQuestion → tool usage required (Remote: N/A is acceptable)
- **Plain text questions:** asked questions in markdown instead of `AskUserQuestion` tool → FORBIDDEN

### Decision Question Patterns (MUST use AskUserQuestion)

These phrases in assistant messages = VIOLATION if not using the tool:
- `Would you like me to...?` → Use AskUserQuestion with options
- `Should we...?` / `Should I...?` → Use AskUserQuestion with yes/no or options
- `Do you want...?` → Use AskUserQuestion with options
- `Which would you prefer...?` → Use AskUserQuestion with the options listed
- `Could you clarify...?` → Use AskUserQuestion
- `What should I...?` → Use AskUserQuestion with options

**ALLOWED without tool** (rhetorical/explanatory):
- Questions analyzing the problem: "The question is whether X works with Y..."
- Questions in code comments or documentation
- Questions quoting the user back to them

### Gate Task Failures
- Gate task amnesia: create Planning, Implementation, then forget the rest -> create ALL gate tasks for your classification with blockedBy chain.
- Gate task rushing: marking gate completed without doing the work -> gates verify work, not skip it.
- Proofless completion: `status: completed` without proof in description -> add `PASS: [key]=[evidence] | ...` to description.
- Early gate only: stop at Implementation because "implementation is done" -> Cleanup through Integration still required.
- False completion: marking gate completed when requirements not met -> keep in_progress with `BLOCKED: [reason]` in description.
- Gate task skip: not creating gate tasks at all -> MUST create all required gates after classification.

### Phase Skipping
- Phase 2 skip: "requirements are clear" → Local: complete "Ask clarifying questions" task. Remote: mark N/A if ambiguity ≤ 7.
- Phase 6 skip: "code is simple, doesn't need review" → ALL review execution tasks must complete with evidence.
- **Codex skip:** "Run codex review" task not completed with output shown → BLOCKED. Show the codex output.
- **Deslop skip:** "Run deslop" task skipped "because code is clean" → run it anyway, show output.
- **Codeql skip:** (Standard) "Run codeql scan" task skipped → BLOCKED for Standard tasks.
- **Workflow-improver skip:** (Standard) "Run workflow-improver" task not completed at session end → session incomplete.

### Verification Failures
- Unverified completion: "Run verification commands" task not completed with exit code 0 shown → execute and show output.
- Partial verification: "syntax check passed" as full verification → run project CI, show full output.
- Stale evidence: "tests passed earlier" → run fresh verification, show current output.
- Execution task incomplete: "Run verification commands" marked complete without showing command output → evidence required.
- CI skip: CI task not completed with `bun run ci` exit code 0 shown → CI must pass for all classifications.

### Implementation Failures
- **Sequential when parallel possible:** executing 2+ independent tasks one-by-one with Bash -> use parallel Task agents.
- **Bash familiarity bias:** defaulting to sequential bash "because it's simpler" -> check skill routing table for `dispatching-parallel-agents`.
- **Agent avoidance:** "file operations are quick" to skip parallel agents -> if tasks are independent, parallelize.
- **Unnamed agents:** spawning agents without `name` parameter -> use names for tracking (e.g., `name: "test-runner"`).
- **Overly permissive mode:** using `mode: "bypassPermissions"` for risky/security tasks -> use `mode: "plan"` for changes requiring review.
- **Mode omission:** not specifying mode when context requires it -> explicitly set `mode` based on task risk level.

### Failure Deflection (CRITICAL)

**THIS IS THE MOST SEVERE ANTI-PATTERN. ZERO TOLERANCE.**

Applies to: CI failures, test failures, lint errors, type errors, build failures, ANY verification failure.

- **"Pre-existing issues":** claiming failures are "not related to my changes" or "pre-existing in the codebase" -> ABSOLUTELY FORBIDDEN. Main branch ALWAYS passes (otherwise PRs cannot merge). If anything fails, YOUR changes broke it.
- **"My tests pass":** claiming success because "the specific tests I created pass" while ignoring other failures -> UNACCEPTABLE. ALL tests must pass. 19 passing tests mean nothing if 1 test fails.
- **"Module resolution issues":** claiming type errors or import failures are "pre-existing module issues" -> LIES. The codebase compiles on main. You broke it.
- **Blame shifting:** any variation of "those errors existed before" or "that's a different module" -> LIES. You own the ENTIRE outcome. Fix it or revert your changes.
- **Scope limitation:** "not in scope of this PR" for ANY failure -> WRONG. If it fails, it IS in scope. Period.
- **Partial success claims:** "implementation is complete, just some unrelated issues" -> NOTHING is complete until everything passes.
- **Selective reporting:** showing only your passing tests while hiding lint/type/other failures -> DISHONEST. Show ALL output.

**The rule is absolute:** If ANY verification (tests, lint, types, build, CI) does not pass, you have NOT completed the task. There are no exceptions. There are no "pre-existing issues" in a working main branch. If it fails now, you fix it now.

### Evidence Failures
- Implied evidence: "I ran the tests" without showing output -> paste actual command output.
- Exit code assumption: "command succeeded" without checking -> show exit code 0 explicitly.
- Selective evidence: showing passing tests, hiding failures -> show full output.

### Completion Check

**Before claiming done, verify ALL execution tasks are completed with evidence:**

Run through your TodoWrite list:
- Every gate task (Planning → Integration) shows completed
- Every execution task shows completed WITH evidence shown in conversation:
  - "Write failing tests" → test output showing failure
  - "Make tests pass" → test output showing pass
  - "Run deslop" → diff or "no slop found"
  - "Run codex review" → codex output shown
  - "Fix P1/P2 issues" → issues fixed or "none found"
  - "Run codeql scan" → scan output shown (Standard)
  - "Run verification" → commands with exit code 0
  - "Run workflow-improver" → analysis output shown (Standard)

If ANY execution task lacks evidence, you are NOT done.

### Task Management Failures
- Orphan tasks: creating tasks without tracking completion -> run `TaskList` before claiming done.
- Stale task list: not checking TaskList after subagent work -> always verify task status after delegation.
- Missing dependencies: parallel tasks that should be sequential -> define blockedBy relationships.
- Tool confusion: mixing Tasks and TodoWrite in same session -> use one system consistently per session.
- Gate task orphans: creating gate tasks without completing them -> all gate tasks must show status: completed with "PASS:" before done.
- Gate dependency skip: creating gates without blockedBy chain -> gates must have proper dependency order (Refinement blockedBy Planning, etc.).

---

## 5. Workflows

Mandatory for implementation tasks. Creating any new file = implementation task. Only exception: pure research/exploration with no artifacts.

### Plan Mode Workflow

When `system-reminder` indicates "Plan mode is active":

1. Output `CLASSIFICATION: [type]`
2. Create gate tasks via TodoWrite: `Planning`, `Refinement`
3. Mark Planning in_progress → do research → mark completed
4. Mark Refinement in_progress → write plan → mark completed
5. Call ExitPlanMode
6. After approval: create remaining gates + ALL execution tasks based on classification (see Task Classification section)

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
Mark Planning in_progress, then completed when done.
- Gather context (Explore Task for large codebases)
- Check docs (mcp__context7__*) and web (mcp__exa__*)
- Draft plan with file paths and tasks

### Phase 2: Plan Refinement
Mark Refinement in_progress.

**Execution task:** "Ask clarifying questions"
1. `Skill({ skill: "ask-questions-if-underspecified" })` to load instructions
2. Execute: Use `AskUserQuestion` tool (Local: always; Remote: only if ambiguous)
3. Mark "Ask clarifying questions" completed with evidence (questions asked or N/A)

**Codex plan review Task (Standard):** Get second opinion on plan:

```typescript
Task({
  subagent_type: "general-purpose",
  description: "Codex plan review",
  prompt: `Run codex review on the plan file (path from system-reminder).
Report any P1/P2 concerns that should be addressed before implementation.`
})
```

Address any P1/P2 concerns before calling ExitPlanMode.

Mark Refinement completed when execution task done.

### Phase 3: Implementation
Mark Implementation in_progress.

**Execution tasks (tracked via TodoWrite):**

1. Mark "Write failing tests (TDD red)" in_progress
   - `Skill({ skill: "test-driven-development" })` to load instructions
   - Execute: write test that fails for the feature/fix
   - Mark completed with evidence (test output showing failure)

2. Mark "Implementation" in_progress
   - Write the implementation code
   - Mark completed

3. Mark "Make tests pass (TDD green)" in_progress
   - Execute: run tests, verify they pass
   - Mark completed with evidence (test output showing pass)

If 2+ implementation tasks marked `[P]`, dispatch parallel Task agents.

### Phase 4: Cleanup (Standard only)
Mark Cleanup in_progress.

**Execution tasks (each requires evidence):**

1. Mark "Run deslop on changed files" in_progress
   - `Skill({ skill: "deslop" })` to load instructions
   - Execute: identify/remove AI slop, unnecessary comments, defensive checks
   - Mark completed with evidence (diff of changes or "no slop found")

2. Mark "Run code-simplifier" in_progress
   - `Skill({ skill: "code-simplifier" })` to load instructions
   - Execute: simplify complex code, reduce nesting
   - Mark completed with evidence (diff or "no simplifications needed")

3. (JS/TS only) Run knip for dead code

Mark Cleanup completed when all execution tasks done with evidence.

### Phase 5: Testing
Mark Testing in_progress.
- Run `bun run ci` from repository root
- Show exit code
Mark Testing completed with test output.

### Phase 6: Review
Mark Review in_progress.

**Execution tasks (Simple):**

1. Mark "Run codex review --uncommitted" in_progress
   - Execute: run the command, capture output
   - Mark completed with evidence (codex output shown)

2. Mark "Fix P1/P2 codex issues" in_progress
   - Execute: address all P1 (critical) and P2 (important) issues
   - Mark completed with evidence (issues fixed or "no P1/P2 issues")

**Additional execution tasks (Standard):**

3. Mark "Run review skill workflow" in_progress
   - `Skill({ skill: "review" })` to load instructions
   - Execute: follow the review skill's documented workflow
   - Mark completed with evidence (review findings addressed)

4. Mark "Run reviewers skill prompts" in_progress
   - `Skill({ skill: "reviewers" })` to load curated prompts
   - Execute: apply relevant review prompts from the 4400+ collection
   - Mark completed with evidence (prompts applied, findings addressed)

5. Mark "Run codeql security scan" in_progress
   - `Skill({ skill: "codeql" })` to load instructions
   - Execute: run codeql analysis on changed files
   - Mark completed with evidence (scan output shown)

6. Mark "Fix codeql findings" in_progress
   - Execute: address security findings
   - Mark completed with evidence (findings fixed or "no findings")

**Parallel reviewer Tasks (Standard):** Dispatch 4 reviewer Tasks in SINGLE message:

```typescript
// ALL FOUR in ONE message = parallel execution
Task({
  subagent_type: "general-purpose",
  description: "Simplicity review",
  prompt: `Read iterations/simplicity-reviewer.md and apply to changed files.
Output: VERDICT: PASS | NEEDS_SIMPLIFICATION with findings.`
})

Task({
  subagent_type: "general-purpose",
  description: "Completeness review",
  prompt: `Read iterations/completeness-reviewer.md.
Original request: [QUOTE REQUEST]
Output: VERDICT: PASS | INCOMPLETE | OVERBUILT with findings.`
})

Task({
  subagent_type: "general-purpose",
  description: "Quality review",
  prompt: `Read iterations/quality-reviewer.md and apply to changed files.
Output: VERDICT: PASS | NEEDS_FIXES with P1/P2 counts.`
})

Task({
  subagent_type: "general-purpose",
  description: "Test coverage review",
  prompt: `Read iterations/comprehensive-test-reviewer.md.
For each file to be modified, verify:
1. Adequate test coverage exists
2. Current tests pass (green phase)
Only allow modifications after green phase confirmed.
Output: VERDICT: PASS | NEEDS_TESTS | TESTS_FAILING with file list.`
})
```

Aggregate verdicts, fix any NEEDS_* findings, re-run failed reviewers until all PASS.

Mark Review completed when ALL execution tasks done with evidence.

### Phase 7: Verification
Mark Verification in_progress.

**Execution task:** "Run verification commands"
1. `Skill({ skill: "verification-before-completion" })` to load instructions
2. Execute: run verification commands documented by the skill
3. Mark completed with evidence (command output with exit code 0)

Mark Verification completed.

### Phase 8: CI Validation
Mark CI in_progress.
- Run `bun run ci` from repository root
- Show exit code 0
Mark CI completed.

### Phase 9: Integration Tests
Mark Integration in_progress.
- Run `bun run test:integration` (if available)
- Show exit code 0 or note N/A
Mark Integration completed.

### Phase 10: Session End (Standard only)

**Execution task:** "Run workflow-improver analysis"
1. `Skill({ skill: "workflow-improver" })` to load instructions
2. Execute: analyze the session, identify improvement opportunities
3. Mark completed with evidence (analysis output shown)

**Completion:** Task list must show ALL gates AND execution tasks completed with evidence before claiming done.

### Reviewer Prompts (Standard tasks)

The `iterations/` folder contains reviewer prompt files for Phase 6:
- `simplicity-reviewer.md` - YAGNI, LOC reduction focus
- `completeness-reviewer.md` - spec compliance verification
- `quality-reviewer.md` - patterns, security, performance checks
- `comprehensive-test-reviewer.md` - test coverage + green phase enforcement

Each is read by a parallel Task agent during review.

---

## 6. Skill Routing Table

### Planning & Context (triggers: plan/design/requirements/docs)
- /plan, plan this, design approach, implementation plan -> `Skill({ skill: "planning workflow" })`
- unclear/ambiguous/missing requirements -> `Skill({ skill: "ask-questions-if-underspecified" })`
- library docs/API reference/current docs -> `mcp__context7__resolve-library-id` then `mcp__context7__query-docs`

### Research & Discovery (triggers: search/research/find/lookup/current/latest)
**PREFER Exa MCP over built-in WebSearch/WebFetch** — Exa is faster, has better filtering, and richer results.
**USE Octocode MCP for GitHub content** — Exa cannot crawl GitHub raw files; use octocode for repo content.
- GitHub file content/raw files -> `mcp__octocode__githubGetFileContent`
- GitHub code search -> `mcp__octocode__githubSearchCode`
- GitHub repo structure -> `mcp__octocode__githubViewRepoStructure`
- GitHub PR search -> `mcp__octocode__githubSearchPullRequests`
- web search/current info/latest news -> `mcp__exa__web_search_exa`
- advanced search/filters/date range -> `mcp__exa__web_search_advanced_exa`
- code examples/snippets/GitHub/StackOverflow -> `mcp__exa__get_code_context_exa`
- company research/business info/competitors -> `mcp__exa__company_research_exa`
- LinkedIn/people search/profiles -> `mcp__exa__linkedin_search_exa`
- deep research/comprehensive report -> `mcp__exa__deep_researcher_start` then `mcp__exa__deep_researcher_check`
- crawl URL/fetch page/PDF content -> `mcp__exa__crawling_exa`
- smart query expansion/summaries -> `mcp__exa__deep_search_exa`

### Implementation (triggers: implement/build/code/write/create feature)
- TDD, write test first, red-green-refactor -> `Skill({ skill: "test-driven-development" })`
- execute/follow plan -> `Skill({ skill: "executing-plans" })`
- parallel tasks/spawn agents -> `Skill({ skill: "subagent-driven-development" })`
- parallel/concurrent/independent/2+ tasks -> `Skill({ skill: "dispatching-parallel-agents" })`
- spawn agent/run in parallel -> direct `Task({ subagent_type: ... })`

### Code Quality (triggers: review/quality/clean/refactor/lint/unused)
- /review, code review, review changes, deep review -> run `codex review` CLI directly
- simplify/cleaner/reduce complexity -> `Skill({ skill: "code-simplifier" })`
- AI slop/defensive comments/generated cleanup -> `Skill({ skill: "deslop" })`
- unused/dead code/exports/deps -> `Skill({ skill: "knip" })`
- done?/complete?/verify/before PR -> `Skill({ skill: "verification-before-completion" })`
- accessibility/WCAG/a11y/visual review -> `Skill({ skill: "rams" })`

### Security (triggers: security/vulnerability/audit/CVE/OWASP/injection)
- semgrep/SAST/pattern scan/quick scan -> `Skill({ skill: "semgrep" })`
- codeql/taint/data-flow/deep analysis -> `Skill({ skill: "codeql" })`
- PR security/diff review/regression/blast radius -> `Skill({ skill: "differential-review" })`
- similar bugs/variants/pattern hunting -> `Skill({ skill: "variant-analysis" })`
- SARIF/scan results/aggregate report -> `Skill({ skill: "sarif-parsing" })`
- footgun/misuse/secure defaults -> `Skill({ skill: "sharp-edges" })`

### Debugging (triggers: bug/error/broken/fix/debug)
- investigate/root cause/why failing/trace error -> `Skill({ skill: "systematic-debugging" })`

### Testing (triggers: test/spec/coverage/browser/e2e)
- property test/fuzzing/quickcheck/edge cases -> `Skill({ skill: "property-based-testing" })`
- browser/e2e/visual/screenshot/form fill -> `Skill({ skill: "agent-browser" })`

### Documentation & Files (triggers: doc/write/spreadsheet/presentation/xlsx/pptx)
- doc/proposal/spec/decision doc/RFC -> `Skill({ skill: "doc-coauthoring" })`
- .xlsx/Excel/CSV analysis/formulas -> `Skill({ skill: "xlsx" })`
- .pptx/PowerPoint/slides -> `Skill({ skill: "pptx" })`
- create skill/skill development -> `Skill({ skill: "writing-skills" })`
- CLAUDE.md audit/improve -> `Skill({ skill: "claude-md-improver" })`

### Web3 & Smart Contracts (triggers: solidity/contract/ERC/blockchain/web3/defi)
- contract review/Trail of Bits -> `Skill({ skill: "guidelines-advisor" })`
- Slither/security diagram/fuzzing properties -> `Skill({ skill: "secure-workflow-guide" })`
- ERC20/ERC721/token integration/weird tokens -> `Skill({ skill: "token-integration-analyzer" })`
- fuzzer blocked/checksum/bypass -> `Skill({ skill: "fuzzing-obstacles" })`

### Framework-Specific (triggers: React/Next.js/TypeScript/auth/query)
- React perf/Next.js/bundle/SSR/RSC -> `Skill({ skill: "vercel-react-best-practices" })`
- TanStack Query/Router/Start/Form docs -> `mcp__tanstack__tanstack_search_docs` or `mcp__tanstack__tanstack_doc`
- TanStack libraries/ecosystem -> `mcp__tanstack__tanstack_list_libraries` or `mcp__tanstack__tanstack_ecosystem`
- create TanStack app/scaffold project -> `mcp__tanstack__createTanStackApplication`
- generic/conditional/mapped/infer/template literal -> `Skill({ skill: "typescript-advanced-types" })`
- Better Auth/auth setup/session/OAuth -> `Skill({ skill: "better-auth-best-practices" })`
- add auth/auth layer/auth feature -> `Skill({ skill: "create-auth-skill" })`

### Database (triggers: postgres/sql/query optimization/database performance/supabase)
- Postgres/SQL optimization/slow query/connection pool/RLS -> `Skill({ skill: "supabase-postgres-best-practices" })`

### Tooling & Meta (triggers: setup/configure/automate/logging)
- Claude Code setup/hooks/MCP automation -> `Skill({ skill: "claude-automation-recommender" })`
- logging/canonical log/wide events/structured logs -> `Skill({ skill: "logging-best-practices" })`
- workflow improvement/meta improvement/improve workflow/session analysis/eval session -> `Skill({ skill: "workflow-improver" })`

---

## 7. Bash Guidelines

### IMPORTANT: Avoid commands that cause output buffering issues
- DO NOT pipe output through `head`, `tail`, `less`, or `more` when monitoring or checking command output
- DO NOT use `| head -n X` or `| tail -n X` to truncate output - these cause buffering problems
- Instead, let commands complete fully, or use `--max-lines` flags if the command supports them
- For log monitoring, prefer reading files directly rather than piping through filters

### When checking command output:
- Run commands directly without pipes when possible
- If you need to limit output, use command-specific flags (e.g., `git log -n 10` instead of `git log | head -10`)
- Avoid chained pipes that can cause output to buffer indefinitely
