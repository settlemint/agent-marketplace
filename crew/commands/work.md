---
name: crew:work
description: Execute plans perfectly using orchestrated agents
argument-hint: "[plan slug]"
allowed-tools:
  - Task
  - TaskOutput
  - AskUserQuestion
  - TodoWrite
  - Skill
skills:
  - crew:crew-patterns
  - crew:todo-tracking
  - crew:git
  - n-skills:orchestration
  - code-simplifier
hooks:
  PostToolUse: false
  PreToolUse: false
---

<objective>

Execute a plan using orchestrated background agents. Workers implement; you orchestrate.

**Input:** Plan at `.claude/plans/<slug>.yaml`
**Output:** Working code, passing CI, git action of user's choice

</objective>

<orchestration_role>

**You are the ORCHESTRATOR.** Per `n-skills:orchestration`:

- **NEVER** use tools directly (Read, Write, Edit, Glob, Grep, WebFetch, WebSearch, MCPSearch)
- **ONLY** use: Task, TaskOutput, TodoWrite, AskUserQuestion, Skill
- Spawn WORKER agents for ALL implementation, testing, and file operations
- All agents run with `run_in_background=True`

The orchestration skill defines all patterns. You decide WHICH patterns based on story complexity.

</orchestration_role>

<worker_requirements>

### TDD Enforcement (For All Workers)

Every implementation worker MUST follow TDD. Include in worker prompt:

```
TDD REQUIRED:
1. RED: Write failing test first
2. GREEN: Minimal code to pass
3. REFACTOR: Clean while green

Use `devtools:tdd-typescript` skill patterns. Test MUST fail before implementation.
```

### Worker Preamble (REQUIRED)

Every spawned agent MUST receive this preamble:

```
CONTEXT: You are a WORKER agent, not an orchestrator.

RULES:
- Complete ONLY the task described below
- Use tools directly (Read, Write, Edit, Bash, Glob, Grep, etc.)
- Do NOT spawn sub-agents or manage tasks
- Follow TDD: write failing test FIRST, then implement
- Report completion with absolute file paths

LIBRARY VERIFICATION (MANDATORY):
Before using ANY library/framework API, ALWAYS verify current usage:
1. Load Context7: MCPSearch({ query: "select:mcp__plugin_crew_context7__query-docs" })
2. Fetch docs: mcp__plugin_crew_context7__query-docs({ libraryId: "/<org>/<repo>", query: "how to [your task]" })

When unsure about patterns or stuck on implementation:
1. Load OctoCode: MCPSearch({ query: "select:mcp__plugin_crew_octocode__githubSearchCode" })
2. Search real examples: mcp__plugin_crew_octocode__githubSearchCode({ keywordsToSearch: [...], owner: "...", repo: "..." })

DO NOT rely on training data for library APIs - they change frequently.

TASK:
[specific task with acceptance criteria]
```

### MCP Tools for Workers (REQUIRED Before Implementation)

**CRITICAL:** Workers MUST verify library APIs before using them. Training data is often outdated.

**Context7** — Library documentation (ALWAYS check before using a library)

```javascript
// Step 1: Load the tool
MCPSearch({ query: "select:mcp__plugin_crew_context7__query-docs" });

// Step 2: Query for your specific use case
mcp__plugin_crew_context7__query_docs({
  libraryId: "/tanstack/query",
  query: "How do I use useQuery with suspense and error boundaries?",
});

// Common library IDs (skip resolve for these):
// /reactjs/react.dev, /tailwindlabs/tailwindcss, /tanstack/router
// /tanstack/query, /tanstack/form, /tanstack/table
// /drizzle-team/drizzle-orm, /trpc/trpc, /honojs/hono
// /vitest-dev/vitest, /restate-developers/restate
```

**OctoCode** — GitHub research (USE when docs are unclear or need real examples)

```javascript
// Step 1: Load the tool
MCPSearch({ query: "select:mcp__plugin_crew_octocode__githubSearchCode" });

// Step 2: Find real-world patterns
mcp__plugin_crew_octocode__githubSearchCode({
  keywordsToSearch: ["useQuery", "suspense", "errorBoundary"],
  owner: "tanstack",
  repo: "query",
  path: "examples",
  mainResearchGoal: "Find TanStack Query suspense patterns",
  researchGoal: "Locate real implementations with error handling",
  reasoning: "Need working examples for suspense integration",
});

// When stuck, search merged PRs for solutions:
mcp__plugin_crew_octocode__githubSearchPullRequests({
  owner: "...",
  repo: "...",
  keywordsToSearch: ["fix", "error", "your problem"],
  state: "merged",
  withComments: true, // reveals solutions and gotchas
});
```

