---
name: crew-codex
description: Complete development workflow for Codex
---

# Crew Codex

Complete development workflow for Codex. Defines philosophy, task classification, hard requirements, anti-patterns, and 8-phase development process with spawn_agent.

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

### Codex Behaviour
- If files change unexpectedly, assume parallel edits and continue; keep your diff scoped. Stop only for conflicts/breakage, then ask the user.
- When web searching, prefer 2026 (latest) sources/docs unless an older version is explicitly needed.
- Set an approval mode that matches the task risk; switch with `/approvals` as needed, and use full access sparingly.
- Use `/review` for a second set of eyes on risky or wide changes.
- Keep AGENTS.md scoped and lean to avoid unnecessary context bloat.

### Codex Skills
- Skills live in repo `.codex/skills` and global `~/.codex/skills`; if `$<myskill>` isn't found locally, explicitly load `~/.codex/skills/<myskill>/SKILL.md` (plus any `references/`/`scripts/`).
- Use `/skills` to list available skills, `$skill-name` for direct invocation.

### When Using the Shell
- Prefer built-in tools (e.g. `read_file`/`list_dir`/`grep_files`) over ad-hoc shell plumbing when available.
- For shell-based search: `fd` (files), `rg` (text), `ast-grep` (syntax-aware), `jq`/`yq` (extract/transform).

---

## 2. Task Classification

Classify before implementation. When in doubt, classify up.

**Execution Mode:** Check `CODEX_INTERNAL_ORIGINATOR_OVERRIDE` env var. If `codex_web_agent` → Remote Mode (autonomous). See Hard Requirements for adjustments.

### Rules
1. New file => at least Simple (never Trivial).
2. Multiple files => at least Standard.
3. Security/auth/payments => Complex.
4. Uncertain => up.

**Applicability notes**
- Docs/config-only or formatting-only changes may skip TDD/testing/CI; mark gates as N/A with a short rationale.
- Behavior-changing code should follow TDD/testing guidance.

### Categories (guidance, not strict)
- **Trivial:** single-line/typo/comment only. Keep it minimal; no formal gates required.
- **Simple:** single file, clear scope; keep it lightweight and ask questions only if unclear.
- **Standard:** multi-file/behavior change. Use gates for structure; iterate as needed.
- **Complex:** architectural/cross-cutting/security-sensitive. Use gates and deeper review/testing.

### Task Management

Task tracking is optional; use it when it improves clarity or helps break up large work.

### Checklists (optional)

#### Trivial (optional template)
```
CLASSIFICATION: Trivial
SUMMARY: [what you changed] | VERIFICATION: [ran or skipped + reason]
```

#### Simple (optional template)
```
CLASSIFICATION: Simple
SUMMARY: [what you changed] | VERIFICATION: [ran or skipped + reason]
```

#### Standard
Use gates as needed; iterate until risk feels covered.

#### Complex
Use gates and deeper review/testing; choose iterations based on risk.

---

## 3. Hard Requirements (No Exceptions)

### Execution Mode Detection

Check `CODEX_INTERNAL_ORIGINATOR_OVERRIDE` environment variable at session start:
- `CODEX_INTERNAL_ORIGINATOR_OVERRIDE=codex_web_agent` → **Remote Mode** (autonomous, minimal interaction)
- Otherwise → **Local Mode** (interactive, full questioning)

**Remote Mode Adjustments:**
- Phase 2 questioning is **optional** - only ask if genuinely ambiguous
- "Requirements are clear" is **allowed** (not a banned phrase)
- `ask-questions-if-underspecified` skill: activate but only act if ambiguity score > 7/10
- All other gates, skills, and quality requirements remain **unchanged**

**ALWAYS**
- **Output classification before edits or deep exploration** - light discovery (e.g., `ls`, `rg`, file list) is allowed to determine scope.
- **If Plan Mode active, classification precedes deep exploration**.
- **Classification determines which guidance applies** - Trivial/Simple can be lightweight; Standard/Complex should use gates.
- Provide a brief verification summary before claiming done (commands run and/or explicitly skipped with reason).
- Ask clarifying questions when ambiguity remains.

