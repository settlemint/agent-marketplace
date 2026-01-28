---
name: crew-claude
description: Complete development workflow for Claude Code
---

# Crew Claude

Complete development workflow for Claude Code. Defines philosophy, hard requirements, anti-patterns, and 9-gate development process.

---

## 1. Philosophy

This codebase will outlive you. Every shortcut you take becomes someone else's burden. Every hack compounds into technical debt that slows the whole team down.

You are not just writing code. You are shaping the future of this project. The patterns you establish will be copied. The corners you cut will be cut again.

Fight entropy. Leave the codebase better than you found it.

Would a senior engineer say this is overcomplicated? If yes, simplify.

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

## 2. Gate Tasks

Every implementation task follows the same 9-gate workflow. Create all gate tasks at the start.

**Execution Mode:** Check `CLAUDE_CODE_REMOTE` env var. If `true` → Remote Mode (autonomous). See Hard Requirements for adjustments.

**Agent Legend:**
| Agent | Type | Description |
|-------|------|-------------|
| `main` | orchestrator | You (the orchestrating agent) |
| `test-engineer` | custom | TDD workflows (`.claude/agents/test-engineer.md`) |
| `cleanup-agent` | custom | Cleanup phase (`.claude/agents/cleanup-agent.md`) |
| `reviewer` | custom | Code review (`.claude/agents/reviewer.md`) |
| `systems-architect` | custom | Architecture decisions (`.claude/agents/systems-architect.md`) |
| `Bash` | built-in | CLI commands |
| `Explore` | built-in | Codebase exploration |
| `general-purpose` | built-in | General tasks, skill execution |

### Create All Gate Tasks

**Execution order:** `[P]` = can run in parallel, `[S]` = must run sequentially

```typescript
// Phase 1: Planning [P] - parallel research
TaskCreate({ subject: "Planning gate", description: "Agent: main + Explore + general-purpose. GATE: Research complete.", activeForm: "Planning" })

// Phase 2: Refinement [P] - parallel questions + review
TaskCreate({ subject: "Dispatch parallel refinement", description: "Agent: main. Dispatches: general-purpose. Questions + codex plan review.", activeForm: "Dispatching refinement" })
TaskCreate({ subject: "Refinement gate", description: "Agent: main. GATE: Questions asked, concerns addressed.", activeForm: "Refining" })

// Phase 3: Implementation [S] - sequential TDD cycle
TaskCreate({ subject: "Write failing tests (TDD red)", description: "Agent: test-engineer. [S] Write test that fails.", activeForm: "Writing failing tests" })
TaskCreate({ subject: "Implementation", description: "Agent: main. [S] Write the implementation code. Can parallelize across independent files.", activeForm: "Implementing" })
TaskCreate({ subject: "Make tests pass (TDD green)", description: "Agent: test-engineer. [S] Run tests and verify they pass.", activeForm: "Making tests pass" })

// Phase 4: Cleanup [P] - parallel cleanup tools
TaskCreate({ subject: "Dispatch parallel cleanup", description: "Agent: main. Dispatches: cleanup-agent. [P] Run deslop, code-simplifier, knip.", activeForm: "Dispatching cleanup" })
TaskCreate({ subject: "Cleanup gate", description: "Agent: main. GATE: All cleanup tools run with evidence.", activeForm: "Cleaning up" })

// Phase 5: Testing [S]
TaskCreate({ subject: "Testing gate", description: "Agent: Bash. [S] GATE: Run bun run ci, show exit code.", activeForm: "Testing" })

// Phase 6: Review [P] reviews → [P] fixes → [P] re-run
TaskCreate({ subject: "Dispatch parallel reviewers", description: "Agent: main. Dispatches: Bash, reviewer, general-purpose. [P] Run all 6 reviewers.", activeForm: "Dispatching reviewers" })
TaskCreate({ subject: "Dispatch parallel fixes", description: "Agent: main. Dispatches: general-purpose. [P] Fix codex, codeql, reviewer findings.", activeForm: "Dispatching fixes" })
TaskCreate({ subject: "Re-run failed reviewers", description: "Agent: main. Dispatches: Bash, reviewer, general-purpose. [P] Re-run until PASS.", activeForm: "Re-running reviewers" })
TaskCreate({ subject: "Review gate", description: "Agent: main. GATE: All review checks pass.", activeForm: "Reviewing" })

// Phase 7-9: Verification chain [S]
TaskCreate({ subject: "Run verification commands", description: "Agent: Bash. [S] Execute verification-before-completion.", activeForm: "Running verification" })
TaskCreate({ subject: "Verification gate", description: "Agent: main. [S] GATE: All checks pass with exit code 0.", activeForm: "Verifying" })
TaskCreate({ subject: "CI gate", description: "Agent: Bash. [S] GATE: Run bun run ci with exit code 0.", activeForm: "Running CI" })
TaskCreate({ subject: "Integration gate", description: "Agent: Bash. [S] GATE: Run bun run test:integration.", activeForm: "Running integration tests" })

// Phase 10: Session end [S]
TaskCreate({ subject: "Run workflow-improver analysis", description: "Agent: main. Skill: workflow-improver. [S] Analyze session.", activeForm: "Running workflow analysis" })
```

