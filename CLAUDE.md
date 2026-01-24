# Claude

## Development Philosophy

This codebase will outlive you. Every shortcut you take becomes
someone else's burden. Every hack compounds into technical debt
that slows the whole team down.

You are not just writing code. You are shaping the future of this
project. The patterns you establish will be copied. The corners
you cut will be cut again.

Fight entropy. Leave the codebase better than you found it.

## Non-negotiables
- Ship production-grade, scalable (>1000 users) implementations; avoid MVP/minimal shortcuts.
- Optimize for long-term sustainability: maintainable, reliable designs.
- Make changes the single canonical implementation in the primary codepath; delete legacy/dead/duplicate paths as part of delivery.
- Use direct, first-class integrations; do not introduce shims, wrappers, glue code, or adapter layers.
- Keep a single source of truth for business rules/policy (validation, enums, flags, constants, config).
- Clean API invariants: define required inputs, validate up front, fail fast.
- Use latest stable libs/docs; if unsure, do a web search.

## Coding Style
- Target <=500 LOC (hard cap 750; imports/types excluded).
- Keep UI/markup nesting <=3 levels; extract components/helpers when JSX/templating repeats, responsibilities pile up, or variant/conditional switches grow.

## Security guards
- No delete/move/overwrite without explicit user request; for deletions prefer `trash` over `rm`.
- Don’t expose secrets in code/logs; use env/secret stores.
- Validate/sanitize untrusted input to prevent injection, path traversal, SSRF, and unsafe uploads.
- Enforce AuthN/AuthZ and tenant boundaries; least privilege.
- Be cautious with new dependencies; flag supply-chain/CVE risk.

<task-classification>
## Task Classification

Classify before implementation. When in doubt, classify up.

**Execution Mode:** Check `CLAUDE_CODE_REMOTE` env var. If `true` → Remote Mode (autonomous). See Hard Requirements for adjustments.

### Rules
1. New file => at least Simple (never Trivial).
2. Multiple files => at least Standard.
3. Security/auth/payments => Complex.
4. Uncertain => up.

### Categories (minimum steps / may skip)
- **Trivial:** single-line/typo/comment only. Steps: TaskCreate -> TaskUpdate(in_progress) -> Implementation -> Verification -> TaskUpdate(completed). May skip: plan refinement, review, deep reasoning.
- **Simple:** single file, clear scope; new file ok. Steps: TaskCreate -> TaskUpdate(in_progress), Planning (1 pass), Implementation, Testing/syntax check, Verification skill, TaskUpdate(completed). May skip: deep reasoning, security review, multi-iteration review.
- **Standard:** multi-file/behavior change. Steps: all phases, minimum 2 iterations each. Skip none.
- **Complex:** architectural/cross-cutting/security-sensitive. Steps: all phases, 5+ iterations each. Skip none.

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

REQUIRED SKILLS (invoke Skill() tool before GATE-3):
- [ ] verification-before-completion

REQUIRED PHASES:
- [ ] Phase 3: Implementation (TaskCreate -> Code -> TaskUpdate)
- [ ] Phase 7: Verification (min 1 iteration)
- [ ] Phase 8: CI Validation → GATE-8

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
- [ ] Phase 8: CI Validation → GATE-8

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
- [ ] Phase 8: CI Validation → GATE-8

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
- [ ] Phase 8: CI Validation → GATE-8

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
</task-classification>
<hard-requirements>
## Hard Requirements (No Exceptions)

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
- **If Plan Mode active, classification precedes exploration** - output PLAN-GATE-1 after classification.
- **Classification determines which gates are required** - Trivial needs fewer, Complex needs more.
- **Task tracking before implementation:** Use `TaskCreate` to create tasks, `TaskUpdate({ status: "in_progress" })` before starting work.
- **Task completion after implementation:** Use `TaskUpdate({ status: "completed" })` after each task is done.
- **Task dependencies:** Use `TaskUpdate({ addBlockedBy: [...] })` to establish task ordering.
- **Fallback:** If Tasks tools unavailable (older Conductor), use `TodoWrite({ status: "in_progress/completed" })`.
- Load skills via `Skill({ skill: "name" })` tool call - listing is not loading.
- Output EVERY gate check (GATE-1 through GATE-8) - not just first few.
- Provide verification evidence (command output/test results with exit code 0) before claiming done.
- Use at least one skill per implementation task (minimum: verification-before-completion).
- Immediately after classification, output the Classification Checklist.
- **Use `AskUserQuestion` tool for ALL clarifying questions** - never plain text questions.
- **Consider parallel Task agents** when 2+ independent implementation tasks exist.
- **Use Task `mode` parameter** appropriately: `plan` for risky changes, `bypassPermissions` for trusted autonomous work.
- **Consider swarm launch** via `ExitPlanMode({ launchSwarm: true, teammateCount: N })` for complex multi-task plans.

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
- Stop outputting gates after the first few pass.
- Check a gate box without showing proof in that same message.
- **Ask clarifying questions in plain text** - MUST use `AskUserQuestion` tool.
- **Execute independent tasks sequentially** when parallel agents could be used.

