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
- TanStack/React Query/useQuery/useMutation -> `Skill({ skill: "tanstack-query" })`
- generic/conditional/mapped/infer/template literal -> `Skill({ skill: "typescript-advanced-types" })`
- Better Auth/auth setup/session/OAuth -> `Skill({ skill: "better-auth-best-practices" })`
- add auth/auth layer/auth feature -> `Skill({ skill: "create-auth-skill" })`

### Database (triggers: postgres/sql/query optimization/database performance/supabase)
- Postgres/SQL optimization/slow query/connection pool/RLS -> `Skill({ skill: "supabase-postgres-best-practices" })`

### Tooling & Meta (triggers: setup/configure/automate/logging)
- Claude Code setup/hooks/MCP automation -> `Skill({ skill: "claude-automation-recommender" })`
- logging/canonical log/wide events/structured logs -> `Skill({ skill: "logging-best-practices" })`
