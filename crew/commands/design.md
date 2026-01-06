---
name: crew:design
description: Create validated implementation plans with research
argument-hint: "[feature description, bug report, or improvement idea]"
---

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

<constraints>

- **NEVER CODE** - This command researches and writes plans only
- **EnterPlanMode first** - Call before any research
- **Branch early** - Set up before research so state writes to correct directory
- **9 agents + Codex** - Launch ALL research in single message
- **spec-flow-analyzer last** - Runs after all research collected

</constraints>

<process>

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

<phase name="enter-plan-mode">
```javascript
EnterPlanMode();
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
Launch ALL 9 agents in SINGLE message using `<pattern name="research-agents"/>`:

**Foundational (3):**

- `repo-research-analyst` - Codebase patterns, conventions
- `best-practices-researcher` - 2026 best practices (use Context7, OctoCode MCP)
- `git-history-analyzer` - Historical context, past decisions

**Dimension analysis (6):**

- `api-interface-analyst` - Endpoints, schemas, versioning
- `data-model-architect` - Entities, migrations, constraints
- `ux-workflow-analyst` - User journeys, accessibility
- `scale-performance-analyst` - Capacity, bottlenecks, caching
- `security-threat-analyst` - STRIDE model, OWASP compliance
- `integration-dependency-analyst` - External services, failure modes

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
// Collect ALL 9 agent results
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
Write to `.claude/plans/<feature-slug>.md`:

```markdown
# Plan: [Feature Name]

**Branch**: `feat/<slug>`
**Status**: Draft

## Problem Statement

[From spec analysis]

## User Stories

### US1 - [Title] (P1) 🎯 MVP

[Description]
**Acceptance**: Given X, When Y, Then Z

## Functional Requirements

- FR-001: [requirement]

## Technical Approach

[From Codex synthesis]

## Dimension Analyses

### API Design | Data Model | UX | Scale | Security | Integrations

[From respective analysts]

## Success Criteria

- SC-001: [criterion]

## Open Questions

[Max 3 NEEDS CLARIFICATION items]
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

<phase name="exit-plan-mode">
```javascript
ExitPlanMode();
```

Output:

```
Plan approved. To start building, run: /crew:build

Files created:
- Plan: .claude/plans/<slug>.md
- Tasks: .claude/branches/<branch>/tasks/*.md (X tasks)
```

**If user confirms to start building:**

```javascript
Skill({ skill: "crew:build", args: "<slug>" });
```

</phase>

</process>

<success_criteria>

- [ ] EnterPlanMode called at start
- [ ] Branch created before research
- [ ] All 9 research agents launched in single message
- [ ] Codex MCP called directly for synthesis
- [ ] spec-flow-analyzer runs after all research collected
- [ ] Plan contains user stories with P1/P2/P3 priorities
- [ ] Plan contains FR-XXX requirements and SC-XXX criteria
- [ ] Plan contains all 6 dimension analyses
- [ ] Task files follow naming convention
- [ ] Each task has acceptance criteria
- [ ] ExitPlanMode called at end

</success_criteria>
