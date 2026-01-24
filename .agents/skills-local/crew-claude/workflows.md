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
- **STOP: Output GATE-1 before proceeding.**
- Gather context (Explore Task for large codebases; direct tools for small).
- Repo-wide search if needed (mcp__octocode__* or local rg/git).
- Check docs (mcp__context7__* if available; else local docs/README).
- Web research if needed — **prefer Exa MCP over built-in WebSearch/WebFetch** (mcp__exa__web_search_exa for current info, mcp__exa__get_code_context_exa for code examples).
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
- **STOP: Output GATE-4 before proceeding.**
- `code-simplifier`, `claude-md-improver` (if CLAUDE.md needs maintenance), `deslop`, `knip`.
- For non-JS/TS files: note "cleanup skills N/A" but still output gate.

### Phase 5: Testing
- **STOP: Output GATE-5 before proceeding.**
- Run `bun run ci` or `bun run lint` + `bun run test`.
- **NOTE:** These commands use turborepo and must be run from the repository root folder.
- **NOTE:** Infrastructure services may be required for tests. Launch with `bun dev:up` (do not use docker-compose directly).
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
- **Tech-specific review guidelines:** Load `Skill({ skill: "reviewers" })` to access 4400+ curated review prompts from OSS projects. Select reviewers by:
  - Language prefix: `react-*`, `nest-*`, `bun-*`, `kubernetes-*`, etc.
  - Read 3-5 relevant reviewers from `.agents/skills-local/reviewers/reviewers/` matching the tech stack
- "Code is simple, doesn't need review" is a banned phrase.
- **Iteration tracking:** Output "Review Iteration N of M" for each pass.

#### Parallel Review Iterations (Standard/Complex tasks)

**REQUIRED for Standard/Complex tasks**: Dispatch three focused review agents IN PARALLEL.

**Step 1: Create review tasks (optional but recommended for tracking)**
```
TaskCreate({ subject: "[R001] [P] Simplicity review", description: "Apply simplicity-reviewer.md", activeForm: "Running simplicity review" })
TaskCreate({ subject: "[R002] [P] Completeness review", description: "Apply completeness-reviewer.md", activeForm: "Running completeness review" })
TaskCreate({ subject: "[R003] [P] Quality review", description: "Apply quality-reviewer.md", activeForm: "Running quality review" })
```

**Step 2: Dispatch ALL THREE in a SINGLE message (parallel execution)**
```
Task({ subagent_type: "general-purpose", description: "Simplicity review", prompt: "Read ./iterations/simplicity-reviewer.md and apply to changed files: [files]. Output VERDICT." })
Task({ subagent_type: "general-purpose", description: "Completeness review", prompt: "Read ./iterations/completeness-reviewer.md. Original request: [quote]. Output VERDICT." })
Task({ subagent_type: "general-purpose", description: "Quality review", prompt: "Read ./iterations/quality-reviewer.md and apply to: [files]. Output VERDICT." })
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
| Simplicity | `./iterations/simplicity-reviewer.md` | YAGNI, LOC reduction | `PASS \| NEEDS_SIMPLIFICATION` |
| Completeness | `./iterations/completeness-reviewer.md` | Spec compliance | `PASS \| INCOMPLETE \| OVERBUILT` |
| Quality | `./iterations/quality-reviewer.md` | Patterns, security, perf | `PASS \| NEEDS_FIXES` |

**Optional: Tech-Stack Reviewers (4th parallel agent)**
For Standard/Complex tasks, add a tech-specific review agent that applies curated OSS review guidelines:
```
Task({ subagent_type: "general-purpose", description: "Tech-stack review", prompt: "1. Identify tech stack from changed files. 2. Read 3-5 matching reviewers from .agents/skills-local/reviewers/reviewers/ (e.g., react-*, nest-*, bun-*). 3. Apply their guidelines to: [files]. Output VERDICT: PASS | NEEDS_FIXES with specific issues." })
```

**GATE-6 Output (with parallel reviews):**
```
GATE-6 CHECK:
- [x] Simplicity review — PROOF: [VERDICT] - [key findings]
- [x] Completeness review — PROOF: [VERDICT] - [requirements N/N]
- [x] Quality review — PROOF: [VERDICT] - [P1: N, P2: N]
- [ ] Tech-stack review (optional) — PROOF: [VERDICT] - [reviewers applied: react-*, nest-*, etc.]
- [x] All review tasks completed — PROOF: TaskList shows R001-R003 done
STATUS: PASS | BLOCKED
```

See `./iterations/parallel-review-dispatch.md` for full dispatch template.

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
  3. Fallback: `<pkg> run lint && <pkg> run test && <pkg> run build` (if no ci script, where `<pkg>` is bun/npm/pnpm)
- **NOTE:** All CI commands use turborepo and must be run from the repository root folder.
- **NOTE:** Infrastructure services may be required. Launch with `bun dev:up` (do not use docker-compose directly).
- **REQUIRED:** Show full CI output with exit code 0 in gate.
- If no CI/lint/test/build scripts exist: document this explicitly in GATE-8.
- This phase runs AFTER Phase 7 verification - it is the absolute last check.
- **No completion claim without GATE-8 passing.**
- **GATE-DONE:** List all gates passed (1-8) + evidence + iteration counts + TaskList output before completion claim.