### Skill Loading (MANDATORY)

**Checklist is not loading.** You must invoke `Skill({ skill: "name" })` tool.

Before GATE-3, you MUST have tool invocations for:
```
Skill({ skill: "test-driven-development" })
Skill({ skill: "verification-before-completion" })
```

If Standard/Complex, also before GATE-2:
```
Skill({ skill: "ask-questions-if-underspecified" })
```

**Self-check:** Search your context for `<invoke name="Skill">`. If not found, you have not loaded skills.

### Classification Checklist (MANDATORY)

Output immediately after classification:

```
CLASSIFICATION: [Trivial|Simple|Standard|Complex]

REQUIRED SKILLS (load before implementation):
- [ ] verification-before-completion (ALL tasks)
- [ ] [skill-2 if applicable]
- [ ] [skill-3 if applicable]

REQUIRED PHASES:
- [ ] Phase 1: Planning
- [ ] Phase 3: Implementation
- [ ] Phase 7: Verification
- [ ] [additional phases per classification]

ITERATIONS: Plan Refinement [1|2|5+] | Review [1|2|5+] | Verification [1|2|5+]
```

### Phase Gates (MANDATORY - ALL OF THEM)

Before each phase, output a gate check. Do not proceed if BLOCKED. Do not skip gates.

⚠️ **Gate amnesia is a failure mode.** You must output EVERY applicable gate, not just early ones.

⚠️ **Gate rushing is a failure mode.** Each checked box requires proof in the same message.

Gate requirements:
- GATE-1 Planning: classification stated + checklist output + research complete (mcp__octocode__* for code, mcp__context7__* for docs, mcp__exa__* for web/company research).
- GATE-2 Plan Refinement: `Skill({ skill: "ask-questions-if-underspecified" })` tool call visible. **Local:** `AskUserQuestion` tool used. **Remote:** questions optional unless genuinely ambiguous.
- GATE-3 Implementation: `Skill({ skill: "test-driven-development" })` tool call visible + Tasks created (or TodoWrite fallback) + task status set to in_progress + parallel agents considered for 2+ independent tasks (with appropriate `name` and `mode`).
- GATE-4 Cleanup: all implementation tasks complete (TaskList shows no pending tasks for current work).
- GATE-5 Testing: test file exists + test output with exit code shown (or explicit "no tests possible" justification).
- GATE-6 Review: `Skill({ skill: "review" })` tool call visible + review output shown. "Manual review" is NOT acceptable.
- GATE-7 Verification: verification commands run IN THIS MESSAGE with exit code 0 shown + all tasks marked completed.
- GATE-8 CI Validation: `bun run ci` (or fallback: lint+test+build) executed IN THIS MESSAGE with exit code 0 shown.
- GATE-DONE Completion: all evidence compiled + TaskList shows all tasks completed.

**Loading ≠ Following:** Invoking a skill means you MUST follow its instructions. Loading TDD then writing code without tests = violation.

Gate format (use verbatim):
```
GATE-[N] CHECK:
- [x] Requirement 1 — PROOF: [what you did]
- [x] Requirement 2 — PROOF: [what you did]
- [ ] Requirement 3 (BLOCKED: reason)

STATUS: PASS | BLOCKED
```

### Pre-Completion Gate

Before saying "done" or "complete", confirm evidence for:
- Tasks created and tracked (TaskCreate/TaskUpdate or TodoWrite fallback)
- All tasks marked completed (run TaskList to verify)
- Classification + checklist
- All gates output (count them: did you output GATE-1 through GATE-8?)
- Phase 2 executed (not skipped) — show questions asked
- Phase 6 executed (not skipped) — show review output
- Required skills loaded via Skill() tool (not just mentioned) — search for `<invoke name="Skill">`
- Verification skill executed (not just loaded)
- Verification command exit code 0
- CI phase executed (GATE-8) with exit code 0