**NEVER**
- **Start deep exploration/planning without classification output** - classification is FIRST.
- **Proceed with heavy tool use before stating classification** - use light discovery only to determine scope.
- Claim completion without stating what was verified or intentionally skipped.
- Skip clarifying questions when requirements are ambiguous.
- You do NOT have the permission to change linter settings, and ignore statements are severely discouraged. Especially the no barrel files rule!

### Skill Activation

Codex activates skills explicitly when you invoke them with `/skills` or `$skill-name`. Skills are optional; use them when helpful. Prefer `$ask-questions-if-underspecified` if ambiguity remains.

### Test Backfilling

When modifying existing code:
- Add tests when risk is medium/high or behavior changes materially.
- Docs/config-only changes are exempt.

**Self-check before modifying any file:**
1. Does a test file exist for this file? (e.g., `foo.ts` → `foo.test.ts`)
2. If no, decide based on risk: add minimal tests for risky changes

### Classification Checklist (Guidance)

Output immediately after classification:

```
CLASSIFICATION: [Trivial|Simple|Standard|Complex]

SKILLS (optional):
- [ ] [skill if helpful]

PHASES (Standard/Complex):
- [ ] Phase 1: Planning
- [ ] Phase 3: Implementation
- [ ] Phase 7: Verification
- [ ] [additional phases per classification]

ITERATIONS: as needed
```

### Phase Gates (Standard/Complex)

Before each phase, output a gate check. Do not proceed if a gate is BLOCKED.

Gate requirements (Standard/Complex):
- Planning: classification stated + research complete.
- Refinement: clarify ambiguities; questions optional if clear.
- Implementation: start work; use TDD/testing if risk warrants.
- Cleanup: ensure implementation is tidy.
- Testing: run relevant tests if they exist and behavior changes.
- Review: do a quick review or `/review` for risky/wide changes.
- Verification: list verification commands run or explicitly note skips.
- CI: run CI for risky/wide changes or when requested; otherwise note skip.
  - **NOTE:** CI commands use turborepo—run from repository root folder.
  - **NOTE:** Infrastructure services may be required—launch with `bun dev:up` (do not use docker-compose directly).
- Completion: verification summary + gates list.

**Activation ≠ Following:** Invoking a skill means you should follow its instructions.

Gate format (use verbatim when gates are used):
```
[Gate Name] CHECK:
- [x] Requirement 1 — PROOF: [brief note or output if run]
- [x] Requirement 2 — PROOF: [brief note or output if run]
- [ ] Requirement 3 (BLOCKED: reason)

STATUS: PASS | BLOCKED
```

### Pre-Completion Gate

Before saying "done" or "complete", confirm:
- Classification + brief verification summary
- Gates used if Standard/Complex
- Verification/testing/CI run or explicitly skipped with rationale

**Banned phrases:** "pre-existing", "not related to my changes", "unrelated to this PR", "existing issue", "those errors existed before", "module resolution issues in the codebase", "the specific tests I created pass"
- **Failure deflection (ZERO TOLERANCE):** Any claim that failures (tests, lint, types, build, CI) are "pre-existing" or "not related to my changes" is ABSOLUTELY FORBIDDEN. Main always passes. If anything fails, you broke it. Fix it.

**Required completion format:** verification summary (and gates list if used)

### Plan Mode Integration

When `system-reminder` indicates "Plan mode is active":

1. **First**: Output classification checklist (same as always)
2. **Then**: Output Understanding gate before exploration
3. **Then**: Output Design gate before writing plan
4. **Finally**: Output the plan (plan-only response when required)

**Plan Mode maps to workflow phases:**
- Understanding → Phase 1 (Planning)
- Design → Phase 2 (Plan Refinement)
- After approval → Phase 3+ (Implementation onwards)

**Plan Mode does NOT exempt you from:**
- Classification output
- Clarifying questions when ambiguous

---

## 4. Anti-Patterns (Never)

### Workflow Bypass
- Classification avoidance: no classification before implementation -> state classification before first TODO (light discovery allowed).