### Set Task Dependencies

After creating all tasks, establish the sequential dependencies:

```typescript
// Phase transitions (each phase blocked by previous)
TaskUpdate({ taskId: refinement-gate-id, addBlockedBy: [planning-gate-id] })
TaskUpdate({ taskId: tdd-red-id, addBlockedBy: [refinement-gate-id] })

// TDD cycle is sequential
TaskUpdate({ taskId: implementation-id, addBlockedBy: [tdd-red-id] })
TaskUpdate({ taskId: tdd-green-id, addBlockedBy: [implementation-id] })

// Cleanup after implementation
TaskUpdate({ taskId: cleanup-dispatch-id, addBlockedBy: [tdd-green-id] })
TaskUpdate({ taskId: cleanup-gate-id, addBlockedBy: [cleanup-dispatch-id] })

// Testing after cleanup
TaskUpdate({ taskId: testing-gate-id, addBlockedBy: [cleanup-gate-id] })

// Review chain
TaskUpdate({ taskId: dispatch-reviewers-id, addBlockedBy: [testing-gate-id] })
TaskUpdate({ taskId: dispatch-fixes-id, addBlockedBy: [dispatch-reviewers-id] })
TaskUpdate({ taskId: rerun-reviewers-id, addBlockedBy: [dispatch-fixes-id] })
TaskUpdate({ taskId: review-gate-id, addBlockedBy: [rerun-reviewers-id] })

// Verification chain
TaskUpdate({ taskId: verification-commands-id, addBlockedBy: [review-gate-id] })
TaskUpdate({ taskId: verification-gate-id, addBlockedBy: [verification-commands-id] })
TaskUpdate({ taskId: ci-gate-id, addBlockedBy: [verification-gate-id] })
TaskUpdate({ taskId: integration-gate-id, addBlockedBy: [ci-gate-id] })

// Session end
TaskUpdate({ taskId: workflow-improver-id, addBlockedBy: [integration-gate-id] })
```

**Execution tasks require evidence:** Each execution task must show command output, diff, or scan results before marking complete.

**Task status updates:**
```typescript
// Before starting work on a task:
TaskUpdate({ taskId: "task-id", status: "in_progress" })

// After completing with evidence:
TaskUpdate({ taskId: "task-id", status: "completed" })

// To set dependencies (task B blocked by task A):
TaskUpdate({ taskId: "task-B-id", addBlockedBy: ["task-A-id"] })
```

