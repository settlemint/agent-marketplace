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

<constraints>

- This codebase will outlive you. Every shortcut becomes someone else's burden. Every hack compounds into technical debt that slows the whole team down.
- You are not just writing code. You are shaping the future of this project. The patterns you establish will be copied. The corners you cut will be cut again.
- Fight entropy. Leave the codebase better than you found it.

</constraints>

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

SKILL LOADING (MANDATORY - load BEFORE starting work):
Use Skill() tool to load domain-specific knowledge. Skills contain patterns, constraints, and success criteria.

FRONTEND:
| Domain | Load Skill |
|--------|------------|
| React/Next.js | Skill({ skill: "devtools:react" }) |
| React performance | Skill({ skill: "devtools:react-best-practices" }) |
| UI components | Skill({ skill: "devtools:shadcn" }) |
| Radix primitives | Skill({ skill: "devtools:radix" }) |
| Animations | Skill({ skill: "devtools:motion" }) |
| TanStack Start | Skill({ skill: "devtools:tanstack-start" }) |
| Charts | Skill({ skill: "devtools:recharts" }) |
| i18n | Skill({ skill: "devtools:i18n" }) |

DESIGN:
| Domain | Load Skill |
|--------|------------|
| Design system | Skill({ skill: "devtools:design-principles" }) |
| UI/UX audit | Skill({ skill: "devtools:vercel-design-guidelines" }) |

TESTING:
| Domain | Load Skill |
|--------|------------|
| Unit tests | Skill({ skill: "devtools:vitest" }) |
| E2E tests | Skill({ skill: "devtools:playwright" }) |
| TDD workflow | Skill({ skill: "devtools:tdd-typescript" }) |

BACKEND/API:
| Domain | Load Skill |
|--------|------------|
| API routes | Skill({ skill: "devtools:api" }) |
| Database | Skill({ skill: "devtools:drizzle" }) |
| Durable execution | Skill({ skill: "devtools:restate" }) |
| Logging | Skill({ skill: "devtools:pino" }) |
| Authentication | Skill({ skill: "devtools:better-auth" }) |
| Validation | Skill({ skill: "devtools:zod" }) |

BLOCKCHAIN:
| Domain | Load Skill |
|--------|------------|
| Smart contracts | Skill({ skill: "devtools:solidity" }) |
| Ethereum client | Skill({ skill: "devtools:viem" }) |
| Subgraphs | Skill({ skill: "devtools:thegraph" }) |

DEVOPS:
| Domain | Load Skill |
|--------|------------|
| Helm charts | Skill({ skill: "devtools:helm" }) |
| Terraform | Skill({ skill: "devtools:terraform" }) |
| Monorepo builds | Skill({ skill: "devtools:turbo" }) |
| Debugging | Skill({ skill: "devtools:troubleshooting" }) |

CREW:
| Domain | Load Skill |
|--------|------------|
| Mass refactoring | Skill({ skill: "crew:ast-grep" }) |
| Git conventions | Skill({ skill: "crew:git" }) |
| Skill creation | Skill({ skill: "crew:skill-builder" }) |
| Task tracking | Skill({ skill: "crew:todo-tracking" }) |

Load relevant skills FIRST based on the task domain.

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

SKILLS TO LOAD FIRST:
- Skill({ skill: "devtools:react" }) - for React/component patterns
- Skill({ skill: "devtools:design-principles" }) - for UI architecture

TOOLS:
- Use Codex MCP for design analysis
- MCPSearch to load: mcp__plugin_crew_codex__codex

CHECKLIST:
- [ ] Follows existing codebase patterns
- [ ] Follows skill constraints (check <constraints> sections)
- [ ] Proper separation of concerns
- [ ] No circular dependencies introduced
- [ ] Consistent naming conventions
- [ ] Appropriate abstraction levels
- [ ] No premature optimization

PROCESS:
1. Load relevant skills for the domain
2. Get changed files: ${changedFiles}
3. Compare patterns to skill constraints
4. Use Codex to analyze design decisions

OUTPUT: JSON array of findings with file, pattern_violation, recommendation`,
  run_in_background: true,
});

// 2b. UI/UX Review (for frontend changes)
Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "UI/UX review",
  prompt: `WORKER TASK: UI/UX quality review against design guidelines.

CONTEXT: Implementation complete. Check UI quality and accessibility.

SKILLS TO LOAD FIRST (MANDATORY):
- Skill({ skill: "devtools:vercel-design-guidelines" })
- Skill({ skill: "devtools:design-principles" })

