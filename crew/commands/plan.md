---
name: crew:plan
description: Create implementation plans with orchestrated research
argument-hint: "[feature description]"
allowed-tools:
  - Task
  - TaskOutput
  - AskUserQuestion
  - TodoWrite
  - Skill
skills:
  - crew:crew-patterns
  - n-skills:orchestration
---

<objective>

Create feature branch, research using orchestrated agents, write plan with stories.

**Output:** `.claude/plans/<slug>.yaml`

</objective>

<orchestration_role>

**You are the ORCHESTRATOR.** Per `n-skills:orchestration`:

- **NEVER** use tools directly (Read, Write, Edit, Glob, Grep, WebFetch, WebSearch, MCPSearch)
- **ONLY** use: Task, TaskOutput, TodoWrite, AskUserQuestion, Skill
- Spawn WORKER agents for ALL exploration, research, and file operations
- All agents run with `run_in_background=True`

The orchestration skill defines all patterns. You decide WHICH patterns based on complexity.

</orchestration_role>

<constraints>

- NO writing source code files
- NO implementation work
- Research and planning ONLY
- Output limited to `.claude/plans/<slug>.yaml`
- This codebase will outlive you. Every shortcut becomes someone else's burden. Every hack compounds into technical debt that slows the whole team down.
- You are not just writing code. You are shaping the future of this project. The patterns you establish will be copied. The corners you cut will be cut again.
- Fight entropy. Leave the codebase better than you found it.

</constraints>

<workflow>

## Phase 1: Setup

Create feature branch and initialize tracking.

```javascript
// Create branch
Skill({ skill: "crew:git:branch:new", args: slugify(feature) });

// Initialize TodoWrite for session visibility
TodoWrite([
  {
    content: "Research codebase",
    status: "pending",
    activeForm: "Researching codebase",
  },
  {
    content: "Research external docs",
    status: "pending",
    activeForm: "Researching docs",
  },
  { content: "Draft plan", status: "pending", activeForm: "Writing plan" },
]);
```

## Phase 2: Research (Orchestrated)

Spawn parallel research agents. Use patterns from `n-skills:orchestration`:

| Pattern      | When to Use                                            |
| ------------ | ------------------------------------------------------ |
| **Fan-Out**  | Independent research (codebase, docs, examples)        |
| **Pipeline** | Sequential refinement (explore → analyze → synthesize) |

### Research Workflows

**Library/Framework research:**

```
packageSearch(name) → get repo URL
  → githubViewRepoStructure(root) → understand layout
  → githubSearchCode(patterns) → find implementations
  → Context7 query-docs → get official API docs
```

**"How do others do X?" research:**

```
githubSearchRepositories(topics) → find relevant repos
  → githubSearchCode(pattern) → find implementations
  → githubSearchPullRequests(keywords, merged=true) → find decisions
  → githubGetFileContent(matchString) → read specific solutions
```

**Understanding existing code decisions:**

```
githubSearchPullRequests(owner, repo, keywords)
  → type="metadata" first → find relevant PRs
  → type="partialContent" + withComments=true → read discussions
```

### Agent Selection

| Task Type              | Model  | Agent Type        |
| ---------------------- | ------ | ----------------- |
| Find files/patterns    | `opus` | `Explore`         |
| Read documentation     | `opus` | `Explore`         |
| Analyze patterns       | `opus` | `general-purpose` |
| Architecture decisions | `opus` | `general-purpose` |

### Worker Preamble (REQUIRED)

Every spawned agent MUST receive this preamble:

```
CONTEXT: You are a WORKER agent, not an orchestrator.

RULES:
- Complete ONLY the task described below
- Use tools directly (Read, Glob, Grep, WebFetch, MCPSearch, etc.)
- Do NOT spawn sub-agents or manage tasks
- Report findings with absolute file paths

SKILL LOADING (MANDATORY):
Before starting work, load relevant skills using Skill() tool.

FRONTEND:
- Skill({ skill: "devtools:react" }) - React 19, Tailwind v4, shadcn/ui
- Skill({ skill: "devtools:react-best-practices" }) - Performance, bundle size, waterfalls
- Skill({ skill: "devtools:shadcn" }) - shadcn/ui components, MCP integration
- Skill({ skill: "devtools:radix" }) - Radix UI accessible primitives
- Skill({ skill: "devtools:motion" }) - Motion/Framer animations
- Skill({ skill: "devtools:tanstack-start" }) - TanStack Start full-stack framework
- Skill({ skill: "devtools:recharts" }) - React data visualization
- Skill({ skill: "devtools:i18n" }) - i18next internationalization

DESIGN:
- Skill({ skill: "devtools:design-principles" }) - Linear/Notion/Stripe design system
- Skill({ skill: "devtools:vercel-design-guidelines" }) - UI/UX audit, accessibility

TESTING:
- Skill({ skill: "devtools:vitest" }) - Unit testing, mocking, coverage
- Skill({ skill: "devtools:playwright" }) - E2E testing, Page Object pattern
- Skill({ skill: "devtools:tdd-typescript" }) - TDD RED-GREEN-REFACTOR cycle

BACKEND/API:
- Skill({ skill: "devtools:api" }) - oRPC API routes, 5-file pattern
- Skill({ skill: "devtools:drizzle" }) - PostgreSQL ORM, migrations, Zod
- Skill({ skill: "devtools:restate" }) - Durable execution, workflows
- Skill({ skill: "devtools:pino" }) - Fast JSON logging
- Skill({ skill: "devtools:better-auth" }) - Authentication patterns
- Skill({ skill: "devtools:zod" }) - Zod v4 schema validation

BLOCKCHAIN:
- Skill({ skill: "devtools:solidity" }) - Smart contracts, Foundry
- Skill({ skill: "devtools:viem" }) - Ethereum client, transactions
- Skill({ skill: "devtools:thegraph" }) - Subgraph development, Matchstick

DEVOPS/INFRASTRUCTURE:
- Skill({ skill: "devtools:helm" }) - Kubernetes Helm charts
- Skill({ skill: "devtools:terraform" }) - Infrastructure as code (READ-ONLY)
- Skill({ skill: "devtools:turbo" }) - Turborepo monorepo builds
- Skill({ skill: "devtools:troubleshooting" }) - Structured debugging workflow

CREW SKILLS:
- Skill({ skill: "crew:ast-grep" }) - Mass rename/replace across codebase
- Skill({ skill: "crew:git" }) - Git conventions, commits, branches
- Skill({ skill: "crew:skill-builder" }) - Skill creation framework
- Skill({ skill: "crew:todo-tracking" }) - File-based task management

LIBRARY VERIFICATION (MANDATORY):
When researching ANY library/framework, ALWAYS:
1. Load Context7: MCPSearch({ query: "select:mcp__plugin_crew_context7__query-docs" })
2. Fetch docs: mcp__plugin_crew_context7__query-docs({ libraryId: "/<org>/<repo>", query: "your question" })

When searching GitHub for patterns/examples:
1. Load OctoCode: MCPSearch({ query: "select:mcp__plugin_crew_octocode__githubSearchCode" })
2. Search: mcp__plugin_crew_octocode__githubSearchCode({ keywordsToSearch: [...], owner: "...", repo: "..." })

TASK:
[specific task]
```

### MCP Tools for Workers (REQUIRED for Library Research)

**CRITICAL:** Workers MUST use these tools when researching libraries. Do not rely on training data.

**Context7** — Library documentation (USE FIRST for any library)