### Plan Mode — Planning and Refinement only; remaining gates after approval
```typescript
TaskCreate({ subject: "Planning gate", description: "Agent: main + Explore. GATE: Research complete.", activeForm: "Planning" })
TaskCreate({ subject: "Refinement gate", description: "Agent: main. GATE: Plan written and reviewed.", activeForm: "Refining" })
// After plan approval, create remaining gates + execution tasks
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
- **Create all gate tasks FIRST** - before any implementation work begins.
- **Task tracking before implementation:** Use `TaskCreate` to create tasks, `TaskUpdate({ status: "in_progress" })` before starting work.
- **Task completion after implementation:** Use `TaskUpdate({ status: "completed" })` after each task is done.
- **Task dependencies:** Use `TaskUpdate({ addBlockedBy: [...] })` to establish task ordering.
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
- Skip phases/gates.
- Skip Phase 2 (Plan Refinement) or Phase 6 (Review) - commonly forgotten.
- Write production code before creating/updating tasks via TaskCreate/TaskUpdate.
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

**Text checklists don't work.** Claude forgets requirements that aren't tracked as Tasks.

Every required action MUST be a TaskCreate item. Never state requirements only in prose or markdown checkboxes.

**Wrong:**
```markdown
- [ ] Run codex review
- [ ] Fix issues
```

**Right:**
```typescript
TaskCreate({ subject: "Dispatch codex review", description: "Agent: Bash. Run: codex review --uncommitted.", activeForm: "Dispatching codex review" })
TaskCreate({ subject: "Fix codex issues", description: "Agent: general-purpose. Fix all P1, P2, P3 issues found.", activeForm: "Fixing codex issues" })
```

**Execution tasks require evidence:** Each task must show command output, diff, or results before marking complete.

### Test Backfilling (MANDATORY)

When modifying existing code:
- **If file has no tests → add tests BEFORE modifying**
- Applies to: bug fixes, refactors, behavior changes, any file touch
- TDD execution tasks ("Write failing tests", "Make tests pass") enforce this

### Gate Task Creation (MANDATORY)

Create all gate tasks AND execution tasks via TaskCreate at the start. See Gate Tasks section for the complete list.

**Key principle:** If it's not a TaskCreate item, it won't happen.

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

- **Planning**: `PASS: Research=[tools used]`
  - Requirements: research complete (mcp__octocode__* for code, mcp__context7__* for docs, mcp__exa__* for web).

- **Refinement**: `PASS: Questions=[count or N/A if Remote]`
  - Requirements: "Ask clarifying questions" task completed with evidence. **Local:** `AskUserQuestion` tool used. **Remote:** questions optional unless genuinely ambiguous.

- **Implementation**: `PASS: TDD=[red+green done] | Backfill=[done/N/A]`
  - Requirements: "Write failing tests (TDD red)" task completed + "Make tests pass (TDD green)" task completed + backfill check done.

- **Cleanup**: `PASS: Deslop=[done] | Simplifier=[done]`
  - Requirements: "Run deslop on changed files" task completed with diff shown + "Run code-simplifier" task completed.

- **Testing**: `PASS: Tests=[N passed, N failed] | Exit=[code]`
  - Requirements: test output with exit code shown.

- **Review**: `PASS: Reviewers=[dispatched] | Fixes=[dispatched] | Rerun=[done or N/A]`
  - Requirements: "Dispatch parallel reviewers" + "Dispatch parallel fixes" + "Re-run failed reviewers" all completed with evidence.

- **Verification**: `PASS: Commands=[run] | Exit=[0]`
  - Requirements: "Run verification commands" task completed with exit code 0 shown.

- **CI**: `PASS: CI=[command] | Exit=[0]`
  - Requirements: `bun run ci` executed with exit code 0 shown.
  - **NOTE:** CI commands use turborepo—run from repository root folder.
  - **NOTE:** Infrastructure services may be required—launch with `bun dev:up`.
  - **NOTE:** When `package.json` does not exist (non-Node repos), substitute: `shellcheck` for `.sh` files, `markdownlint` for `.md` files. Document the substitution.

- **Integration**: `PASS: Integration=[Exit 0 or N/A]`
  - Requirements: `bun run test:integration` executed with exit code 0 (or N/A if unavailable).
  - **Prerequisite:** CI must pass first.
  - **NOTE:** When `package.json` does not exist, document N/A with justification.

- **Session End**: `PASS: Workflow-improver=[done]`
  - Requirements: "Run workflow-improver analysis" task completed with session analysis output shown.

**Execution ≠ Loading:** Calling `Skill()` just loads instructions. The execution task tracks actually DOING what the skill documents.

### Pre-Completion Gate

Before claiming done, the task list must show all gate tasks as completed. No exceptions.

**Banned phrases:** "looks good", "should work", "Done!", "it's just a port", "manual review", "pre-existing", "not related to my changes"

**Failure deflection (ZERO TOLERANCE):** Any claim that failures are "pre-existing" or "not related to my changes" is FORBIDDEN. Main always passes. If anything fails, you broke it.

### Plan Mode Integration

When `system-reminder` indicates "Plan mode is active":

1. **First**: Create Planning and Refinement gate tasks
2. **Then**: Update Planning to in_progress, do research, then completed
3. **Then**: Update Refinement to in_progress, write plan, then completed
4. **Finally**: Call ExitPlanMode when plan is complete
5. **After approval**: Create remaining gate tasks

**Plan Mode maps to workflow phases:**
- Planning → Phase 1 (Planning)
- Refinement → Phase 2 (Plan Refinement)
- After approval → Phase 3+ (Implementation onwards)

**Plan Mode does NOT exempt you from:**
- Gate task creation (create Planning and Refinement minimum, rest after approval)
- Skill loading (ask-questions-if-underspecified before Refinement completion)
- AskUserQuestion tool usage (never plain text questions)

---

## 4. Anti-Patterns (Never)

### Workflow Bypass
- Workflow skip: "task is simple" to skip gates -> follow ALL gates, no exceptions.
- Direct implementation: code before task tracking -> call `TaskCreate` + `TaskUpdate({ status: "in_progress" })` first.
- Task dependency skip: ignoring task ordering -> use `TaskUpdate({ addBlockedBy: [...] })` for dependent tasks.
- Task status neglect: not updating task status -> always set in_progress before work, completed after.
- **False task completion:** marking a task as completed without performing the work -> NEVER mark a task completed without doing it. If not applicable, mark completed with clear N/A justification AND output why before marking.
- **Rush-to-completion:** marking workflow-improver or any final-phase task as completed to finish faster -> final-phase tasks exist for a reason; skipping them is a violation.

### Text Checklist Theater (CRITICAL)

**Text checklists don't work.** Claude forgets requirements that aren't tracked as Tasks.

- **Text requirements:** stating requirements in prose without creating tasks → EVERY requirement must be a TaskCreate item
- **Markdown checkboxes:** outputting `- [ ] Do X` without calling TaskCreate → call TaskCreate, not markdown
- **Self-check in context:** "search context for X" → use TaskCreate execution tasks, not context search
- **Gate without execution tasks:** creating Review gate without "Run codex review" task → execution must be tracked
- **Skill load without execute:** calling `Skill()` but not doing what it documents → TaskCreate tracks EXECUTION, not loading
- **Marking execution complete without evidence:** "Run codeql scan" marked done without showing output → must show results

**The rule:** If it's not a TaskCreate item, it won't happen. Period.

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
- Gate task amnesia: create Planning, Implementation, then forget the rest -> create ALL gate tasks at the start.
- Gate task rushing: marking gate completed without doing the work -> gates verify work, not skip it.
- Proofless completion: `status: completed` without proof in description -> add `PASS: [key]=[evidence] | ...` to description.
- Early gate only: stop at Implementation because "implementation is done" -> Cleanup through Integration still required.
- False completion: marking gate completed when requirements not met -> keep in_progress with `BLOCKED: [reason]` in description.
- Gate task skip: not creating gate tasks at all -> MUST create all gate tasks at the start.

### Phase Skipping
- Phase 2 skip: "requirements are clear" → Local: complete "Ask clarifying questions" task. Remote: mark N/A if ambiguity ≤ 7.
- Phase 6 skip: "code is simple, doesn't need review" → ALL review execution tasks must complete with evidence.
- **Codex skip:** "Run codex review" task not completed with output shown → BLOCKED. Show the codex output.
- **Deslop skip:** "Run deslop" task skipped "because code is clean" → run it anyway, show output.
- **Codeql skip:** "Run codeql scan" task skipped → BLOCKED. The skill itself determines applicability, not the agent pre-emptively.
- **Reviewers skip:** "Run reviewers skill prompts" skipped because "only shell/markdown changes" → invoke the skill; it determines relevance, not the agent.
- **Workflow-improver skip:** "Run workflow-improver" task not completed at session end → session incomplete. This must be the absolute last task completed.

### Verification Failures
- Unverified completion: "Run verification commands" task not completed with exit code 0 shown → execute and show output.
- Partial verification: "syntax check passed" as full verification → run project CI, show full output.
- Stale evidence: "tests passed earlier" → run fresh verification, show current output.
- Execution task incomplete: "Run verification commands" marked complete without showing command output → evidence required.
- CI skip: CI task not completed with `bun run ci` exit code 0 shown → CI must pass.

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

Run `TaskList` and verify:
- Every gate task (Planning → Integration) shows completed
- Every execution task shows completed WITH evidence shown in conversation:
  - "Write failing tests" → test output showing failure
  - "Make tests pass" → test output showing pass
  - "Run deslop" → diff or "no slop found"
  - "Dispatch codex review" → codex output shown
  - "Fix codex issues" → issues fixed or "none found"
  - "Run codeql scan" → scan output shown
  - "Run verification" → commands with exit code 0
  - "Run workflow-improver" → analysis output shown

If ANY execution task lacks evidence, you are NOT done.

### Task Management Failures
- Orphan tasks: creating tasks without tracking completion -> run `TaskList` before claiming done.
- Stale task list: not checking TaskList after subagent work -> always verify task status after delegation.
- Missing dependencies: parallel tasks that should be sequential -> define blockedBy relationships via `TaskUpdate({ addBlockedBy: [...] })`.
- Gate task orphans: creating gate tasks without completing them -> all gate tasks must show status: completed with "PASS:" before done.
- Gate dependency skip: creating gates without blockedBy chain -> gates must have proper dependency order (Refinement blockedBy Planning, etc.).
- Wrong agent: using main agent for tasks that should use specialized agents -> consult agent legend in Gate Tasks section.

---

## 5. Workflows

Mandatory for implementation tasks. Creating any new file = implementation task. Only exception: pure research/exploration with no artifacts.

### Plan Mode Workflow

When `system-reminder` indicates "Plan mode is active":

1. Create gate tasks via TaskCreate: `Planning gate`, `Refinement gate`
2. `TaskUpdate({ taskId: planning-id, status: "in_progress" })` → do research → `TaskUpdate({ taskId: planning-id, status: "completed" })`
3. `TaskUpdate({ taskId: refinement-id, status: "in_progress" })` → write plan → `TaskUpdate({ taskId: refinement-id, status: "completed" })`
4. Call ExitPlanMode
5. After approval: create remaining gate tasks (see Gate Tasks section)

---

### Task Management

Use TaskCreate/TaskUpdate for all task tracking. Task list is the source of truth.

**Task lifecycle:**
```typescript
// 1. Create task with agent in description
TaskCreate({
  subject: "Task name",
  description: "Agent: agent-type. What to do.",
  activeForm: "Doing task"
})