**Banned phrases:** "looks good", "should work", "Done!", "that's it", "it's just a port", "direct translation", "1:1 conversion", "straightforward", "manual review", "reviewed the code"
- **Local only banned:** "requirements are clear" (allowed in Remote Mode when genuinely clear)

**Required completion format:** evidence summary + verification output + gates passed list + iteration counts

### Plan Mode Integration

When `system-reminder` indicates "Plan mode is active":

1. **First**: Output classification checklist (same as always)
2. **Then**: Output PLAN-GATE-1 before exploration
3. **Then**: Output PLAN-GATE-2 before writing plan
4. **Finally**: Call ExitPlanMode when plan is complete

**Plan Mode maps to workflow phases:**
- PLAN-GATE-1 → Phase 1 (Planning)
- PLAN-GATE-2 → Phase 2 (Plan Refinement)
- After approval → Phase 3+ (Implementation onwards)

**Plan Mode does NOT exempt you from:**
- Classification output (still FIRST)
- Skill loading (ask-questions-if-underspecified before PLAN-GATE-2)
- AskUserQuestion tool usage (never plain text questions)
</hard-requirements>
<anti-patterns>
## Anti-Patterns (Never)

### Workflow Bypass
- Trivial bypass: "task is simple" to skip workflow -> classify first and follow minimum steps.
- Direct implementation: code before task tracking -> call `TaskCreate` + `TaskUpdate({ status: "in_progress" })` first (or `TodoWrite` fallback).
- Classification avoidance: no classification before implementation -> state classification before first task creation.
- Task dependency skip: ignoring task ordering -> use `TaskUpdate({ addBlockedBy: [...] })` for dependent tasks.
- Task status neglect: not updating task status -> always set in_progress before work, completed after.

### Skill Failures
- Skill avoidance: no skills loaded -> load at least verification-before-completion.
- Skill mention vs load: "I'll use TDD" without `Skill({ skill: "..." })` call -> actually invoke the tool.
- Checklist theater: listing skills in checklist without invoking Skill() tool -> checklist is not loading.
- Conditional skip: "shell scripts don't need TDD" -> TDD applies to all code, load the skill.
- Implicit knowledge: "I know TDD" without loading -> skill provides specific instructions, load it.
- **Load without follow:** invoked Skill() but ignored its instructions -> loading = commitment to follow.
- **TDD theater:** loaded TDD skill then wrote code without tests -> delete code, write test first.
- **Fake ask-questions:** checked box without invoking skill, said "requirements clear" -> MUST invoke tool. (Remote: asking is optional if ambiguity ≤ 7)
- **Plain text questions:** loaded ask-questions skill but asked in markdown instead of `AskUserQuestion` tool -> FORBIDDEN, always use the tool when asking.

### Gate Failures
- Gate amnesia: output GATE-1, GATE-3, then forget the rest -> output ALL gates for your classification.
- Gate rushing: GATE-N CHECK with all boxes checked without doing the work -> gates verify work, not skip it.
- Proofless checkboxes: `[x] Requirement` without showing evidence -> add `— PROOF: [what you did]`.
- Early gate only: stop at GATE-3 because "implementation is done" -> GATE-4 through GATE-7 still required.
- False pass: marking STATUS: PASS when requirements not met -> BLOCKED until proof shown.

### Phase Skipping
- Phase 2 skip: "requirements are clear" -> Local: ask anyway. Remote: allowed if ambiguity ≤ 7 (still invoke skill, document assumptions).
- Phase 6 skip: "code is simple, doesn't need review" -> run `/review` regardless.
- Implicit phases: doing phase work without outputting the gate -> gate output is mandatory.
- Single iteration: doing 1 pass when classification requires 2+ -> track and show iteration count.
- **Manual review substitution:** "reviewed manually" or "reviewed the code" instead of `Skill({ skill: "review" })` -> tool invocation required.
- **Port rationalization:** "it's just a port/translation" to skip questions -> ports have ambiguity too (error handling, idioms, edge cases).

### Iteration Failures
- Iteration shortcut: "did 1 iteration, that's enough" for Standard -> Standard requires 2+ iterations.
- Shallow iteration: repeating same check without deepening -> each iteration must add: edge cases, error handling, test strategy.
- Uncounted iterations: not tracking iteration count -> output "Iteration N of M" for each pass.

