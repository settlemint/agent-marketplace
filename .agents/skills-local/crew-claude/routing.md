# Skill Routing Table

Quick reference for which skill/tool to use for what task.

---

## Planning & Context

**Triggers:** plan, design, requirements, docs

| Need | Skill/Tool |
|------|------------|
| /plan, plan this, design approach | `Skill({ skill: "planning workflow" })` |
| unclear/ambiguous requirements | `Skill({ skill: "ask-questions-if-underspecified" })` |
| library docs, API reference | `mcp__context7__resolve-library-id` → `mcp__context7__query-docs` |

---

## Research & Discovery

**Triggers:** search, research, find, lookup, current, latest

**PREFER Exa MCP over built-in WebSearch/WebFetch** — Exa is faster, has better filtering, and richer results.

**USE Octocode MCP for GitHub content** — Exa cannot crawl GitHub raw files.

| Need | Tool |
|------|------|
| GitHub file content/raw files | `mcp__octocode__githubGetFileContent` |
| GitHub code search | `mcp__octocode__githubSearchCode` |
| GitHub repo structure | `mcp__octocode__githubViewRepoStructure` |
| GitHub PR search | `mcp__octocode__githubSearchPullRequests` |
| Web search, current info | `mcp__exa__web_search_exa` |
| Advanced search with filters | `mcp__exa__web_search_advanced_exa` |
| Code examples, StackOverflow | `mcp__exa__get_code_context_exa` |
| Company research | `mcp__exa__company_research_exa` |
| LinkedIn/people search | `mcp__exa__linkedin_search_exa` |
| Deep research, comprehensive report | `mcp__exa__deep_researcher_start` → `mcp__exa__deep_researcher_check` |
| Crawl URL, fetch page/PDF | `mcp__exa__crawling_exa` |
| Smart query expansion | `mcp__exa__deep_search_exa` |

---

## Implementation

**Triggers:** implement, build, code, write, create feature

| Need | Skill |
|------|-------|
| TDD, write test first | `Skill({ skill: "test-driven-development" })` |
| Execute/follow plan | `Skill({ skill: "executing-plans" })` |
| Parallel tasks, spawn agents | `Skill({ skill: "dispatching-parallel-agents" })` |
| Spawn agent directly | `Task({ subagent_type: ... })` |

---

## Code Quality

**Triggers:** review, quality, clean, refactor, lint, unused

| Need | Skill/Tool |
|------|------------|
| /review, code review | Run `codex review` CLI directly |
| Simplify, reduce complexity | `Skill({ skill: "code-simplifier" })` |
| AI slop, defensive comments | `Skill({ skill: "deslop" })` |
| Unused code, dead exports | `Skill({ skill: "knip" })` |
| Done? Complete? Before PR | `Skill({ skill: "verification-before-completion" })` |
| Accessibility, WCAG, a11y | `Skill({ skill: "rams" })` |

---

## Security

**Triggers:** security, vulnerability, audit, CVE, OWASP, injection

| Need | Skill |
|------|-------|
| Semgrep, SAST, quick scan | `Skill({ skill: "semgrep" })` |
| CodeQL, taint, deep analysis | `Skill({ skill: "codeql" })` |
| PR security, diff review | `Skill({ skill: "differential-review" })` |
| Similar bugs, variants | `Skill({ skill: "variant-analysis" })` |
| SARIF, scan results | `Skill({ skill: "sarif-parsing" })` |
| Footgun, secure defaults | `Skill({ skill: "sharp-edges" })` |

---

## Debugging

**Triggers:** bug, error, broken, fix, debug

| Need | Skill |
|------|-------|
| Investigate, root cause | `Skill({ skill: "systematic-debugging" })` |

---

## Testing

**Triggers:** test, spec, coverage, browser, e2e

| Need | Skill |
|------|-------|
| Property test, fuzzing | `Skill({ skill: "property-based-testing" })` |
| Browser, e2e, visual | `Skill({ skill: "agent-browser" })` |

---

## Documentation & Files

**Triggers:** doc, write, spreadsheet, presentation, xlsx, pptx

| Need | Skill |
|------|-------|
| Doc, proposal, spec, RFC | `Skill({ skill: "doc-coauthoring" })` |
| .xlsx, Excel, CSV | `Skill({ skill: "xlsx" })` |
| .pptx, PowerPoint | `Skill({ skill: "pptx" })` |
| Create skill | `Skill({ skill: "writing-skills" })` |
| CLAUDE.md audit | `Skill({ skill: "claude-md-improver" })` |

---

## Web3 & Smart Contracts

**Triggers:** solidity, contract, ERC, blockchain, web3, defi

| Need | Skill |
|------|-------|
| Contract review, Trail of Bits | `Skill({ skill: "guidelines-advisor" })` |
| Slither, security diagram | `Skill({ skill: "secure-workflow-guide" })` |
| ERC20/ERC721, token integration | `Skill({ skill: "token-integration-analyzer" })` |
| Fuzzer blocked, checksum bypass | `Skill({ skill: "fuzzing-obstacles" })` |

---

## Framework-Specific

**Triggers:** React, Next.js, TypeScript, auth, query

| Need | Tool/Skill |
|------|------------|
| React perf, Next.js, SSR/RSC | `Skill({ skill: "vercel-react-best-practices" })` |
| TanStack Query/Router docs | `mcp__tanstack__tanstack_search_docs` or `mcp__tanstack__tanstack_doc` |
| TanStack libraries | `mcp__tanstack__tanstack_list_libraries` or `mcp__tanstack__tanstack_ecosystem` |
| Create TanStack app | `mcp__tanstack__createTanStackApplication` |
| TypeScript advanced types | `Skill({ skill: "typescript-advanced-types" })` |
| Better Auth setup | `Skill({ skill: "better-auth-best-practices" })` |
| Add auth layer | `Skill({ skill: "create-auth-skill" })` |

---

## Database

**Triggers:** postgres, sql, query optimization, database performance, supabase

| Need | Skill |
|------|-------|
| Postgres optimization, slow query | `Skill({ skill: "supabase-postgres-best-practices" })` |

---

## Tooling & Meta

**Triggers:** setup, configure, automate, logging

| Need | Skill |
|------|-------|
| Claude Code setup, hooks, MCP | `Skill({ skill: "claude-automation-recommender" })` |
| Logging, canonical log lines | `Skill({ skill: "logging-best-practices" })` |
| Workflow improvement, session analysis | `Skill({ skill: "workflow-improver" })` |