### Skill Failures
- Skill avoidance when needed: use a skill if it materially reduces risk or ambiguity.
- Skill mention vs activation: "I'll use TDD" without invoking `$test-driven-development` -> activate the skill explicitly.
- Conditional skip: "shell scripts don't need TDD" -> TDD applies to behavior-changing code (docs/config-only exempt).
- Implicit knowledge: "I know TDD" without activation -> load the skill or follow its full workflow manually.
- **Activation without follow-through:** invoked a skill but ignored its instructions -> activation = commitment.
- **TDD theater:** activated TDD then wrote code without tests -> delete code, write test first.
- **Fake questions:** claimed to ask questions but skipped them -> activate skill. (Remote: asking is optional if ambiguity ≤ 7)

### Gate Failures
- Gate rushing: gate CHECK with all boxes checked without doing the work -> gates verify work, not skip it.
- Proofless checkboxes: `[x] Requirement` without a brief note -> add `— PROOF: [what you did]`.

### Phase Skipping
- Phase 2 skip: skipping questions when requirements are ambiguous -> clarify or document assumptions.
- Phase 6 skip: skipping review for Standard/Complex code changes without noting a rationale.
- Implicit phases: doing phase work without outputting the gate -> gate output is mandatory.
- Single iteration: doing 1 pass when classification requires 2+ -> track and show iteration count.
- **Review substitution:** skipping any review for Standard/Complex code changes without a brief manual checklist.
- **Port rationalization:** "it's just a port/translation" to skip questions -> ports have ambiguity too (error handling, idioms, edge cases).

### Iteration Failures
- Shallow iteration: repeating the same check without deeper risk analysis.

### Verification Failures
- Unverified completion: claim done without stating what was verified or intentionally skipped.
- Partial verification: "syntax check passed" as full verification -> be explicit about what ran vs skipped.
- Stale evidence: "tests passed earlier" -> run fresh verification before completion claim for code changes.
- Activation without execution: activated verification skill but never ran verification -> execute relevant checks or document skip.
- CI skip: skipping CI for Standard/Complex code changes without a rationale.

### Implementation Failures
- Ignoring obvious time-saving decomposition for large work.

### Failure Deflection (CRITICAL)

**THIS IS THE MOST SEVERE ANTI-PATTERN. ZERO TOLERANCE.**

Applies to: CI failures, test failures, lint errors, type errors, build failures, ANY verification failure.

- **"Pre-existing issues":** claiming failures are "not related to my changes" or "pre-existing in the codebase" -> ABSOLUTELY FORBIDDEN. Main branch ALWAYS passes (otherwise PRs cannot merge). If anything fails, YOUR changes broke it.
- **"My tests pass":** claiming success because "the specific tests I created pass" while ignoring other failures -> UNACCEPTABLE. ALL tests must pass. 19 passing tests mean nothing if 1 test fails.
- **"Module resolution issues":** claiming type errors or import failures are "pre-existing module issues" -> LIES. The codebase compiles on main. You broke it.
- **Blame shifting:** any variation of "those errors existed before" or "that's a different module" -> LIES. You own the ENTIRE outcome. Fix it or revert your changes.
- **Scope limitation:** "not in scope of this PR" for ANY failure -> WRONG. If it fails, it IS in scope. Period.
- **Partial success claims:** "implementation is complete, just some unrelated issues" -> NOTHING is complete until everything passes.
- **Selective reporting:** hiding lint/type/other failures while claiming success -> DISHONEST. Disclose failures; share output if requested.

**The rule is absolute:** If ANY verification (tests, lint, types, build, CI) does not pass, you have NOT completed the task. There are no exceptions. There are no "pre-existing issues" in a working main branch. If it fails now, you fix it now.

### Evidence Failures
- Claiming tests ran when they did not.
- Hiding failures if verification was executed.
- Refusing to share output when explicitly requested.

### Self-Check Questions

Before edits or deep exploration: "Did I output classification?"
Before claiming done: "Did I summarize what ran or was skipped?"

---

## 5. Workflows

Mandatory for implementation tasks. Creating any new file = implementation task. Only exception: pure research/exploration with no artifacts.

### Plan Mode Workflow

When `system-reminder` indicates "Plan mode is active", use this dedicated gate structure:

**Understanding**
```
Understanding CHECK:
- [ ] Classification stated (Trivial/Simple/Standard/Complex)
- [ ] User request understood
- [ ] Codebase exploration complete (mcp__octocode__* for code search, Explore agent for structure)
- [ ] Library docs checked (mcp__context7__* for external libs, local docs for project)
- [ ] Web research done if needed (mcp__exa__* for current info, code examples, company research)
STATUS: PASS | BLOCKED
```

**Design**
```
Design CHECK:
- [ ] Implementation approach documented
- [ ] Critical files identified
- [ ] Questions asked (plain text) if ambiguous
- [ ] Plan written (plan-only response when required)
STATUS: PASS | BLOCKED
```

**After Plan Approval**: Regular workflow resumes at Implementation phase.

**Plan Mode maps to workflow phases:**
- Understanding → Phase 1 (Planning)
- Design → Phase 2 (Plan Refinement)
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
- Use Planning gate for Standard/Complex work.
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
- Use Refinement gate for Standard/Complex work.
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
- Use Implementation gate for Standard/Complex work.
- Use TDD/tests when risk is medium/high or behavior changes materially.
- **Backfill check:** add minimal tests for risky bug fixes if none exist.
- Break work into tasks if it helps; keep it lightweight.

### Phase 4: Cleanup
- Use Cleanup gate for Standard/Complex work.
- Use relevant cleanup skills if available (`$code-simplifier`, `$deslop`, `$knip`).
- For non-JS/TS files: note "cleanup skills N/A" but still output gate.

### Phase 5: Testing
- Use Testing gate for Standard/Complex work.
- Run relevant tests when behavior changes and tests exist.
- **NOTE:** These commands use turborepo and must be run from the repository root folder.
- **NOTE:** Infrastructure services may be required for tests. Launch with `bun dev:up` (do not use docker-compose directly).
- If no project tests exist, note this explicitly.
- If UI: use `$agent-browser` for visual checks.
- Check for silent failure gaps.
- Output optional unless requested or failures occur.

### Phase 6: Review
- Use Review gate for Standard/Complex work.
- Review for bugs/regressions/missing tests on risky changes; `/review` is optional.
- Security review if auth/data/payments (use `$semgrep`/`$codeql` if available).

### Phase 7: Verification
- Use Verification gate for Standard/Complex work.
- Execute verification commands when applicable; summarize results.
- Run completion validation.
- Document results (test counts, warnings) when available.
- Update README/docs if behavior changed.
- Update Linear issue if configured; otherwise note status in response.

### Phase 8: CI Validation (final step when applicable)
- Use CI gate for Standard/Complex work.
- Run CI for risky/wide changes or when requested; otherwise skip with rationale:
  1. `bun run ci` (if available)
  2. `npm run ci` / `pnpm run ci` (if bun unavailable)
  3. Fallback: `<pkg> run lint && <pkg> run test && <pkg> run build` (if no ci script, where `<pkg>` is bun/npm/pnpm)
- **NOTE:** All CI commands use turborepo and must be run from the repository root folder.
- **NOTE:** Infrastructure services may be required. Launch with `bun dev:up` (do not use docker-compose directly).
- Output optional unless requested or failures occur.
- If no CI/lint/test/build scripts exist, or CI is skipped for low-risk/docs: document this explicitly in CI gate.
- This phase runs AFTER Phase 7 verification.
- **Completion:** List gates used (if any) + verification summary before completion claim.

---

## 6. Skill Routing Table

### Skill Invocation
- In Codex, activate skills explicitly via `/skills` or `$skill-name` (recommended when required).

### Planning & Context (triggers: plan/design/requirements/docs)
- /plan, plan this, design approach, implementation plan -> use a planning skill if available (e.g., `$create-plan`) or write a manual plan.
- unclear/ambiguous/missing requirements -> `$ask-questions-if-underspecified`
- library docs/API reference/current docs -> `mcp__context7__resolve-library-id` then `mcp__context7__query-docs`

