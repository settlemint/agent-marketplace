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

| Task Type              | Model   | Agent Type        |
| ---------------------- | ------- | ----------------- |
| Find files/patterns    | `haiku` | `Explore`         |
| Read documentation     | `haiku` | `Explore`         |
| Analyze patterns       | `opus`  | `general-purpose` |
| Architecture decisions | `opus`  | `general-purpose` |

### Worker Preamble (REQUIRED)

Every spawned agent MUST receive this preamble:

```
CONTEXT: You are a WORKER agent, not an orchestrator.

RULES:
- Complete ONLY the task described below
- Use tools directly (Read, Glob, Grep, WebFetch, MCPSearch, etc.)
- Do NOT spawn sub-agents or manage tasks
- Report findings with absolute file paths

TASK:
[specific task]
```

### MCP Tools for Workers

Workers should use these MCP tools for research:

**Context7** — Library documentation

- `resolve-library-id` → `query-docs` for framework/library docs

**OctoCode** — GitHub research (powerful for patterns and decisions)

- `packageSearch` → Find package repo URLs (start here for libraries)
- `githubViewRepoStructure` → Explore repo layout (root first, then drill)
- `githubSearchCode` → Find patterns across repos (use owner+repo for precision)
- `githubGetFileContent` → Read specific files (use matchString for large files)
- `githubSearchPullRequests` → **Code archaeology**: understand WHY code was written
  - Use `type="metadata"` first, then `partialContent` for specific files
  - `withComments=true` reveals decision rationale

**Codex** — Deep reasoning

- `codex` for architectural analysis requiring extended thinking

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

## Phase 4: Present and Offer Work

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
- [ ] Valid YAML at `.claude/plans/<slug>.yaml`
- [ ] Stories with priorities and acceptance criteria
- [ ] User presented with next step options

</success_criteria>