CHECKLIST (from skills):
- [ ] Keyboard accessibility (focus management, tab order)
- [ ] Hit targets ≥24px (44px on mobile)
- [ ] Loading states don't flicker
- [ ] prefers-reduced-motion respected
- [ ] Form labels and error handling
- [ ] Color contrast meets APCA standards
- [ ] Spacing on 4px grid
- [ ] Consistent depth strategy (shadows/borders)

PROCESS:
1. Load both skills above
2. Get changed .tsx files: ${changedFiles} | grep -E "\\.(tsx|css)$"
3. For each UI file, check against skill success_criteria
4. Run validation scripts from design-principles skill

OUTPUT: JSON array with file, line, category (Interactions/Animations/Layout/etc), severity, issue, fix`,
  run_in_background: true,
});

// 3. Test Coverage Review
Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "Test coverage review",
  prompt: `WORKER TASK: Test coverage and quality review.

CONTEXT: Implementation complete. Verify test adequacy.

SKILLS TO LOAD FIRST:
- Skill({ skill: "devtools:vitest" }) - for unit test patterns
- Skill({ skill: "devtools:playwright" }) - for E2E test patterns

CHECKLIST:
- [ ] All new functions have tests
- [ ] Edge cases covered
- [ ] Error paths tested
- [ ] Integration points tested
- [ ] Mocks are appropriate (not over-mocking)
- [ ] Tests are deterministic
- [ ] Follows skill test patterns and locator strategies

PROCESS:
1. Load relevant test skills
2. Get changed implementation files: ${changedFiles}
3. Find corresponding test files
4. Analyze coverage gaps against skill success_criteria
5. Check test quality (not just quantity)

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

SKILLS TO LOAD FIRST:
- For React code: Skill({ skill: "devtools:react-best-practices" })
- For UI components: Skill({ skill: "devtools:vercel-design-guidelines" })
- For design patterns: Skill({ skill: "devtools:design-principles" })

CHECKLIST:
- [ ] Cognitive complexity acceptable (<15 per function)
- [ ] No dead code introduced
- [ ] No TODO/FIXME without tickets
- [ ] Type safety (no 'any' unless justified)
- [ ] Error handling complete
- [ ] Logging appropriate
- [ ] Follows skill success_criteria for relevant domains

PROCESS:
1. Load relevant skills based on file types
2. Get changed files: ${changedFiles}
3. Analyze each for quality issues against skill constraints
4. Check for anti-patterns defined in skills

OUTPUT: JSON array with file, line, issue, suggestion`,
  run_in_background: true,
});
```

### Aggregate and Triage Findings

After all reviewers complete, collect and triage:

```javascript
// Wait for all review agents (5 reviewers now including UI/UX)
const results = await Promise.all([
  TaskOutput({ task_id: securityReview.id }),
  TaskOutput({ task_id: architectureReview.id }),
  TaskOutput({ task_id: uiuxReview.id }),
  TaskOutput({ task_id: testReview.id }),
  TaskOutput({ task_id: qualityReview.id }),
]);

// Triage by severity
// P1: Block - must fix before proceeding
// P2: Fix - should fix, spawn workers
// P3: Note - document for future, proceed
```

### Apply Rule of Five for Complex Changes

For complex implementations, apply iterative review convergence:

```javascript
Skill({ skill: "devtools:rule-of-five" });
```

**When to apply multi-pass review:**

- Changes touch 5+ files
- Security-sensitive code
- Core architecture changes
- First review found 3+ P1/P2 issues

**Convergence process:**

1. After initial multi-domain review, if significant findings exist
2. Spawn fix workers for P1/P2 findings
3. Run review pass 2 (focus: did fixes introduce new issues?)
4. Repeat until review pass finds no new P1/P2 findings
5. Stop when converged or 5 passes completed

For simple changes (1-2 files, no P1 findings), single review pass suffices.

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
- [ ] Workers load relevant skills BEFORE starting (devtools:react, devtools:vitest, etc.)
- [ ] TDD followed (failing tests before implementation)
- [ ] Code refinement applied (code-simplifier used on changed files)
- [ ] Multi-domain review completed (security, architecture, UI/UX, tests, quality)
- [ ] UI/UX review uses devtools:vercel-design-guidelines and devtools:design-principles
- [ ] P1/P2 findings fixed before CI
- [ ] TodoWrite shows real-time progress
- [ ] Stories executed in priority order
- [ ] CI passing
- [ ] Git action completed per user choice

</success_criteria>