### Research & Discovery (triggers: search/research/find/lookup/current/latest)
**PREFER Exa MCP over built-in web search** — Exa is faster, has better filtering, and richer results.
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
- TDD, write test first, red-green-refactor -> `$test-driven-development`
- execute/follow plan -> `$executing-plans`
- parallel tasks/spawn agents -> use `spawn_agent` collaboration tool, or `$subagent-driven-development` skill
- parallel/concurrent/independent/2+ tasks -> use `spawn_agent` with role presets, or `/new`/`/fork` for separate threads

### Code Quality (triggers: review/quality/clean/refactor/lint/unused)
- /review, code review, review changes, deep review -> run `/review` when helpful; summarize results (output optional unless requested)
- simplify/cleaner/reduce complexity -> `$code-simplifier`
- AI slop/defensive comments/generated cleanup -> `$deslop`
- unused/dead code/exports/deps -> `$knip`
- done?/complete?/verify/before PR -> `$verification-before-completion`
- accessibility/WCAG/a11y/visual review -> `$rams`

### Security (triggers: security/vulnerability/audit/CVE/OWASP/injection)
- semgrep/SAST/pattern scan/quick scan -> `$semgrep`
- codeql/taint/data-flow/deep analysis -> `$codeql`
- PR security/diff review/regression/blast radius -> `$differential-review`
- similar bugs/variants/pattern hunting -> `$variant-analysis`
- SARIF/scan results/aggregate report -> `$sarif-parsing`
- footgun/misuse/secure defaults -> `$sharp-edges`

### Debugging (triggers: bug/error/broken/fix/debug)
- investigate/root cause/why failing/trace error -> `$systematic-debugging`

### Testing (triggers: test/spec/coverage/browser/e2e)
- property test/fuzzing/quickcheck/edge cases -> `$property-based-testing`
- browser/e2e/visual/screenshot/form fill -> `$agent-browser`

### Documentation & Files (triggers: doc/write/spreadsheet/presentation/xlsx/pptx)
- doc/proposal/spec/decision doc/RFC -> `$doc-coauthoring`
- .xlsx/Excel/CSV analysis/formulas -> `$xlsx`
- .pptx/PowerPoint/slides -> `$pptx`
- create skill/skill development -> `$writing-skills`
- CLAUDE.md audit/improve -> `$claude-md-improver` (if present in this repo)

### Web3 & Smart Contracts (triggers: solidity/contract/ERC/blockchain/web3/defi)
- contract review/Trail of Bits -> `$guidelines-advisor`
- Slither/security diagram/fuzzing properties -> `$secure-workflow-guide`
- ERC20/ERC721/token integration/weird tokens -> `$token-integration-analyzer`
- fuzzer blocked/checksum/bypass -> `$fuzzing-obstacles`

### Framework-Specific (triggers: React/Next.js/TypeScript/auth/query)
- React perf/Next.js/bundle/SSR/RSC -> `$vercel-react-best-practices`
- TanStack Query/Router/Start/Form docs -> `mcp__tanstack__tanstack_search_docs` or `mcp__tanstack__tanstack_doc`
- TanStack libraries/ecosystem -> `mcp__tanstack__tanstack_list_libraries` or `mcp__tanstack__tanstack_ecosystem`
- create TanStack app/scaffold project -> `mcp__tanstack__createTanStackApplication`
- generic/conditional/mapped/infer/template literal -> `$typescript-advanced-types`
- Better Auth/auth setup/session/OAuth -> `$better-auth-best-practices`
- add auth/auth layer/auth feature -> `$create-auth-skill`

### Database (triggers: postgres/sql/query optimization/database performance/supabase)
- Postgres/SQL optimization/slow query/connection pool/RLS -> `$supabase-postgres-best-practices`

### Tooling & Meta (triggers: setup/configure/automate/logging)
- Codex CLI setup/MCP/skill automation -> use `/mcp`, `/skills`, config file, and `codex exec`
- logging/canonical log/wide events/structured logs -> `$logging-best-practices`
- workflow improvement/meta improvement/improve workflow/session analysis/eval session -> `$workflow-improver`

---

## 7. Bash Guidelines

### Output Buffering
- Avoid piping through `head`, `tail`, `less`, `more` - causes buffering issues
- Let commands complete fully, or use command-specific flags (e.g., `git log -n 10` not `git log | head -10`)
- Read files directly rather than piping through filters