// 2. Before starting work
TaskUpdate({ taskId: "...", status: "in_progress" })

// 3. After completing with evidence
TaskUpdate({ taskId: "...", status: "completed" })
```

**Description format:**
```
Agent: <primary-agent>. [Dispatches: <agent1>, <agent2>.] [Skill: <skill-name>.] <task description>.
```

**Sub-agents:** Multiple `Task()` calls in one message = parallel execution

**Agent assignment table:**
| Task Type | Agent | Why |
|-----------|-------|-----|
| Codebase exploration | `Explore` | Built-in, optimized for search |
| TDD (red/green) | `test-engineer` | Custom agent with TDD workflow |
| Cleanup (deslop/simplify/knip) | `cleanup-agent` | Custom agent for Phase 4 |
| Code review | `reviewer` | Custom agent with review modes |
| Architecture decisions | `systems-architect` | Custom agent for design |
| CLI commands (codex, bun, git) | `Bash` | Built-in shell execution |
| Skill execution (codeql, etc.) | `general-purpose` | Built-in with skill loading |
| Docs/web research | `general-purpose` | Uses MCP tools |
| Fix tasks | `general-purpose` | Can read context and edit |

**Principles**
- Use latest package versions (@latest/:latest)
- MANY small tasks > few large tasks
- Always prefix description with `Agent: <type>.`

### Phase 1: Planning
Mark Planning in_progress, then completed when done.

**Parallel research dispatch (SINGLE message):**

Launch research Tasks in parallel where applicable:

```typescript
// Up to 3 Tasks in ONE message = parallel execution
Task({
  subagent_type: "Explore",
  description: "Explore codebase",
  prompt: `Explore the codebase to understand:
- Existing patterns and conventions
- Files relevant to [TASK DESCRIPTION]
- Dependencies and imports
Output: Summary of findings with file paths.`
})

