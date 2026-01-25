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
- Use gates for Standard/Complex work; Simple/Trivial can skip gates and provide a short verification summary.
- If a gate is BLOCKED, do not proceed.

**Parallel work**
- Optional; use when it materially speeds up large independent tasks.

**Task format (optional)**
```
[T001] [P] [US1] Description with exact file path
```
- **Task ID**: Use if helpful
- **[P] marker**: Optional
- **[US#] label**: Optional
- **File path**: Include when it helps clarity
- **Atomic**: Keep tasks bite-sized if you use them

**Task phases**
1. **Setup** — project initialization, dependencies
2. **Foundational** — blocking prerequisites (must complete before features)
3. **Features** — one group per user story/feature, in priority order
4. **Polish** — cross-cutting concerns, cleanup, docs

**Task granularity**
- Use whatever task breakdown helps you move quickly and stay accurate.

**Codex helpers**
- `/diff` for changes, `/review` for review, `/approvals` to switch approval modes (Auto/read-only), `/status` for safety, `/model` for model selection.
- `/mcp` to list available MCP tools, `/mention` to add files into context, `/compact` to reduce context.
- `/skills` to list and run skills, `$skill-name` for direct invocation.

**Principles**
- Use latest package versions (@latest/:latest). Verify on npmjs.com, hub.docker.com, pypi.org. If pinned older, note current version.

### Phase 1: Planning
- Use GATE-1 for Standard/Complex work.
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

### Phase 2: Plan Refinement
- Use GATE-2 for Standard/Complex work.
- Ask questions only if requirements are unclear.

**Local Mode (interactive):**
- Ask questions only when ambiguous.

**Remote Mode (autonomous):**
- Assess ambiguity: Is the request genuinely unclear? (Score 1-10)
- If ambiguity ≤ 7: proceed with reasonable assumptions, document them in plan.
- If ambiguity > 7: ask focused questions (max 2-3 questions).
- "Requirements are clear" is allowed when genuinely clear.

**Both modes:**
- Review plan vs requirements; update as needed.

**Questions to consider (ask if needed):**
- Scope: What's included/excluded?
- Behavior: How should edge cases behave?
- Output: What format/structure is expected?
- Error handling: How should failures be handled?
- Testing: What test coverage is expected?
- Compatibility: Version constraints? Breaking changes?

### Phase 3: Implementation
- Use GATE-3 for Standard/Complex work.
- Use TDD/tests when risk is medium/high or behavior changes materially.
- **Backfill check:** add minimal tests for risky bug fixes if none exist.
- Break work into tasks if it helps; keep it lightweight.

### Phase 4: Cleanup
- Use GATE-4 for Standard/Complex work.
- Use relevant cleanup skills if available (`$code-simplifier`, `$deslop`, `$knip`).
- For non-JS/TS files: note "cleanup skills N/A" but still output gate.

### Phase 5: Testing
- Use GATE-5 for Standard/Complex work.
- Run relevant tests when behavior changes and tests exist.
- **NOTE:** These commands use turborepo and must be run from the repository root folder.
- **NOTE:** Infrastructure services may be required for tests. Launch with `bun dev:up` (do not use docker-compose directly).
- If no project tests exist, note this explicitly.
- If UI: use `$agent-browser` for visual checks.
- Check for silent failure gaps.
- Output optional unless requested or failures occur.

### Phase 6: Review
- Use GATE-6 for Standard/Complex work.
- Review for bugs/regressions/missing tests on risky changes; `/review` is optional.
- Security review if auth/data/payments (use `$semgrep`/`$codeql` if available).
-

#### Parallel Review Iterations (optional)

### Phase 7: Verification
- Use GATE-7 for Standard/Complex work.
- Execute verification commands when applicable; summarize results.
- Run completion validation.
- Document results (test counts, warnings) when available.
- Update README/docs if behavior changed.
- Update Linear issue if configured; otherwise note status in response.
-

### Phase 8: CI Validation (final step when applicable)
- Use GATE-8 for Standard/Complex work.
- Run CI for risky/wide changes or when requested; otherwise skip with rationale:
  1. `bun run ci` (if available)
  2. `npm run ci` / `pnpm run ci` (if bun unavailable)
  3. Fallback: `<pkg> run lint && <pkg> run test && <pkg> run build` (if no ci script, where `<pkg>` is bun/npm/pnpm)
- **NOTE:** All CI commands use turborepo and must be run from the repository root folder.
- **NOTE:** Infrastructure services may be required. Launch with `bun dev:up` (do not use docker-compose directly).
- Output optional unless requested or failures occur.
- If no CI/lint/test/build scripts exist, or CI is skipped for low-risk/docs: document this explicitly in GATE-8.
- This phase runs AFTER Phase 7 verification.
- **GATE-DONE:** List gates used (if any) + verification summary before completion claim.
