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
- [ ] Questions asked (plain text) if ambiguous
- [ ] Plan written (plan-only response when required)
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

**Parallel work (when 2+ independent tasks exist)**
- Use Codex collaboration tools: `spawn_agent` (accepts role presets) or `send_input` (can interrupt running agents)
- Alternative: separate Codex threads (`/new`, `/fork`, `/resume`) or `codex exec` runs
- For MCP-based orchestration: `codex mcp-server` exposes `codex` and `codex-reply` tools with `threadId` for session continuity
- Avoid parallel edits to the same files.

**Task format (strict)**
```
[T001] [P] [US1] Description with exact file path
```
- **Task ID**: Sequential (T001, T002...) in execution order
- **[P] marker**: Include ONLY if parallelizable (different files, no dependencies)
- **[US#] label**: Map to user story/feature when applicable
- **File path**: REQUIRED — every task specifies exact file(s)
- **Atomic**: Each task executable without additional context

**Task phases**
1. **Setup** — project initialization, dependencies
2. **Foundational** — blocking prerequisites (must complete before features)
3. **Features** — one group per user story/feature, in priority order
4. **Polish** — cross-cutting concerns, cleanup, docs

**Task granularity**
- **MANY small tasks** > few large tasks — prefer 10+ atomic tasks over 3 vague ones
- **Single file per task** when possible — enables parallelization
- **Clear completion criteria** — task is done when X file exists/passes/works

**Codex helpers**
- `/diff` for changes, `/review` for review, `/approvals` and `/status` for safety, `/model` for model selection.
- `/mcp` to list available MCP tools, `/mention` to add files into context, `/compact` to reduce context.
- `/skills` to list and run skills, `$skill-name` for direct invocation.

**Principles**
- Use latest package versions (@latest/:latest). Verify on npmjs.com, hub.docker.com, pypi.org. If pinned older, note current version.

### Phase 1: Planning
- **STOP: Output GATE-1 before proceeding.**
- Gather context (Explore Task for large codebases; direct tools for small).
- Repo-wide search if needed (MCP tools if configured, or local rg/git).
- Check docs (local docs/README or MCP if available).
- Web research if needed — **prefer Exa MCP over built-in web search** (mcp__exa__web_search_exa for current info, mcp__exa__get_code_context_exa for code examples).
- Company/competitor research (mcp__exa__company_research_exa, mcp__exa__linkedin_search_exa).
- Deep research for complex topics (mcp__exa__deep_researcher_start → mcp__exa__deep_researcher_check).
- If modifying existing behavior: use `$systematic-debugging` (if available).
- Draft plan with file paths and 2-5 minute tasks; mark parallelizable tasks.
- If complex/architectural: consider switching models via `/model` or `--model`.
- If Linear configured: find issue, then comment plan.

### Phase 2: Plan Refinement ⚠️ COMMONLY SKIPPED
- **STOP: Output GATE-2 before proceeding.**
- **REQUIRED:** Activate `$ask-questions-if-underspecified` (if available).

**Local Mode (interactive):**
- **REQUIRED:** Ask at least one clarifying question in plain text. No exceptions.

**Remote Mode (autonomous):**
- Assess ambiguity: Is the request genuinely unclear? (Score 1-10)
- If ambiguity ≤ 7: proceed with reasonable assumptions, document them in plan.
- If ambiguity > 7: ask focused questions (max 2-3 questions).
- "Requirements are clear" is allowed when genuinely clear.

**Both modes:**
- Even "simple ports" have ambiguity: error handling idioms, edge cases, output format, version compatibility.
- Review plan vs requirements; update.
- Each iteration must deepen: requirements clarity, edge cases, error handling, test strategy.
- **Iteration tracking:** Output "Plan Refinement Iteration N of M" for each pass.

**Questions to consider (ask if needed):**
- Scope: What's included/excluded?
- Behavior: How should edge cases behave?
- Output: What format/structure is expected?
- Error handling: How should failures be handled?
- Testing: What test coverage is expected?
- Compatibility: Version constraints? Breaking changes?

### Phase 3: Implementation
- **STOP: Output GATE-3 before proceeding.**
- **REQUIRED:** Activate `$test-driven-development` and `$verification-before-completion`.
- **Self-check before proceeding:** Confirm explicit skill invocations are in the transcript.
- **Task generation (use strict format above):**
  1. Break work into **MANY small atomic tasks** — prefer 10+ tasks over 3 vague ones
  2. Each task = single file + clear action: `[T001] [P] Create User model in src/models/user.ts`
  3. Mark `[P]` for parallelizable tasks (different files, no dependencies)
  4. Group by phase: Setup → Foundational → Features → Polish
  5. Output TODO checklist with task IDs before writing code
- **Task execution:**
  1. Mark task in-progress in TODO
  2. RED (failing test) -> GREEN (minimal code) — one task at a time
  3. Mark task completed in TODO
- Iron Law: no production code before a failing test. No exceptions for "simple" file types.
- **Parallel check:** If 2+ tasks marked `[P]`, use `spawn_agent` or parallel Codex threads.

### Phase 4: Cleanup
- **STOP: Output GATE-4 before proceeding.**
- Use relevant cleanup skills if available (`$code-simplifier`, `$deslop`, `$knip`).
- For non-JS/TS files: note "cleanup skills N/A" but still output gate.

### Phase 5: Testing
- **STOP: Output GATE-5 before proceeding.**
- Run `bun run ci` or `bun run lint` + `bun run test`.
- If no project tests exist, note this explicitly.
- If UI: use `$agent-browser` for visual checks.
- Check for silent failure gaps.
- **REQUIRED:** Show test output with exit code.

### Phase 6: Review ⚠️ COMMONLY SKIPPED
- **STOP: Output GATE-6 before proceeding.**
- **REQUIRED:** Run `/review` (preferred) and include output.
- Review for bugs/regressions/missing tests.
- Security review if auth/data/payments (use `$semgrep`/`$codeql` if available).
- "Code is simple, doesn't need review" is a banned phrase.
- **Iteration tracking:** Output "Review Iteration N of M" for each pass.

#### Parallel Review Iterations (Standard/Complex tasks)

**REQUIRED for Standard/Complex tasks**: Dispatch three focused review agents IN PARALLEL.

**Step 1: Dispatch ALL THREE in a SINGLE message (parallel execution)**
```
spawn_agent({
  agent_type: "worker",
  message: "Simplicity review: read ./iterations/simplicity-reviewer.md and apply to changed files: [files]. Output VERDICT."
})
spawn_agent({
  agent_type: "worker",
  message: "Completeness review: read ./iterations/completeness-reviewer.md. Original request: [quote]. Output VERDICT."
})
spawn_agent({
  agent_type: "worker",
  message: "Quality review: read ./iterations/quality-reviewer.md and apply to: [files]. Output VERDICT."
})
```

**CRITICAL**: Multiple `spawn_agent` calls in ONE message = parallel. Separate messages = sequential.

| Agent | File | Focus | Verdict Format |
|-------|------|-------|----------------|
| Simplicity | `./iterations/simplicity-reviewer.md` | YAGNI, LOC reduction | `PASS \| NEEDS_SIMPLIFICATION` |
| Completeness | `./iterations/completeness-reviewer.md` | Spec compliance | `PASS \| INCOMPLETE \| OVERBUILT` |
| Quality | `./iterations/quality-reviewer.md` | Patterns, security, perf | `PASS \| NEEDS_FIXES` |

**Optional: Tech-Stack Reviewers (4th parallel agent)**
For Standard/Complex tasks, add a tech-specific review agent that applies curated OSS review guidelines:
```
spawn_agent({
  agent_type: "worker",
  message: "Tech-stack review: 1) Identify tech stack from changed files. 2) Read 3-5 matching reviewers from .agents/skills-local/reviewers/reviewers/ (e.g., react-*, nest-*, bun-*). 3) Apply guidelines to: [files]. Output VERDICT: PASS | NEEDS_FIXES with specific issues."
})
```

**GATE-6 Output (with parallel reviews):**
```
GATE-6 CHECK:
- [x] Simplicity review — PROOF: [VERDICT] - [key findings]
- [x] Completeness review — PROOF: [VERDICT] - [requirements N/N]
- [x] Quality review — PROOF: [VERDICT] - [P1: N, P2: N]
- [ ] Tech-stack review (optional) — PROOF: [VERDICT] - [reviewers applied: react-*, nest-*, etc.]
- [x] All review agents completed — PROOF: wait() shows all agents done
STATUS: PASS | BLOCKED
```

See `./iterations/parallel-review-dispatch.md` for full dispatch template.

### Phase 7: Verification (iterations per classification)
- **STOP: Output GATE-7 before proceeding.**
- **REQUIRED:** Execute verification commands and show output (exit code 0).
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
- **REQUIRED:** Show full CI output with exit code 0 in gate.
- If no CI/lint/test/build scripts exist: document this explicitly in GATE-8.
- This phase runs AFTER Phase 7 verification - it is the absolute last check.
- **No completion claim without GATE-8 passing.**
- **GATE-DONE:** List all gates passed (1-8) + evidence + iteration counts before completion claim.