Task({
  subagent_type: "general-purpose",
  description: "Query library docs",
  prompt: `Use mcp__context7__resolve-library-id and mcp__context7__query-docs to find:
- API documentation for [RELEVANT LIBRARIES]
- Usage patterns and best practices
Output: Relevant documentation excerpts.`
})

Task({
  subagent_type: "general-purpose",
  description: "Web search for current info",
  prompt: `Use mcp__exa__web_search_exa to find:
- Latest version info for [LIBRARIES]
- Current best practices for [TECHNOLOGY]
Output: Relevant findings with sources.`
})
```

After research completes, draft plan with file paths and tasks.

### Phase 2: Plan Refinement
Mark Refinement in_progress.

**Parallel refinement dispatch (SINGLE message):**

```typescript
// BOTH Tasks in ONE message = parallel execution
Task({
  subagent_type: "general-purpose",
  description: "Ask clarifying questions",
  prompt: `Load Skill({ skill: "ask-questions-if-underspecified" }).
Execution mode: [LOCAL or REMOTE from CLAUDE_CODE_REMOTE env]
If Local: Use AskUserQuestion tool to clarify ambiguities.
If Remote: Only ask if ambiguity score > 7/10.
Output: Questions asked and answers received, or "N/A - requirements clear".`
})

Task({
  subagent_type: "general-purpose",
  description: "Codex plan review",
  prompt: `Run codex review on the plan file: [PLAN_FILE_PATH]
Report any concerns that should be addressed before implementation.
Output: Concerns list or "no concerns".`
})
```

Address any concerns before calling ExitPlanMode.

Mark Refinement completed when both tasks done.

### Phase 3: Implementation
`TaskUpdate({ taskId: implementation-gate-id, status: "in_progress" })`

**Execution tasks (tracked via TaskCreate/TaskUpdate):**

1. **TDD Red Phase** (Agent: `test-engineer`)
   ```typescript
   TaskUpdate({ taskId: tdd-red-task-id, status: "in_progress" })
   Task({
     subagent_type: "test-engineer",
     description: "Write failing tests",
     prompt: `Write tests that fail for: [FEATURE DESCRIPTION]
   Output: Test code + test output showing failure.`
   })
   TaskUpdate({ taskId: tdd-red-task-id, status: "completed" })
   ```

2. **Implementation** (Agent: `main` or `general-purpose` if parallel)
   ```typescript
   TaskUpdate({ taskId: implementation-task-id, status: "in_progress" })
   // Write the implementation code directly, or dispatch parallel agents:
   Task({
     subagent_type: "general-purpose",
     description: "Implement feature in file X",
     prompt: `Implement: [SPECIFIC TASK]`
   })
   TaskUpdate({ taskId: implementation-task-id, status: "completed" })
   ```

3. **TDD Green Phase** (Agent: `test-engineer`)
   ```typescript
   TaskUpdate({ taskId: tdd-green-task-id, status: "in_progress" })
   Task({
     subagent_type: "test-engineer",
     description: "Make tests pass",
     prompt: `Run tests and verify they pass.
   Output: Test output showing all tests pass.`
   })
   TaskUpdate({ taskId: tdd-green-task-id, status: "completed" })
   ```

If 2+ independent implementation tasks (marked parallelizable), dispatch parallel Task agents.

### Phase 4: Cleanup
`TaskUpdate({ taskId: cleanup-gate-id, status: "in_progress" })`

**Parallel cleanup dispatch** (Dispatches: `cleanup-agent`)

```typescript
TaskUpdate({ taskId: dispatch-cleanup-task-id, status: "in_progress" })