### Verification Failures
- Unverified completion: claim done without verification -> run `Skill({ skill: "verification-before-completion" })` with evidence.
- Partial verification: "syntax check passed" as full verification -> run project CI if available.
- Stale evidence: "tests passed earlier" -> run fresh verification before completion claim.
- Load without execute: loaded verification skill but never ran it -> execute and show output.
- CI skip: claiming done without running `bun run ci` or fallback -> GATE-8 is mandatory for all classifications.

### Implementation Failures
- **Sequential when parallel possible:** executing 2+ independent tasks one-by-one with Bash -> use parallel Task agents.
- **Bash familiarity bias:** defaulting to sequential bash "because it's simpler" -> check skill routing table for `dispatching-parallel-agents`.
- **Agent avoidance:** "file operations are quick" to skip parallel agents -> if tasks are independent, parallelize.
- **Unnamed agents:** spawning agents without `name` parameter -> use names for tracking (e.g., `name: "test-runner"`).
- **Overly permissive mode:** using `mode: "bypassPermissions"` for risky/security tasks -> use `mode: "plan"` for changes requiring review.
- **Mode omission:** not specifying mode when context requires it -> explicitly set `mode` based on task risk level.

### Evidence Failures
- Implied evidence: "I ran the tests" without showing output -> paste actual command output.
- Exit code assumption: "command succeeded" without checking -> show exit code 0 explicitly.
- Selective evidence: showing passing tests, hiding failures -> show full output.

### Self-Check Questions

Before each phase, ask yourself:

**Before any action**: "Did I output classification?"
**Before exploration**: "Did I output PLAN-GATE-1?" (if in plan mode)
**Before writing plan**: "Did I output PLAN-GATE-2?" (if in plan mode)
**Before Write/Edit**: "Did I output GATE-3 and create/update tasks?"
**Before claiming done**: "Did I output all required gates and run TaskList?"

If the answer to any question is "no", STOP and output the missing gate/classification first.

### Task Management Failures
- Orphan tasks: creating tasks without tracking completion -> run `TaskList` before claiming done.
- Stale task list: not checking TaskList after subagent work -> always verify task status after delegation.
- Missing dependencies: parallel tasks that should be sequential -> define blockedBy relationships.
- Tool confusion: mixing Tasks and TodoWrite in same session -> use one system consistently per session.
</anti-patterns>
<workflows>
## Development Workflow

Mandatory for implementation tasks. Creating any new file = implementation task. Only exception: pure research/exploration with no artifacts.

### Plan Mode Workflow

When `system-reminder` indicates "Plan mode is active", use this dedicated gate structure:

**PLAN-GATE-1: Understanding**
```
PLAN-GATE-1 CHECK:
- [ ] Classification stated (Trivial/Simple/Standard/Complex)
- [ ] User request understood
- [ ] Codebase exploration complete (mcp__octocode__* for code search, Explore agent for structure)
- [ ] Library docs checked (mcp__context7__* for external libs, local docs for project)
- [ ] Web research done if needed (mcp__exa__* for current info, code examples, company research)
STATUS: PASS | BLOCKED
```

**PLAN-GATE-2: Design**
```
PLAN-GATE-2 CHECK:
- [ ] Implementation approach documented
- [ ] Critical files identified
- [ ] Questions asked (via AskUserQuestion) if ambiguous
- [ ] Plan written to plan file
STATUS: PASS | BLOCKED
```

**After Plan Approval**: Regular workflow resumes at GATE-3 (Implementation phase).

**Plan Mode maps to workflow phases:**
- PLAN-GATE-1 → Phase 1 (Planning)
- PLAN-GATE-2 → Phase 2 (Plan Refinement)
- After approval → Phase 3+ (Implementation onwards)

---

**Enforcement**
- Each phase has a gate; output gate check (see Hard Requirements) before entering.
- Do not proceed if a gate is BLOCKED.
- Each gate checkbox requires proof in same message.

**Task Management (use Tasks tools when available, TodoWrite as fallback)**

Task Granularity:
- **Phase-level tasks:** Create one task per workflow phase (e.g., "Phase 1: Planning", "Phase 3: Implementation")
- **Work-item tasks:** Create sub-tasks for discrete work items within phases (e.g., "Update file X", "Add test for Y")
- **Dependencies:** Use `TaskUpdate({ addBlockedBy: [...] })` to establish ordering

