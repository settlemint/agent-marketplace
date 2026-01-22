### Skill Invocation
- In Codex, activate skills explicitly via `/skills` or `$skill-name` (recommended when required).

### Planning & Context (triggers: plan/design/requirements/docs)
- /plan, plan this, design approach, implementation plan -> use a planning skill if available (e.g., `$create-plan`) or write a manual plan.
- unclear/ambiguous/missing requirements -> `$ask-questions-if-underspecified`
- library docs/API reference/current docs -> use MCP tools if configured (`/mcp`) or local docs/README

### Implementation (triggers: implement/build/code/write/create feature)
- TDD, write test first, red-green-refactor -> `$test-driven-development`
- execute/follow plan -> `$executing-plans`
- parallel tasks/spawn agents -> `$subagent-driven-development` (if your setup supports it)
- parallel/concurrent/independent/2+ tasks -> `$dispatching-parallel-agents` or split into parallel Codex threads

### Code Quality (triggers: review/quality/clean/refactor/lint/unused)
- /review, code review, review changes, deep review -> run `/review` and include output
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

### Database (triggers: postgres/sql/query optimization/database performance/supabase)
- Postgres/SQL optimization/slow query/connection pool/RLS -> `$supabase-postgres-best-practices`

### Tooling & Meta (triggers: setup/configure/automate/logging)
- Codex CLI setup/MCP/prompt automation -> use `/mcp`, `/prompts`, config file, and `codex exec`
- logging/canonical log/wide events/structured logs -> `$logging-best-practices`