// Option 1: Use custom cleanup-agent (recommended)
Task({
  subagent_type: "cleanup-agent",
  description: "Run all cleanup tools",
  prompt: `Execute Phase 4 cleanup on changed files.
Changed files: [LIST FILES]
Run: deslop, code-simplifier, knip (if JS/TS)
Output: Evidence for each tool.`
})

// Option 2: Dispatch individual tasks in parallel (general-purpose agents)
Task({
  subagent_type: "general-purpose",
  description: "Run deslop",
  prompt: `Load Skill({ skill: "deslop" }) and execute on changed files.
Output: Diff of changes or "no slop found".`
})

Task({
  subagent_type: "general-purpose",
  description: "Run code-simplifier",
  prompt: `Load Skill({ skill: "code-simplifier" }) and execute on changed files.
Output: Diff of changes or "no simplifications needed".`
})

Task({
  subagent_type: "general-purpose",
  description: "Run knip",
  prompt: `Load Skill({ skill: "knip" }) and execute.
Output: List of unused items or "no dead code found".`
})

TaskUpdate({ taskId: dispatch-cleanup-task-id, status: "completed" })
```

`TaskUpdate({ taskId: cleanup-gate-id, status: "completed" })` when all Tasks done with evidence.

### Phase 5: Testing
Mark Testing in_progress.
- Run `bun run ci` from repository root
- Show exit code
Mark Testing completed with test output.

### Phase 6: Review
`TaskUpdate({ taskId: review-gate-id, status: "in_progress" })`

**Step 1: Parallel reviewer dispatch (SINGLE message)**

Launch ALL reviewers in parallel via Task tool in ONE message (6 Tasks):

```typescript
TaskUpdate({ taskId: dispatch-reviewers-task-id, status: "in_progress" })

