## Development Workflow

Mandatory for implementation tasks. Creating any new file = implementation task. Only exception: pure research/exploration with no artifacts.

### Plan Mode Workflow

When `system-reminder` indicates "Plan mode is active", use gate tasks:

**Step 1: Create gate tasks after classification**
```typescript
TaskCreate({ subject: "[GATE-1] Planning", description: "Awaiting start", activeForm: "Verifying planning requirements" })
TaskCreate({ subject: "[GATE-2] Refinement", description: "Awaiting GATE-1", blockedBy: ["gate-1-id"], activeForm: "Verifying refinement requirements" })
```

**Step 2: Update [GATE-1] when planning complete**
```typescript
TaskUpdate({
  taskId: "gate-1-id",
  status: "completed",
  description: "PASS: Classification=[type] | Exploration=octocode,exa | Docs=checked"
})
```
Requirements: Classification stated + User request understood + Codebase exploration complete + Library docs checked + Web research done if needed

**Step 3: Update [GATE-2] when plan complete**
```typescript
TaskUpdate({
  taskId: "gate-2-id",
  status: "completed",
  description: "PASS: Approach=documented | Files=identified | Questions=[asked/N/A] | Plan=written"
})
```
Requirements: Implementation approach documented + Critical files identified + Questions asked (via AskUserQuestion) if ambiguous + Plan written to plan file

**After Plan Approval**: Create remaining gate tasks ([GATE-3] through [GATE-8]) and resume at Implementation phase.

**Plan Mode maps to workflow phases:**
- [GATE-1] → Phase 1 (Planning)
- [GATE-2] → Phase 2 (Plan Refinement)
- After approval → Phase 3+ (Implementation onwards)

---

**Enforcement**
- Each phase has a gate task; update it before proceeding (see Hard Requirements for gate task creation).
- Do not proceed if a gate is BLOCKED (stays in_progress with "BLOCKED:" in description).
- Each gate completion requires proof in the task description.

**Task Management (use Tasks tools when available, TodoWrite as fallback)**

