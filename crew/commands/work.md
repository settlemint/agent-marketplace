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

TASK:
[specific task with acceptance criteria]
```

### MCP Tools for Workers

Workers should use these MCP tools when needed:

**Context7** — Library documentation

- `resolve-library-id` → `query-docs` for API references and examples

**OctoCode** — GitHub research (use during implementation blocks)

- `packageSearch` → Find package source repos
- `githubSearchCode` → Find real-world usage patterns
- `githubGetFileContent` → Read library internals when docs are unclear
- `githubSearchPullRequests` → Find how others solved similar problems
  - Search merged PRs with `keywordsToSearch` matching your problem
  - `withComments=true` reveals solutions and gotchas

**Codex** — Deep reasoning (use sparingly)

- Security reviews, complex debugging, architecture decisions

</worker_requirements>

<workflow>

## Phase 1: Setup

Spawn a haiku worker to:

1. Verify not on main branch
2. Read the plan file and return story list

```javascript
Task({
  subagent_type: "Explore",
  model: "haiku",
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

| Task Complexity        | Model   | Agent Type        |
| ---------------------- | ------- | ----------------- |
| Single file, simple    | `opus`  | `general-purpose` |
| Multi-file, moderate   | `opus`  | `general-purpose` |
| Security-critical      | `opus`  | `general-purpose` |
| Architecture decisions | `opus`  | `Plan`            |
| Exploration/research   | `haiku` | `Explore`         |

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

## Phase 4: Run CI

```javascript
Skill({ skill: "crew:work:ci", args: slug });
```

If CI fails, spawn workers to fix failures. Repeat until green.

## Phase 5: Completion

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
- [ ] TodoWrite shows real-time progress
- [ ] Stories executed in priority order
- [ ] CI passing
- [ ] Git action completed per user choice

</success_criteria>
