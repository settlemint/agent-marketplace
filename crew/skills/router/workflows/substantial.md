# Substantial Workflow

**Purpose:** Plan and execute complex features that require research, multiple stories, and orchestrated work.

## When This Runs

User requests a non-trivial feature or change:

- "Add user authentication with OAuth"
- "Implement a caching layer"
- "Refactor the database schema"
- "Build a dashboard for analytics"

## Characteristics of Substantial Requests

- **Multiple components:** Several files, systems, or modules
- **Requires research:** Needs codebase exploration, library docs
- **Non-obvious solution:** Multiple valid approaches exist
- **Risk of scope creep:** Could expand if not planned

## Workflow

### Phase 1: Setup

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

// Update state to PLANNING mode
updateState({
  routing: {
    current_mode: "planning",
    entered_at: new Date().toISOString(),
    classification: "substantial",
  },
});
```

### Phase 2: Research (Orchestrated)

Spawn parallel research agents using the orchestration skill patterns.

```javascript
// Load orchestration patterns
Skill({ skill: "n-skills:orchestration" });
```

**Agent Types:**

| Task Type              | Model  | Agent Type        |
| ---------------------- | ------ | ----------------- |
| Find files/patterns    | `opus` | `Explore`         |
| Read documentation     | `opus` | `Explore`         |
| Analyze patterns       | `opus` | `general-purpose` |
| Architecture decisions | `opus` | `general-purpose` |

**MCP Tools for Research (REQUIRED):**

Workers MUST use Context7 for library docs and OctoCode for GitHub patterns:

```javascript
// Load tools first
MCPSearch({ query: "select:mcp__plugin_crew_context7__query-docs" });
MCPSearch({ query: "select:mcp__plugin_crew_octocode__githubSearchCode" });
```

### Phase 3: Synthesize Plan

After research agents complete, spawn a Plan agent to create the plan YAML.

**Plan format:** `.claude/plans/<slug>.yaml`

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

### Phase 4: Plan Convergence

Apply iterative review for plan quality:

| Pass | Focus        | Questions                        |
| ---- | ------------ | -------------------------------- |
| 1    | Completeness | Are all requirements covered?    |
| 2    | Dependencies | Is execution order optimal?      |
| 3    | Scope        | Is each story right-sized?       |
| 4    | Architecture | Does this fit codebase patterns? |
| 5    | Strategy     | Is this the right approach?      |

For simple features (1-2 stories), 2-3 passes suffice.

### Phase 5: Present Plan and Offer Work

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Plan complete. What would you like to do?",
      header: "Next Step",
      options: [
        { label: "Start building", description: "Execute the plan now" },
        { label: "Review first", description: "Open the plan for review" },
        { label: "Revise plan", description: "Make changes to stories" },
        { label: "Stop here", description: "Keep plan for later" },
      ],
      multiSelect: false,
    },
  ],
});
```

### Phase 6: Transition to Work (If Approved)

If user approves building:

```javascript
// Update state to WORKING mode
updateState({
  routing: {
    current_mode: "working",
    entered_at: new Date().toISOString(),
  },
});

// Read and follow the adaptive work workflow
// This handles probe-based execution, metrics, and failure budgets
Read({ file_path: "crew/skills/router/workflows/work-adaptive.md" });
// Then follow that workflow
```

## State Updates

| Event          | Mode       | Persistence |
| -------------- | ---------- | ----------- |
| Workflow start | `planning` | state.json  |
| Plan approved  | `working`  | state.json  |
| Work complete  | `complete` | state.json  |
| User stops     | `idle`     | state.json  |

## Constraints

- **NO writing source code** during planning
- Research and planning ONLY in Phases 1-5
- Output limited to `.claude/plans/<slug>.yaml`
- This codebase will outlive you. Every shortcut becomes someone else's burden.

## Success Criteria

- [ ] Feature branch created
- [ ] All research done by background workers
- [ ] Workers load relevant skills BEFORE researching
- [ ] Valid YAML at `.claude/plans/<slug>.yaml`
- [ ] Stories with priorities and acceptance criteria
- [ ] User presented with next step options
- [ ] State reflects current mode (planning/working)