Task Workflow:
```
1. TaskCreate({ subject: "...", description: "...", activeForm: "..." })
2. TaskUpdate({ taskId: "N", status: "in_progress" }) - before starting work
3. [Do the work]
4. TaskUpdate({ taskId: "N", status: "completed" }) - after finishing
5. TaskList - verify all tasks complete before claiming done
```

Multi-Session Collaboration:
- Set `CLAUDE_CODE_TASK_LIST_ID=<list-id>` environment variable to share tasks across sessions
- Example: `CLAUDE_CODE_TASK_LIST_ID=feature-auth claude` - all sessions share the same task list
- Works with `claude -p` and AgentSDK for subagent coordination
- When one session updates a task, changes are visible to all sessions on that list

**Sub-agents (use when 2+ independent tasks)**
- Format: `Task({ subagent_type: "<type>", prompt: "<task>" })`
- Multiple Task() in one message = parallel
- `run_in_background: true` for background agents
- Skills: `subagent-driven-development`, `dispatching-parallel-agents`
- **Agent naming:** Use `name` parameter for tracking (e.g., `name: "test-runner"`)
- **Team coordination:** Use `team_name` to group related agents
- **Permission modes:** Use `mode` parameter to control agent behavior:
  - `default` - standard permissions
  - `plan` - require plan approval before implementation
  - `acceptEdits` - auto-accept file edits
  - `bypassPermissions` - autonomous mode (use sparingly)
  - `delegate` - can spawn sub-agents
  - `dontAsk` - skip confirmation prompts

**Swarm launch from planning**
- After plan approval, use `ExitPlanMode({ launchSwarm: true, teammateCount: N })` to spawn implementation swarm
- Swarm distributes plan tasks across N parallel teammates

**Principles**
- Use latest package versions (@latest/:latest). Verify on npmjs.com, hub.docker.com, pypi.org. If pinned older, note current version.

### Phase 1: Planning
- **STOP: Output GATE-1 before proceeding.**
- Gather context (Explore Task for large codebases; direct tools for small).
- Repo-wide search if needed (mcp__octocode__* or local rg/git).
- Check docs (mcp__context7__* if available; else local docs/README).
- Web research if needed (mcp__exa__web_search_exa for current info, mcp__exa__get_code_context_exa for code examples).
- Company/competitor research (mcp__exa__company_research_exa, mcp__exa__linkedin_search_exa).
- Deep research for complex topics (mcp__exa__deep_researcher_start → mcp__exa__deep_researcher_check).
- If modifying existing behavior: `Skill({ skill: "systematic-debugging" })`.
- Draft plan with file paths and 2-5 minute tasks; mark parallelizable tasks.
- If complex/architectural: `mcp__codex` (Claude Code only).
- If Linear configured: find issue, then comment plan.

### Phase 2: Plan Refinement ⚠️ COMMONLY SKIPPED
- **STOP: Output GATE-2 before proceeding.**
- **REQUIRED:** `Skill({ skill: "ask-questions-if-underspecified" })` - actually invoke the tool.

**Local Mode (interactive):**
- **REQUIRED:** Use `AskUserQuestion` tool for questions - **NEVER plain text questions**.
- **REQUIRED:** Ask at least one clarifying question. No exceptions. "Requirements clear" is a banned phrase.

**Remote Mode (autonomous):**
- Assess ambiguity: Is the request genuinely unclear? (Score 1-10)
- If ambiguity ≤ 7: proceed with reasonable assumptions, document them in plan.
- If ambiguity > 7: ask focused questions via `AskUserQuestion` (max 2-3 questions).
- "Requirements clear" is allowed when genuinely clear.

**Both modes:**
- Even "simple ports" have ambiguity: error handling idioms, edge cases, output format, version compatibility.
- Review plan vs requirements; update.
- Deep review: `mcp__codex` (Claude Code) or manual (Codex).
- Each iteration must deepen: requirements clarity, edge cases, error handling, test strategy.
- **Iteration tracking:** Output "Plan Refinement Iteration N of M" for each pass.

**Questions to consider (ask via `AskUserQuestion` tool if needed):**
- Scope: What's included/excluded?
- Behavior: How should edge cases behave?
- Output: What format/structure is expected?
- Error handling: How should failures be handled?
- Testing: What test coverage is expected?
- Compatibility: Version constraints? Breaking changes?

