## Development Workflow

Mandatory for implementation tasks. Creating any new file = implementation task. Only exception: pure research/exploration with no artifacts.

**Enforcement**
- Each phase has a gate; output gate check (see Hard Requirements) before entering.
- Do not proceed if a gate is BLOCKED.
- Each gate checkbox requires proof in same message.

**Parallel work (when 2+ independent tasks exist)**
- Prefer separate Codex threads (`/new`, `/fork`, `/resume`) or separate `codex exec` runs.
- Avoid parallel edits to the same files.

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
- Web research if needed (mcp__exa__web_search_exa for current info, mcp__exa__get_code_context_exa for code examples).
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
- Start a visible TODO checklist before writing production code.
- RED (failing test) -> GREEN (minimal code) -> update TODO.
- Iron Law: no production code before a failing test. No exceptions for "simple" file types.
- **Parallel check:** Review tasks - if independent, split into parallel Codex threads.

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