// ALL SIX in ONE message = parallel execution

Task({
  subagent_type: "Bash",  // Built-in CLI agent
  description: "Run codex review",
  prompt: `Stage untracked files: git ls-files --others --exclude-standard -z | xargs -0 git add
Run: codex review --uncommitted --config model_reasoning_effort=xhigh
Output: Full codex output with issue counts.`,
  timeout: 600000  // 10min (use 1800000 for ≥10 files or ≥500 changes)
})

// Additional 5 Tasks in the SAME message

Task({
  subagent_type: "general-purpose",  // Built-in with skill loading
  description: "Run codeql scan",
  prompt: `Load Skill({ skill: "codeql" }) and execute on changed files.
Output: Scan results with security findings.`
})

Task({
  subagent_type: "reviewer",  // Custom agent: .claude/agents/reviewer.md
  description: "Simplicity review",
  prompt: `Focus: simplicity
Apply SIMPLICITY MODE checklist to changed files.
Output: VERDICT: PASS | NEEDS_SIMPLIFICATION with findings.`
})

Task({
  subagent_type: "reviewer",
  description: "Completeness review",
  prompt: `Focus: completeness
Original request: [QUOTE REQUEST]
Output: VERDICT: PASS | INCOMPLETE | OVERBUILT with findings.`
})

Task({
  subagent_type: "reviewer",
  description: "Quality review",
  prompt: `Focus: quality
Apply QUALITY MODE checklist to changed files.
Output: VERDICT: PASS | NEEDS_FIXES with findings.`
})

Task({
  subagent_type: "reviewer",
  description: "Test coverage review",
  prompt: `Focus: test-coverage
Verify adequate test coverage and tests pass (green phase).
Output: VERDICT: PASS | NEEDS_TESTS | TESTS_FAILING with file list.`
})