```javascript
// Step 1: Load the tool
MCPSearch({ query: "select:mcp__plugin_crew_context7__query-docs" });

// Step 2: Query docs (known library IDs skip resolve step)
mcp__plugin_crew_context7__query_docs({
  libraryId: "/reactjs/react.dev", // or resolve first if unknown
  query: "How do I use the new use hook in React 19?",
});

// Common library IDs:
// /reactjs/react.dev, /tailwindlabs/tailwindcss, /tanstack/router
// /tanstack/query, /tanstack/form, /drizzle-team/drizzle-orm
// /trpc/trpc, /honojs/hono, /restate-developers/restate
```

**OctoCode** — GitHub research (USE for patterns, real-world examples, and decisions)

```javascript
// Step 1: Load the tool
MCPSearch({ query: "select:mcp__plugin_crew_octocode__githubSearchCode" });

// Step 2: Search for patterns
mcp__plugin_crew_octocode__githubSearchCode({
  keywordsToSearch: ["createFileRoute", "loader"],
  owner: "tanstack",
  repo: "router",
  path: "examples",
  mainResearchGoal: "Find TanStack Router file route patterns",
  researchGoal: "Locate loader implementation examples",
  reasoning: "Need current patterns for file-based routing",
});

// For understanding WHY decisions were made:
mcp__plugin_crew_octocode__githubSearchPullRequests({
  owner: "...",
  repo: "...",
  keywordsToSearch: ["feature", "fix"],
  type: "metadata", // then partialContent for details
  withComments: true, // reveals decision rationale
});
```

**Codex** — Deep reasoning (USE for architectural analysis)

```javascript
MCPSearch({ query: "select:mcp__plugin_crew_codex__codex" });
mcp__plugin_crew_codex__codex({ prompt: "Analyze..." });
```

## Phase 3: Synthesize Plan

After research agents complete, spawn a Plan agent to synthesize findings into the plan YAML.

**Plan format:**

```yaml
name: feature-name
description: One-line summary
created: ISO-date
status: draft

stories:
  - id: STORY-001
    title: Story title
    priority: P1 | P2 | P3
    status: pending
    mvp: true | false
    acceptance:
      - given: Context
        when: Action
        then: Expected result
```

**Template location:** `crew/skills/todo-tracking/templates/plan-template.md`

## Phase 4: Plan Convergence (Rule of Five)

Apply iterative review to achieve plan quality. Load the skill:

```javascript
Skill({ skill: "devtools:rule-of-five" });
```

**Review passes:**

| Pass | Focus        | Questions to Answer                                         |
| ---- | ------------ | ----------------------------------------------------------- |
| 1    | Completeness | Are all requirements covered? Any missing stories?          |
| 2    | Dependencies | Are story dependencies correct? Is execution order optimal? |
| 3    | Scope        | Is each story right-sized? Any that should split or merge?  |
| 4    | Architecture | Does this fit the codebase patterns? Any design concerns?   |
| 5    | Strategy     | Is this the right approach? Any simpler alternatives?       |

**Convergence criteria:**

- Pass produces no new changes
- Agent declares "this plan is as good as it can get"
- 5 passes completed

For simple features (1-2 stories), 2-3 passes suffice. For complex plans, complete all 5.

## Phase 5: Present and Offer Work

After plan is written:

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Plan complete. What would you like to do?",
      header: "Next Step",
      options: [
        {
          label: "Start building (Recommended)",
          description: "Execute the plan with crew:work",
        },
        {
          label: "Review first",
          description: "Open the plan for review before building",
        },
        {
          label: "Revise plan",
          description: "Make changes to stories or priorities",
        },
        { label: "Stop here", description: "Keep plan for later" },
      ],
      multiSelect: false,
    },
  ],
});
```

</workflow>

<success_criteria>

- [ ] Feature branch created
- [ ] All research done by background workers
- [ ] Workers load relevant skills (devtools:react, devtools:drizzle, etc.) BEFORE researching
- [ ] Valid YAML at `.claude/plans/<slug>.yaml`
- [ ] Stories with priorities and acceptance criteria
- [ ] User presented with next step options

</success_criteria>