**Codex** — Deep reasoning (use for security, debugging, architecture)

```javascript
MCPSearch({ query: "select:mcp__plugin_crew_codex__codex" });
mcp__plugin_crew_codex__codex({
  prompt: "Analyze security implications of...",
});
```

**Code-Simplifier** — Code refinement (use during REFACTOR phase)

- Simplify complex conditionals and nested logic
- Extract reusable functions from duplicated code
- Improve variable and function naming
- Reduce cognitive complexity while preserving behavior

</worker_requirements>

<workflow>

## Phase 1: Setup

Spawn an opus worker to:

1. Verify not on main branch
2. Read the plan file and return story list

```javascript
Task({
  subagent_type: "Explore",
  model: "opus",
  description: "Load plan",
  prompt: `WORKER TASK: Read plan and return stories.

  1. Check branch: git branch --show-current (fail if main/master)
  2. Read: .claude/plans/${slug}.yaml
  3. Return: list of stories with id, title, priority, status`,
  run_in_background: true,
});
```

## Phase 2: Initialize Tracking

Convert plan stories to TodoWrite for session visibility:

```javascript
TodoWrite([
  {
    content: "STORY-001: Title",
    status: "in_progress",
    activeForm: "Implementing...",
  },
  { content: "STORY-002: Title", status: "pending", activeForm: "Waiting..." },
]);
```

## Phase 3: Execute Stories (Orchestrated)

Use patterns from `n-skills:orchestration`:

| Pattern        | When to Use                                    |
| -------------- | ---------------------------------------------- |
| **Fan-Out**    | Independent stories (no shared files)          |
| **Pipeline**   | Sequential stories (dependencies)              |
| **Map-Reduce** | Multi-file changes (parallel edit → integrate) |

### Agent/Model Selection

| Task Complexity        | Model  | Agent Type        |
| ---------------------- | ------ | ----------------- |
| Single file, simple    | `opus` | `general-purpose` |
| Multi-file, moderate   | `opus` | `general-purpose` |
| Security-critical      | `opus` | `general-purpose` |
| Architecture decisions | `opus` | `Plan`            |
| Exploration/research   | `opus` | `Explore`         |

### Execution Loop

1. Identify stories ready to work (no dependencies or dependencies complete)
2. Spawn background workers for ready stories (parallel if independent)
3. Wait for notifications or poll with TaskOutput
4. Update TodoWrite to mark completed and start next
5. Repeat until all stories complete

### Error Recovery

Per `n-skills:orchestration`:

- **Timeout**: Retry with smaller scope or simpler model
- **Incomplete**: Create follow-up task for remainder
- **Wrong approach**: Retry with clearer prompt
- **After 2 failures**: Ask user for guidance

## Phase 4: Code Refinement

After all stories complete, spawn a refinement worker to simplify and clean up the implementation:

```javascript
Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "Refine code",
  prompt: `WORKER TASK: Refine and simplify implementation code.

CONTEXT: All implementation stories are complete. Now apply the REFACTOR step of TDD.

RULES:
- Use the code-simplifier skill for systematic refinement
- Focus on files changed in this branch (git diff --name-only main)
- Apply simplifications: extract functions, reduce nesting, improve naming
- Do NOT change behavior - only improve readability and maintainability
- Run tests after each refactoring to ensure nothing breaks

PROCESS:
1. Get list of changed files: git diff --name-only main
2. For each implementation file (skip tests):
   - Load with Read tool
   - Apply code-simplifier patterns
   - Edit to simplify
   - Run related tests to verify
3. Report: list of files refined and changes made`,
  run_in_background: true,
});
```

**When to skip refinement:**

- Single-file changes with minimal code
- Urgent hotfixes where speed matters
- User explicitly requests skipping

## Phase 5: Multi-Domain Review

After refinement, spawn parallel review agents using **fan-out pattern**. Each agent focuses on a specific domain and uses Codex for deep analysis.

### Review Agents (Run in Parallel)

```javascript
// Fan-out: Launch all reviewers simultaneously
const changedFiles = "git diff --name-only main";

// 1. Security Review (CRITICAL - uses Codex)
Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "Security review",
  prompt: `WORKER TASK: Security review of implementation.

CONTEXT: Implementation complete. Perform security audit.

TOOLS:
- Use Codex MCP for deep security analysis
- MCPSearch to load: mcp__plugin_crew_codex__codex

CHECKLIST:
- [ ] Injection vulnerabilities (SQL, command, XSS)
- [ ] Authentication/authorization flaws
- [ ] Sensitive data exposure (secrets, PII)
- [ ] Input validation gaps
- [ ] Insecure dependencies
- [ ] OWASP Top 10 coverage

