---
name: crew:plan
description: Create implementation plans with orchestrated research
argument-hint: "[feature description]"
allowed-tools:
  - Read
  - Write
  - Glob
  - Grep
  - Bash
  - Task
  - WebFetch
  - WebSearch
  - MCPSearch
  - AskUserQuestion
  - TodoWrite
  - Skill
skills:
  - crew:crew-patterns
  - n-skills:orchestration
---

<objective>

Create feature branch. Research using orchestrated agents (Claude decides which). Write plan with stories. Output: `.claude/plans/<slug>.yaml`

</objective>

<critical_constraints>

**THIS IS A PLANNING COMMAND - NOT AN IMPLEMENTATION COMMAND**

- NO writing source code files
- NO build/test commands
- ONLY output: `.claude/plans/<slug>.yaml`

</critical_constraints>

<workflow>

## Step 1: Create Feature Branch

```javascript
const slug = slugify(feature); // kebab-case, max 30 chars
Skill({ skill: "crew:git:branch:new", args: slug });
```

## Step 2: Initialize Tracking

```javascript
TodoWrite([
  {
    content: "Research codebase",
    status: "pending",
    activeForm: "Researching",
  },
  { content: "Draft plan", status: "pending", activeForm: "Writing plan" },
  { content: "Finalize", status: "pending", activeForm: "Finalizing" },
]);
```

## Step 3: Research (Claude Decides Agents)

Use Task tool to spawn research agents as needed. Per n-skills:orchestration, Claude decides:

- **Which agents**: Based on feature complexity
- **How many**: Parallel for independent research, sequential for dependencies
- **Tier**: Haiku for quick lookups, Sonnet for analysis, Opus for architecture

### MCP Tools for Research (REQUIRED)

```javascript
// Library documentation - ALWAYS use for framework questions
MCPSearch({ query: "select:mcp__plugin_crew_context7__resolve-library-id" });
MCPSearch({ query: "select:mcp__plugin_crew_context7__query-docs" });

// GitHub search - use for patterns, examples
MCPSearch({ query: "select:mcp__plugin_crew_octocode__githubSearchCode" });
MCPSearch({
  query: "select:mcp__plugin_crew_octocode__githubViewRepoStructure",
});

// Codex - deep reasoning for architecture decisions
MCPSearch({ query: "select:mcp__plugin_crew_codex__codex" });
```

### When to Use Codex

For complex architectural decisions requiring deep reasoning:

```javascript
mcp__plugin_crew_codex__codex({
  prompt: `Analyze architecture options for ${feature}:

CONTEXT: ${codebasePatterns}

Evaluate: trade-offs, scalability, maintainability.
Recommend: approach with rationale.`,
});
```

### Example Research Tasks

```javascript
// Codebase analysis
Task({
  subagent_type: "Explore",
  prompt: `Find: key files, patterns for ${feature}`,
  description: "codebase-research",
  run_in_background: true,
});

// External docs (use Context7 MCP)
Task({
  subagent_type: "general-purpose",
  prompt: `Research best practices for ${feature} using Context7 MCP`,
  description: "docs-research",
  run_in_background: true,
});
```

## Step 4: Write Plan

```javascript
Read({
  file_path: `${CLAUDE_PLUGIN_ROOT}/skills/todo-tracking/templates/plan-template-llm.yaml`,
});
Write({ file_path: `.claude/plans/${slug}.yaml`, content: plan });
```

Plan structure:

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

## Step 5: Present and Ask to Start

```javascript
console.log(`Plan complete: .claude/plans/${slug}.yaml`);

const response = AskUserQuestion({
  questions: [
    {
      question: "Plan ready. Start building?",
      options: ["Yes, start building", "No, review first"],
    },
  ],
});

if (response === "Yes, start building") {
  Skill({ skill: "crew:work", args: slug });
}
```

</workflow>

<success_criteria>

- [ ] Feature branch created
- [ ] Research completed (using MCP tools)
- [ ] Valid YAML at `.claude/plans/<slug>.yaml`
- [ ] Stories with priorities and acceptance criteria
- [ ] User asked before starting work

</success_criteria>
