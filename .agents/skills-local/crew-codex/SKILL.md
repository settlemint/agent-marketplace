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
