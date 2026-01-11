---
name: crew:plan
description: Create implementation plans with multi-agent orchestration
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

Create feature branch. Research with parallel agents. Write draft plan with `open_questions`. Refine until complete. Output: `.claude/plans/<slug>.yaml`

</objective>

<critical_constraints>

**THIS IS A PLANNING COMMAND - NOT AN IMPLEMENTATION COMMAND**

❌ FORBIDDEN ACTIONS:

- Writing, editing, or creating source code files
- Making changes to the codebase
- Running build/test commands
- Creating or modifying any file outside `.claude/plans/`
- Skipping to implementation before plan is approved

✅ ALLOWED ACTIONS:

- Reading files for research
- Running git commands to analyze diffs
- Spawning research agents
- Writing plan files to `.claude/plans/<slug>.yaml`
- Asking user questions to clarify requirements

**OUTPUT**: The ONLY file you create is `.claude/plans/<slug>.yaml`

If you find yourself about to write code or edit source files, STOP. You are in planning mode. Follow the workflow steps in order.

</critical_constraints>

<workflow>

## Step 1: Create Feature Branch

```javascript
const slug = slugify(feature); // kebab-case, max 30 chars
Skill({ skill: "crew:git:branch:new", args: slug });
```

## Step 2: Initialize Tracking

```javascript
// Icons: ○ ready, ● blocked, ✓ complete
TodoWrite([
  {
    content: "#1 ○ Codebase analysis",
    status: "pending",
    activeForm: "Analyzing codebase",
  },
  {
    content: "#2 ○ Docs research",
    status: "pending",
    activeForm: "Researching docs",
  },
  {
    content: "#3 ○ Architecture design",
    status: "pending",
    activeForm: "Designing architecture",
  },
  {
    content: "#4 ○ Quality analysis",
    status: "pending",
    activeForm: "Analyzing quality",
  },
  {
    content: "#5 ● Draft plan ⚠ blocked by #1-4",
    status: "pending",
    activeForm: "Writing draft",
  },
  {
    content: "#6 ● Review ⚠ blocked by #5",
    status: "pending",
    activeForm: "Reviewing",
  },
]);
```

## Step 3: Spawn Research Agents (parallel, background)

```javascript
// All 4 research agents in parallel
Task({
  subagent_type: "crew:design:codebase-analyst",
  prompt: `Feature: ${feature}. Find: key files, patterns, anti-patterns. List open_questions: ambiguities, unclear integration points.`,
  description: "codebase",
  run_in_background: true,
});

Task({
  subagent_type: "crew:design:docs-researcher",
  prompt: `Feature: ${feature}. Find: best practices, examples, gotchas. List open_questions: multiple valid approaches needing decision.`,
  description: "docs",
  run_in_background: true,
});

Task({
  subagent_type: "crew:design:architecture-analyst",
  prompt: `Feature: ${feature}. Design: components, interfaces, data flow. List open_questions: trade-offs needing user input.`,
  description: "architecture",
  run_in_background: true,
});

Task({
  subagent_type: "crew:design:quality-analyst",
  prompt: `Feature: ${feature}. Analyze: performance, security (STRIDE), UX. List open_questions: unspecified requirements, scale unknowns.`,
  description: "quality",
  run_in_background: true,
});
```

## Step 4: Collect Results

```javascript
for (const agent of agents) {
  research[agent.type] = TaskOutput({ task_id: agent.id, block: true });
}
// TodoWrite: #1-4 ✓, #5 in_progress
```

## Step 5: Write Draft Plan

```javascript
Read({
  file_path: `${CLAUDE_PLUGIN_ROOT}/skills/todo-tracking/templates/plan-template-llm.yaml`,
});
Write({ file_path: `.claude/plans/${slug}.yaml`, content: populatedTemplate });
// TodoWrite: #1-5 ✓
```

**open_questions**: Generate comprehensive questions covering:

- Ambiguous requirements needing clarification
- Technical decisions with multiple valid approaches
- Edge cases and error handling unclear from spec
- Integration points needing confirmation
- Performance/scale requirements if unspecified

Mark `blocking: true` for questions that must be resolved before implementation.

## Step 6: Review Plan

```javascript
// Reviews plan, adds open_questions, updates file
Skill({ skill: "crew:plan:review", args: `.claude/plans/${slug}.yaml` });

// Reload plan to check for open_questions
const plan = Read({ file_path: `.claude/plans/${slug}.yaml` });
// TodoWrite: #1-5 ✓, #6 in_progress
```

## Step 7: Refine Loop

```javascript
// If open questions exist, refine is required (not optional)
while (plan.open_questions?.length > 0) {
  // Resolve current questions
  Skill({ skill: "crew:plan:refine", args: `.claude/plans/${slug}.yaml` });

  // Review may find new questions
  Skill({ skill: "crew:plan:review", args: `.claude/plans/${slug}.yaml` });

  // Reload to check if still questions
  plan = Read({ file_path: `.claude/plans/${slug}.yaml` });
}
// TodoWrite: #1-6 ✓
```

## Step 8: Present Plan and Ask to Start

```javascript
// Present plan summary to user
console.log(`Plan complete: .claude/plans/${slug}.yaml`);
// Display key sections: stories count, P1/P2/P3 breakdown, etc.

// Ask user if they want to start building
const response = AskUserQuestion({
  questions: [
    {
      question: "Plan is ready. Start building?",
      options: [
        "Yes, start building now",
        "No, I need to review the plan first",
      ],
    },
  ],
});

if (response === "Yes, start building now") {
  Skill({ skill: "crew:work", args: slug });
}
// If "No", command ends - user can run /crew:work later
```

</workflow>

<constraints>

- Single `.yaml` file at `.claude/plans/<slug>.yaml`
- Stories embedded with P1/P2/P3 priorities
- Research → Draft → Review → Finalize
- **NO source code changes during planning** - only plan file created
- Step 8 asks user via AskUserQuestion before starting work

</constraints>

<success_criteria>

**Orchestration:**

- [ ] TodoWrite initialized with 6 tasks (research → draft → review)
- [ ] Icons show dependencies: ○ ready, ● blocked, ✓ complete, ⚠ blocker info
- [ ] All research agents run_in_background: true

**Workflow:**

- [ ] Feature branch created (Step 1)
- [ ] 4 research agents launched parallel (Step 3)
- [ ] Draft plan written with open_questions (Step 5)
- [ ] plan-review called (Step 6)
- [ ] Refine loop runs until no open_questions (Step 7)
- [ ] Plan presented and user asked to start building (Step 8)
- [ ] crew:work invoked only if user says "Yes"

**Output:**

- [ ] Valid YAML at `.claude/plans/<slug>.yaml`
- [ ] Stories with `id`, `priority`, `status`, `mvp`
- [ ] Acceptance as `given`/`when`/`then`
- [ ] open_questions resolved before work starts

</success_criteria>