PROCESS:
1. Get changed files: ${changedFiles}
2. For each file, analyze with Codex for security issues
3. Classify findings: P1 (critical), P2 (high), P3 (medium)

OUTPUT: JSON array of findings with file, line, severity, description, fix`,
  run_in_background: true,
});

// 2. Architecture Review (uses Codex)
Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "Architecture review",
  prompt: `WORKER TASK: Architecture and pattern review.

CONTEXT: Implementation complete. Verify architectural consistency.

TOOLS:
- Use Codex MCP for design analysis
- MCPSearch to load: mcp__plugin_crew_codex__codex

CHECKLIST:
- [ ] Follows existing codebase patterns
- [ ] Proper separation of concerns
- [ ] No circular dependencies introduced
- [ ] Consistent naming conventions
- [ ] Appropriate abstraction levels
- [ ] No premature optimization

PROCESS:
1. Get changed files: ${changedFiles}
2. Compare patterns to existing codebase
3. Use Codex to analyze design decisions

OUTPUT: JSON array of findings with file, pattern_violation, recommendation`,
  run_in_background: true,
});

// 3. Test Coverage Review
Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "Test coverage review",
  prompt: `WORKER TASK: Test coverage and quality review.

CONTEXT: Implementation complete. Verify test adequacy.

CHECKLIST:
- [ ] All new functions have tests
- [ ] Edge cases covered
- [ ] Error paths tested
- [ ] Integration points tested
- [ ] Mocks are appropriate (not over-mocking)
- [ ] Tests are deterministic

PROCESS:
1. Get changed implementation files: ${changedFiles}
2. Find corresponding test files
3. Analyze coverage gaps
4. Check test quality (not just quantity)

OUTPUT: JSON array with file, coverage_gap, missing_test_case`,
  run_in_background: true,
});

// 4. Code Quality Review
Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "Quality review",
  prompt: `WORKER TASK: Code quality and maintainability review.

CONTEXT: Implementation complete. Check quality metrics.

CHECKLIST:
- [ ] Cognitive complexity acceptable (<15 per function)
- [ ] No dead code introduced
- [ ] No TODO/FIXME without tickets
- [ ] Type safety (no 'any' unless justified)
- [ ] Error handling complete
- [ ] Logging appropriate

PROCESS:
1. Get changed files: ${changedFiles}
2. Analyze each for quality issues
3. Check for anti-patterns

OUTPUT: JSON array with file, line, issue, suggestion`,
  run_in_background: true,
});
```

### Aggregate and Triage Findings

After all reviewers complete, collect and triage:

```javascript
// Wait for all review agents
const results = await Promise.all([
  TaskOutput({ task_id: securityReview.id }),
  TaskOutput({ task_id: architectureReview.id }),
  TaskOutput({ task_id: testReview.id }),
  TaskOutput({ task_id: qualityReview.id }),
]);

// Triage by severity
// P1: Block - must fix before proceeding
// P2: Fix - should fix, spawn workers
// P3: Note - document for future, proceed
```

### Fix Critical Findings

If P1/P2 findings exist, spawn fix workers:

```javascript
Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "Fix review findings",
  prompt: `WORKER TASK: Fix review findings.

FINDINGS TO FIX:
${JSON.stringify(p1AndP2Findings)}

RULES:
- Fix each finding
- Run tests after each fix
- Report what was fixed

Follow TDD: if fix requires new code, write test first.`,
  run_in_background: true,
});
```

### When to Skip Review

- Trivial changes (typos, comments only)
- User explicitly requests: "skip review"
- Emergency hotfix with user approval

## Phase 6: Run CI

```javascript
Skill({ skill: "crew:work:ci", args: slug });
```

If CI fails, spawn workers to fix failures. Repeat until green.

## Phase 7: Completion

When all stories complete and CI passes:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "All work complete. What would you like to do?",
      header: "Git Action",
      options: [
        {
          label: "Create PR (Recommended)",
          description: "Commit, push, and open pull request",
        },
        {
          label: "Commit & Push",
          description: "Commit changes and push to origin",
        },
        { label: "Commit only", description: "Create commit without pushing" },
        { label: "Continue working", description: "Keep making changes" },
      ],
      multiSelect: false,
    },
  ],
});
```

</workflow>

<success_criteria>

- [ ] All work done by background workers (orchestrator never uses Read/Write/Edit)
- [ ] TDD followed (failing tests before implementation)
- [ ] Code refinement applied (code-simplifier used on changed files)
- [ ] Multi-domain review completed (security, architecture, tests, quality)
- [ ] P1/P2 findings fixed before CI
- [ ] TodoWrite shows real-time progress
- [ ] Stories executed in priority order
- [ ] CI passing
- [ ] Git action completed per user choice

</success_criteria>
