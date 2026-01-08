---
name: crew:design
description: Create validated implementation plans with research
argument-hint: "[feature description, bug report, or improvement idea]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
  - TodoWrite
  - WebFetch
  - WebSearch
  - MCPSearch
  - Skill
skills:
  - crew:crew-patterns
  - crew:todo-tracking
---

<worktree_status>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/worktree-context.sh`
</worktree_status>

<stack_context>
!`${CLAUDE_PLUGIN_ROOT}/scripts/git/machete-context.sh`
</stack_context>

<prerequisite>

**Load patterns skill first:**

```javascript
Skill({ skill: "crew:crew-patterns" });
```

This provides: `<pattern name="research-agents"/>`, `<pattern name="task-file"/>`.

</prerequisite>

<input>
<feature_description>$ARGUMENTS</feature_description>
</input>

<output_files>

1. **Plan** → `.claude/plans/<feature-slug>.md`
2. **Task files** → `.claude/branches/<slugified-branch>/tasks/*.md`

</output_files>

<notes>
- **NEVER CODE** - This command researches and writes plans only
- Branch early for state directory, agents per @rules/agent-limits.md
- spec-flow-analyzer runs after all research collected
</notes>

<process>

<phase name="memory-recall">
**Query claude-mem for past learnings before expensive research:**

```javascript
// Search for relevant past decisions, discoveries, gotchas
mcp__claude_mem__search({
  query: "<feature keywords>",
  type: "decision,discovery,bugfix",
  limit: 10
});

// If relevant results found (~50 tokens per result), evaluate ROI
// Fetch full details only for high-relevance matches
mcp__claude_mem__get_observations({
  ids: [relevant_ids]  // ~500 tokens per observation
});
```

**Why:** Prevents re-discovering known gotchas and respects past architectural decisions. Costs ~1000 tokens vs re-researching from scratch.

**CRITICAL - Memory vs Current Request:**
- Memory INFORMS, never OVERRIDES the user's explicit request
- User's current ask ALWAYS takes priority over past observations
- If memory suggests approach X but user asks for approach Y → follow user's request
- If memory conflicts with current request, use AskUserQuestion:

```javascript
AskUserQuestion({
  questions: [{
    question: "I found a past observation that suggests [X], but your current request implies [Y]. Which approach should I follow?",
    options: [
      "Follow my current request (Y)",
      "Use the past approach (X)",
      "Explain both so I can decide"
    ]
  }]
});
```

**Skip if:** No claude-mem MCP available or empty results.
</phase>

<phase name="validate-input">
If empty or unclear:
```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like to design?",
    header: "Type",
    options: [
      { label: "New feature", description: "Add new functionality" },
      { label: "Bug fix", description: "Fix an existing issue" },
      { label: "Refactoring", description: "Improve code structure" },
      { label: "Infrastructure", description: "DevOps or tooling" }
    ],
    multiSelect: false
  }]
});
```
</phase>

<phase name="branch-setup">
```javascript
const branch = Bash({ command: "git branch --show-current" }).trim();
if (branch === "main" || branch === "master") {
  // AskUserQuestion: feature branch or stacked branch
  Bash({ command: `git checkout -b feat/${slug}` });
}
// If stacked: git machete add --onto <parent>
```
</phase>

<phase name="parallel-research">
Launch ALL 4 agents in SINGLE message using `<pattern name="research-agents"/>`:

- `codebase-analyst` - Repository structure, patterns, conventions, git history
- `docs-researcher` - External best practices via Context7/OctoCode MCP
- `architecture-analyst` - API design, data models, external integrations
- `quality-analyst` - Performance, security (STRIDE), UX, accessibility

**Plus Codex MCP** (direct call, not Task):

```javascript
MCPSearch({ query: "select:mcp__plugin_crew_codex__codex" });
mcp__plugin_crew_codex__codex({
  question: `Architecture design for: ${feature}. Key decisions, trade-offs, risks?`,
});
```

</phase>

<phase name="collect-research">
```javascript
// Collect ALL 4 agent results
const results = {};
for (const agent of agents) {
  results[agent.type] = TaskOutput({ task_id: agent.id, block: true });
}
```
</phase>

<phase name="spec-analysis">
Launch spec-flow-analyzer with ALL research context:
```javascript
Task({
  subagent_type: "spec-flow-analyzer",
  prompt: `CONTEXT: ${feature}\nRESEARCH: ${JSON.stringify(results)}\nOUTPUT: User stories (P1/P2/P3), FR-XXX requirements, SC-XXX success criteria, gaps`,
  run_in_background: false
});
```
</phase>

<phase name="write-plan">
Write to `.claude/plans/<feature-slug>.md` using the plan template:

```javascript
// Read template and populate with research findings
Read({
  file_path: `${CLAUDE_PLUGIN_ROOT}/skills/todo-tracking/templates/plan-template.md`,
});

// Fill in template with:
// - Problem Statement: From spec analysis
// - User Stories: From spec-flow-analyzer (P1/P2/P3 priorities)
// - Functional Requirements: FR-XXX requirements
// - Technical Approach: From Codex synthesis
// - Codebase Context: From codebase-analyst
// - External Research: From docs-researcher
// - Architecture: From architecture-analyst (API, Data, Integrations)
// - Quality: From quality-analyst (Performance, Security, UX)
// - Success Criteria: SC-XXX criteria
// - Open Questions: Max 3 NEEDS CLARIFICATION items
```

</phase>

<phase name="generate-tasks">
Create task files using `<pattern name="task-file"/>`:

```javascript
const slugBranch = branch.replace(/\//g, "-");
Bash({ command: `mkdir -p .claude/branches/${slugBranch}/tasks` });

// Naming: {order}-{status}-{priority}-{story}-{slug}.md
// 001-009: setup tasks
// 010-019: us1 tasks
// 020-029: us2 tasks
// 090-099: polish tasks
```

Story labels: `setup`, `found`, `us1`, `us2`, `us3`, `polish`
</phase>

<phase name="present-plan">
**Print the full plan content:**

```javascript
// Read and output the entire plan file
const planContent = Read({ file_path: `.claude/plans/${slug}.md` });
// Output the plan content directly to the user (not a summary)
```

Output the complete plan content followed by:

```
Files created:
- Plan: .claude/plans/<slug>.md
- Tasks: .claude/branches/<branch>/tasks/*.md (X tasks)
```

**Then ask user to continue:**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "Ready to start building this plan?",
      header: "Next step",
      options: [
        {
          label: "Start building",
          description: "Run /crew:build to implement the plan",
        },
        {
          label: "Interview first",
          description: "Flesh out details with /crew:interview before building",
        },
        {
          label: "Edit plan first",
          description: "Make manual changes before building",
        },
        { label: "Just save", description: "Save the plan for later" },
      ],
      multiSelect: false,
    },
    {
      question: "Add this branch to the machete stack?",
      header: "Stacking",
      options: [
        {
          label: "Stack on main",
          description: "Add branch to stack with main as parent (Recommended)",
        },
        {
          label: "Stack on current",
          description: "Add branch stacked on the current parent branch",
        },
        {
          label: "No stacking",
          description: "Keep branch independent, not in machete stack",
        },
      ],
      multiSelect: false,
    },
    {
      question: "Enable iteration loop during build?",
      header: "Loop mode",
      options: [
        {
          label: "With loop",
          description: "Iterate until all tasks pass CI checks (Recommended)",
        },
        {
          label: "Single pass",
          description: "Run build once without automatic iteration",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

**Based on responses:**

Stacking (execute first if building):

- "Stack on main" → `Bash({ command: "git machete add --onto main" });`
- "Stack on current" → `Bash({ command: "git machete add" });` (uses current parent)
- "No stacking" → No machete action

Next step:

- "Start building" + "With loop" → `Skill({ skill: "crew:build", args: "<slug> --loop" });`
- "Start building" + "Single pass" → `Skill({ skill: "crew:build", args: "<slug>" });`
- "Interview first" → `SlashCommand({ command: "/crew:interview .claude/plans/<slug>.md" });`
- "Edit plan first" → Tell user to edit `.claude/plans/<slug>.md` and run `/crew:build` when ready
- "Just save" → Confirm plan saved, no further action

</phase>

</process>

<success_criteria>

- [ ] claude-mem queried for past learnings (if available)
- [ ] Branch created before research
- [ ] All 4 research agents launched in single message
- [ ] Codex MCP called directly for synthesis
- [ ] spec-flow-analyzer runs after all research collected
- [ ] Plan contains user stories with P1/P2/P3 priorities
- [ ] Plan contains FR-XXX requirements and SC-XXX criteria
- [ ] Plan contains architecture and quality analyses
- [ ] Task files follow naming convention
- [ ] Each task has acceptance criteria
- [ ] Full plan content printed to user (not just summary)
- [ ] AskUserQuestion used to offer building option

</success_criteria>