TaskUpdate({ taskId: dispatch-reviewers-task-id, status: "completed" })
```

**Step 2: Parallel fix dispatch (SINGLE message)**

After all parallel review Tasks complete, launch fix Tasks in parallel:

```typescript
// ALL FIX TASKS in ONE message = parallel execution
// Note: Paste the actual outputs from Step 1 into the placeholders below
Task({
  subagent_type: "general-purpose",
  description: "Fix codex issues",
  prompt: `Codex review output:
[PASTE CODEX OUTPUT HERE]

Fix all issues found (P1, P2, P3, suggestions).
Output: Issues fixed or "no issues found".`
})

Task({
  subagent_type: "general-purpose",
  description: "Fix codeql findings",
  prompt: `CodeQL scan results:
[PASTE CODEQL OUTPUT HERE]

Fix all findings.
Output: Findings fixed or "no findings".`
})

Task({
  subagent_type: "general-purpose",
  description: "Fix reviewer findings",
  prompt: `Reviewer verdicts:
[PASTE SIMPLICITY VERDICT HERE]
[PASTE COMPLETENESS VERDICT HERE]
[PASTE QUALITY VERDICT HERE]
[PASTE TEST COVERAGE VERDICT HERE]

For any NEEDS_* verdict, apply the recommended fixes.
Output: List of fixes applied or "all reviewers passed".`
})
```

**Step 3: Re-run ALL failed checks in parallel (if needed)**

If any fixes were applied, identify which checks need re-running and dispatch them ALL in parallel. This includes:
- **Codex review** - if codex had findings that were fixed
- **CodeQL scan** - if codeql had findings that were fixed
- **Any reviewer** - if any reviewer returned NEEDS_* verdict

```typescript
// Example: if codex, codeql, and simplicity had issues, re-run ALL THREE in ONE message
Task({
  subagent_type: "Bash",
  description: "Re-run codex review",
  prompt: `Run: codex review --uncommitted --config model_reasoning_effort=xhigh
Output: Full codex output - verify previous issues are resolved.
Required: Output must show "no issues found" or all previous issues fixed.`,
  timeout: DIFFICULT_TASK ? 1800000 : 600000
})

Task({
  subagent_type: "general-purpose",
  description: "Re-run codeql scan",
  prompt: `Load Skill({ skill: "codeql" }) and execute codeql analysis on changed files.
Output: Scan results - verify previous findings are resolved.
Required: Output must show "no findings" or all previous findings fixed.`
})

Task({
  subagent_type: "reviewer",
  description: "Re-run simplicity review",
  prompt: `Focus: simplicity
Apply SIMPLICITY MODE checklist to changed files.
Output: VERDICT: PASS | NEEDS_SIMPLIFICATION with findings.`
})
// ... add other affected checks to the same message
```

**Completion criteria:** Review is ONLY marked completed when ALL of the following pass:
- Codex review: no issues (or "no issues found")
- CodeQL scan: no findings
- All 4 reviewers: VERDICT = PASS

Repeat the fix→re-run cycle until all checks pass. Each iteration should dispatch all failing checks in parallel.

Mark Review completed when all checks pass with evidence.

### Phase 7: Verification
Mark Verification in_progress.

**Execution task:** "Run verification commands"
1. `Skill({ skill: "verification-before-completion" })` to load instructions
2. Execute: run verification commands documented by the skill
3. Mark completed with evidence (command output with exit code 0)

Mark Verification completed.

### Phase 8: CI Validation
Mark CI in_progress.
- **First:** verify `package.json` exists at repository root. If not, substitute with `shellcheck` for `.sh` files and `markdownlint` for `.md` files. Document the substitution.
- Run `bun run ci` from repository root (or substitutes)
- Show exit code 0
Mark CI completed.

### Phase 9: Integration Tests
Mark Integration in_progress.
- **First:** verify `package.json` exists. If not, mark N/A with documented justification.
- Run `bun run test:integration` (if available)
- Show exit code 0 or note N/A
Mark Integration completed.

### Phase 10: Session End

**Execution task:** "Run workflow-improver analysis"
1. `Skill({ skill: "workflow-improver" })` to load instructions
2. Execute: analyze the session, identify improvement opportunities
3. Mark completed with evidence (analysis output shown)

**Completion:** Task list must show ALL gates AND execution tasks completed with evidence before claiming done.

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