### Phase 3: Implementation
- **STOP: Output GATE-3 before proceeding.**
- **REQUIRED:** Load skills via `Skill({ skill: "..." })` tool - not just mention them:
  - `Skill({ skill: "test-driven-development" })` - even for shell scripts, config files, "ports".
  - `Skill({ skill: "verification-before-completion" })` - load now, execute in Phase 7.
- **Self-check before proceeding:** Search context for `<invoke name="Skill">`. If not found, STOP.
- **Loading = Commitment:** Once you invoke a skill, you MUST follow its instructions. No exceptions.
- **Task tracking workflow:**
  1. `TaskCreate` for each work item (or `TodoWrite(in_progress)` fallback)
  2. `TaskUpdate({ status: "in_progress" })` before starting each task
  3. RED (failing test) -> GREEN (minimal code)
  4. `TaskUpdate({ status: "completed" })` after each task
- Iron Law: no production code before a failing test. No exceptions for "simple" file types.
- **REQUIRED:** If 2+ independent tasks exist, use parallel Task agents - not sequential Bash.
- **Parallel check:** Review task list (`TaskList`) - can any tasks run simultaneously? If yes, dispatch parallel agents.
- **Agent configuration:** Use `name` for tracking, `mode: "plan"` for risky changes, `mode: "bypassPermissions"` for trusted work.
- Load `dispatching-parallel-agents` skill when parallelization is possible.

### Phase 4: Cleanup
- **STOP: Output GATE-4 before proceeding.**
- `code-simplifier`, `claude-md-improver` (if CLAUDE.md needs maintenance), `deslop`, `knip`.
- For non-JS/TS files: note "cleanup skills N/A" but still output gate.

### Phase 5: Testing
- **STOP: Output GATE-5 before proceeding.**
- Run `bun run ci` or `bun run lint` + `bun run test`.
- If no project tests exist, note this explicitly.
- If UI: `agent-browser`, run visual checks.
- Check for silent failure gaps.
- **REQUIRED:** Show test output with exit code.

### Phase 6: Review ⚠️ COMMONLY SKIPPED
- **STOP: Output GATE-6 before proceeding.**
- **REQUIRED:** Run `Skill({ skill: "review" })` or `/review` - do not skip.
- **REQUIRED:** Show review output in gate.
- **"Manual review" is NOT acceptable** - must invoke the skill tool.
- Review for bugs/regressions/missing tests.
- Security review if auth/data/payments (semgrep/codeql).
- `differential-review` for diff security.
- "Code is simple, doesn't need review" is a banned phrase.
- **Iteration tracking:** Output "Review Iteration N of M" for each pass.

### Phase 7: Verification (iterations per classification)
- **STOP: Output GATE-7 before proceeding.**
- **REQUIRED:** Execute `Skill({ skill: "verification-before-completion" })` - not just load.
- **REQUIRED:** Show verification output in gate.
- **REQUIRED:** Run `TaskList` to verify all tasks are completed.
- Run completion validation.
- Document evidence (exit codes, test counts, warnings).
- Update README/docs if behavior changed.
- Update Linear issue if configured; otherwise note status in response.
- **Iteration tracking:** Output "Verification Iteration N of M" for each pass.

### Phase 8: CI Validation ⚠️ MANDATORY FINAL STEP
- **STOP: Output GATE-8 before claiming completion.**
- **REQUIRED:** Run CI commands in this priority:
  1. `bun run ci` (if available)
  2. `npm run ci` / `pnpm run ci` (if bun unavailable)
  3. Fallback: `bun run lint && bun run test && bun run build` (if no ci script)
- **REQUIRED:** Show full CI output with exit code 0 in gate.
- If no CI/lint/test/build scripts exist: document this explicitly in GATE-8.
- This phase runs AFTER Phase 7 verification - it is the absolute last check.
- **No completion claim without GATE-8 passing.**
- **GATE-DONE:** List all gates passed (1-8) + evidence + iteration counts + TaskList output before completion claim.
</workflows>
<skill-routing-table>
### Planning & Context (triggers: plan/design/requirements/docs)
- /plan, plan this, design approach, implementation plan -> `Skill({ skill: "planning workflow" })`
- unclear/ambiguous/missing requirements -> `Skill({ skill: "ask-questions-if-underspecified" })`
- library docs/API reference/current docs -> `mcp__context7__resolve-library-id` then `mcp__context7__query-docs`

### Research & Discovery (triggers: search/research/find/lookup/current/latest)
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
- /review, code review, review changes, deep review -> `Skill({ skill: "mcp__codex (Claude Code)" })`
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
</skill-routing-table>