Task Format (strict):
```
[T001] [P] [US1] Description with exact file path
```
- **Task ID**: Sequential (T001, T002...) in execution order
- **[P] marker**: Include ONLY if parallelizable (different files, no dependencies)
- **[US#] label**: Map to user story/feature when applicable
- **File path**: REQUIRED — every task specifies exact file(s)
- **Atomic**: Each task executable by an LLM without additional context

Task Phases:
1. **Setup** — project initialization, dependencies
2. **Foundational** — blocking prerequisites (must complete before features)
3. **Features** — one group per user story/feature, in priority order
4. **Polish** — cross-cutting concerns, cleanup, docs

Task Granularity:
- **MANY small tasks** > few large tasks — prefer 10+ atomic tasks over 3 vague ones
- **Single file per task** when possible — enables parallelization
- **Clear completion criteria** — task is done when X file exists/passes/works
- **Dependencies explicit** — use `TaskUpdate({ addBlockedBy: [...] })` for ordering

Task Workflow:
```
1. TaskCreate({ subject: "[T001] [P] Create user model", description: "Create src/models/user.ts with User interface" })
2. TaskUpdate({ taskId: "N", status: "in_progress" }) - before starting
3. [Single atomic action - one file, one purpose]
4. TaskUpdate({ taskId: "N", status: "completed" }) - after finishing
5. TaskList - find next unblocked task, repeat
```

Parallelization:
- Review TaskList for tasks without `blockedBy` — run these in parallel
- Multiple `Task()` calls in one message = parallel execution
- Mark tasks with `[P]` when they touch different files and have no dependencies

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

**Parallel implementation after planning**
- After plan approval, review TaskList for tasks without `blockedBy` — these can run in parallel
- Dispatch parallel Task subagents: multiple `Task()` calls in one message = parallel execution
- Use `dispatching-parallel-agents` skill when 2+ independent tasks exist
- Use `subagent-driven-development` skill for sequential tasks with review checkpoints

**Principles**
- Use latest package versions (@latest/:latest). Verify on npmjs.com, hub.docker.com, pypi.org. If pinned older, note current version.

### Phase 1: Planning
- **STOP: Update [GATE-1] to in_progress, then completed with proof when done.**
- Gather context (Explore Task for large codebases; direct tools for small).
- Repo-wide search if needed (mcp__octocode__* or local rg/git).
- Check docs (mcp__context7__* if available; else local docs/README).
- Web research if needed — **prefer Exa MCP over built-in WebSearch/WebFetch** (mcp__exa__web_search_exa for current info, mcp__exa__get_code_context_exa for code examples).
- Company/competitor research (mcp__exa__company_research_exa, mcp__exa__linkedin_search_exa).
- Deep research for complex topics (mcp__exa__deep_researcher_start → mcp__exa__deep_researcher_check).
- If modifying existing behavior: `Skill({ skill: "systematic-debugging" })`.
- Draft plan with file paths and 2-5 minute tasks; mark parallelizable tasks.
- If Standard task: `mcp__codex` (Claude Code only) for planning assistance.
- If Linear configured: find issue, then comment plan.

### Phase 2: Plan Refinement ⚠️ COMMONLY SKIPPED
- **STOP: Update [GATE-2] to in_progress, then completed with proof when done.**
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

**Question Format Check (self-check before sending message):**
- Does my message contain "Would you like", "Should we/I", "Do you want", "Could you clarify", or "Which option"?
- If YES and followed by "?" → STOP, use `AskUserQuestion` tool instead
- If NO → proceed with message

**Questions to consider (ask via `AskUserQuestion` tool if needed):**
- Scope: What's included/excluded?
- Behavior: How should edge cases behave?
- Output: What format/structure is expected?
- Error handling: How should failures be handled?
- Testing: What test coverage is expected?
- Compatibility: Version constraints? Breaking changes?

### Phase 3: Implementation
- **STOP: Update [GATE-3] to in_progress, then completed with proof when skills loaded and tasks created.**
- **REQUIRED:** Load skills via `Skill({ skill: "..." })` tool - not just mention them:
  - `Skill({ skill: "test-driven-development" })` - even for shell scripts, config files, "ports".
  - `Skill({ skill: "verification-before-completion" })` - load now, execute in Phase 7.
- **Self-check before proceeding:** Search context for `<invoke name="Skill">`. If not found, STOP.
- **Loading = Commitment:** Once you invoke a skill, you MUST follow its instructions. No exceptions.
- **Backfill check:** Before modifying any existing file:
  1. Check if test file exists (e.g., `foo.ts` → `foo.test.ts`)
  2. If no tests → add tests for existing behavior FIRST
  3. Then proceed with TDD for new changes
- **Task generation (use strict format above):**
  1. Break work into **MANY small atomic tasks** — prefer 10+ tasks over 3 vague ones
  2. Each task = single file + clear action: `[T001] [P] Create User model in src/models/user.ts`
  3. Mark `[P]` for parallelizable tasks (different files, no dependencies)
  4. Group by phase: Setup → Foundational → Features → Polish
  5. `TaskCreate` with ID in subject, file path in description
- **Task execution:**
  1. `TaskUpdate({ status: "in_progress" })` before starting
  2. RED (failing test) -> GREEN (minimal code) — one task at a time
  3. `TaskUpdate({ status: "completed" })` after finishing
- Iron Law: no production code before a failing test. No exceptions for "simple" file types.
- **REQUIRED:** If 2+ tasks marked `[P]`, dispatch parallel Task agents — not sequential.
- **Parallel check:** `TaskList` → find tasks without `blockedBy` → dispatch in parallel.
- **Agent configuration:** Use `name` for tracking, `mode: "plan"` for risky changes, `mode: "bypassPermissions"` for trusted work.
- Load `dispatching-parallel-agents` skill when parallelization is possible.

### Phase 4: Cleanup
- **STOP: Update [GATE-4] to in_progress, then completed with proof when all tasks done.**
- `code-simplifier`, `claude-md-improver` (if CLAUDE.md needs maintenance), `deslop`, `knip`.
- For non-JS/TS files: note "cleanup skills N/A" in gate description.

### Phase 5: Testing
- **STOP: Update [GATE-5] to in_progress, then completed with test results in description.**
- Run `bun run ci` or `bun run lint` + `bun run test`.
- **NOTE:** These commands use turborepo and must be run from the repository root folder.
- **NOTE:** Infrastructure services may be required for tests. Launch with `bun dev:up` (do not use docker-compose directly).
- If no project tests exist, note this explicitly.
- If UI: `agent-browser`, run visual checks.
- Check for silent failure gaps.
- **REQUIRED:** Show test output with exit code.

### Phase 6: Review ⚠️ COMMONLY SKIPPED
- **STOP: Update [GATE-6] to in_progress, then completed with review results in description.**
- **REQUIRED:** Run `Skill({ skill: "review" })` or `/review` - do not skip.
- **REQUIRED:** Run `codex review --uncommitted` (Simple+) - do not skip.
- **REQUIRED:** Include review output AND codex output in gate description.
- **"Manual review" is NOT acceptable** - must invoke the skill tool AND run codex.
- Review for bugs/regressions/missing tests.
- Security review if auth/data/payments (semgrep/codeql).
- `differential-review` for diff security.
- **Tech-specific review guidelines:** Load `Skill({ skill: "reviewers" })` to access 4400+ curated review prompts from OSS projects. Select reviewers by:
  - Language prefix: `react-*`, `nest-*`, `bun-*`, `kubernetes-*`, etc.
  - Read 3-5 relevant reviewers from `.agents/skills-local/reviewers/reviewers/` matching the tech stack
- "Code is simple, doesn't need review" is a banned phrase.
- **Iteration tracking:** Output "Review Iteration N of M" for each pass.

#### Parallel Review Iterations (Standard tasks)

**REQUIRED for Standard tasks**: Dispatch three focused review agents IN PARALLEL.

**Step 1: Create review tasks (optional but recommended for tracking)**
```
TaskCreate({ subject: "[R001] [P] Simplicity review", description: "Apply simplicity-reviewer.md", activeForm: "Running simplicity review" })
TaskCreate({ subject: "[R002] [P] Completeness review", description: "Apply completeness-reviewer.md", activeForm: "Running completeness review" })
TaskCreate({ subject: "[R003] [P] Quality review", description: "Apply quality-reviewer.md", activeForm: "Running quality review" })
```

**Step 2: Dispatch ALL THREE in a SINGLE message (parallel execution)**
```
Task({ subagent_type: "general-purpose", description: "Simplicity review", prompt: "Read .agents/skills-local/crew-claude/iterations/simplicity-reviewer.md and apply to changed files: [files]. Output VERDICT." })
Task({ subagent_type: "general-purpose", description: "Completeness review", prompt: "Read .agents/skills-local/crew-claude/iterations/completeness-reviewer.md. Original request: [quote]. Output VERDICT." })
Task({ subagent_type: "general-purpose", description: "Quality review", prompt: "Read .agents/skills-local/crew-claude/iterations/quality-reviewer.md and apply to: [files]. Output VERDICT." })
```

**CRITICAL**: Multiple Task() calls in ONE message = parallel. Separate messages = sequential.

**Step 3: Aggregate and update tasks**
```
TaskUpdate({ taskId: "R001", status: "completed" })  // after simplicity returns
TaskUpdate({ taskId: "R002", status: "completed" })  // after completeness returns
TaskUpdate({ taskId: "R003", status: "completed" })  // after quality returns
TaskList()  // verify all complete
```

| Agent | File | Focus | Verdict Format |
|-------|------|-------|----------------|
| Simplicity | `.agents/skills-local/crew-claude/iterations/simplicity-reviewer.md` | YAGNI, LOC reduction | `PASS \| NEEDS_SIMPLIFICATION` |
| Completeness | `.agents/skills-local/crew-claude/iterations/completeness-reviewer.md` | Spec compliance | `PASS \| INCOMPLETE \| OVERBUILT` |
| Quality | `.agents/skills-local/crew-claude/iterations/quality-reviewer.md` | Patterns, security, perf | `PASS \| NEEDS_FIXES` |

**Optional: Tech-Stack Reviewers (4th parallel agent)**
For Standard tasks, add a tech-specific review agent that applies curated OSS review guidelines:
```
Task({ subagent_type: "general-purpose", description: "Tech-stack review", prompt: "1. Identify tech stack from changed files. 2. Read 3-5 matching reviewers from .agents/skills-local/reviewers/reviewers/ (e.g., react-*, nest-*, bun-*). 3. Apply their guidelines to: [files]. Output VERDICT: PASS | NEEDS_FIXES with specific issues." })
```

**[GATE-6] Task Description (with parallel reviews):**
```
PASS: Simplicity=[VERDICT] | Completeness=[VERDICT] | Quality=[VERDICT] | Tech=[optional VERDICT] | Reviews=R001-R003 done | Codex=P1:N,P2:N fixed
```

See `.agents/skills-local/crew-claude/iterations/parallel-review-dispatch.md` for full dispatch template.

### Codex AI Review (Simple/Standard - NOT Trivial) ⚠️ MANDATORY

After parallel reviews complete, run codex for independent AI analysis:

1. **Stage any untracked files:**
   ```bash
   git ls-files --others --exclude-standard -z | while IFS= read -r -d '' f; do git add -- "$f"; done
   ```

2. **Run codex review:**
   ```bash
   codex review --uncommitted --config model_reasoning_effort=xhigh
   ```

3. **Handle findings:**
   - If P1/P2 issues found → **MUST fix before proceeding**
   - If only P3/P4 → document and proceed

**[GATE-6] codex requirement (include in task description):**
```
... | Codex=P1:[count],P2:[count] fixed
```

**Anti-pattern:** "My review skill passed" without running codex → **BLOCKED** (gate stays in_progress). Both are required.

### Phase 7: Verification (iterations per classification)
- **STOP: Update [GATE-7] to in_progress, then completed with verification results.**
- **REQUIRED:** Execute `Skill({ skill: "verification-before-completion" })` - not just load.
- **REQUIRED:** Include verification output in gate description.
- **REQUIRED:** Run `TaskList` to verify all tasks are completed.
- Run completion validation.
- Document evidence (exit codes, test counts, warnings).
- Update README/docs if behavior changed.
- Update Linear issue if configured; otherwise note status in response.
- **Iteration tracking:** Output "Verification Iteration N of M" for each pass.

### Phase 8: CI Validation
- **STOP: Update [GATE-8] to in_progress, then completed with CI results.**
- **REQUIRED:** Run CI commands in this priority:
  1. `bun run ci` (if available)
  2. `npm run ci` / `pnpm run ci` (if bun unavailable)
  3. Fallback: `<pkg> run lint && <pkg> run test && <pkg> run build` (if no ci script, where `<pkg>` is bun/npm/pnpm)
- **NOTE:** All CI commands use turborepo and must be run from the repository root folder.
- **NOTE:** Infrastructure services may be required. Launch with `bun dev:up` (do not use docker-compose directly).
- **REQUIRED:** Include CI exit code in gate description: `PASS: CI=bun run ci | Exit=0`
- If no CI/lint/test/build scripts exist: document this explicitly in [GATE-8] description.
- **No completion claim without [GATE-8] showing status: completed.**

### Phase 9: Integration Tests ⚠️ MANDATORY FINAL STEP
- **STOP: Update [GATE-9] to in_progress, then completed with integration test results.**
- **PREREQUISITE:** [GATE-8] must be completed first—do not attempt integration tests if CI fails.
- **REQUIRED:** Run `bun run test:integration` (if script exists) for comprehensive quality assurance.
  - Check if script exists: `jq -e '.scripts["test:integration"]' package.json`
  - If available: run and include result in gate description: `PASS: Integration=Exit 0`
  - If not available: note `PASS: Integration=N/A` in gate description
- **NOTE:** Infrastructure services may be required. Launch with `bun dev:up` before running.
- This phase runs AFTER Phase 8 CI validation - it is the absolute last check.
- **No completion claim without [GATE-9] showing status: completed.**
- **Completion verification:** Run `TaskList` and confirm all gate tasks ([GATE-1] through [GATE-9]) show status: completed with "PASS:" in description.
