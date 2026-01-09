---
name: crew:plan
description: Create implementation plans using native Plan mode with multi-agent orchestration
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
  - EnterPlanMode
  - ExitPlanMode
  - AskUserQuestion
  - TodoWrite
  - Skill
skills:
  - crew:crew-patterns
  - orchestration
---

<objective>

Create feature branch. Enter Plan mode. Research with parallel agents. Write draft plan with `open_questions`. Review → Refine loop until no questions remain. Output: `.claude/plans/<slug>.yaml`

</objective>

<workflow>

## Step 0: Create Feature Branch

```javascript
const slug = slugify(feature); // kebab-case, max 30 chars
Skill({ skill: "crew:git:branch-new", args: `${slug} --type feat` });
```

## Step 1: Enter Plan Mode

```javascript
EnterPlanMode();
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

## Step 3: Spawn Research Agents (parallel)

```javascript
// All 4 research agents in parallel - each must return open_questions
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

## Step 6: Exit Plan Mode

```javascript
ExitPlanMode();
// TodoWrite: #1-6 ✓
```

## Step 7: Review Plan

```javascript
// Reviews plan, adds open_questions, updates file
Skill({ skill: "crew:plan-review", args: `.claude/plans/${slug}.yaml` });

// Reload plan to check for open_questions
const plan = Read({ file_path: `.claude/plans/${slug}.yaml` });
// TodoWrite: #1-6 ✓
```

## Step 8: Refine Loop (if needed)

```javascript
// If open questions exist, refine is required (not optional)
while (plan.open_questions?.length > 0) {
  // Resolve current questions
  Skill({ skill: "crew:plan-refine", args: `.claude/plans/${slug}.yaml` });

  // Review may find new questions
  Skill({ skill: "crew:plan-review", args: `.claude/plans/${slug}.yaml` });

  // Reload to check if still questions
  plan = Read({ file_path: `.claude/plans/${slug}.yaml` });
}
```

## Step 9: Ask Next Action

```javascript
// No open questions - ready to build
AskUserQuestion({
  questions: [
    {
      question: "Plan complete. What's next?",
      header: "Next",
      options: [
        { label: "Build (Recommended)", description: "Start implementation" },
        { label: "Stop", description: "Save plan for later" },
      ],
      multiSelect: false,
    },
  ],
});

if (choice === "Build") {
  Skill({ skill: "crew:build", args: slug });
}
```

</workflow>

<constraints>

- Single `.yaml` file at `.claude/plans/<slug>.yaml`
- Stories embedded with P1/P2/P3 priorities
- Research → Draft → Review → Finalize

</constraints>

<success_criteria>

**Orchestration:**

- [ ] TodoWrite initialized with 6 tasks (research → draft → review)
- [ ] Icons show dependencies: ○ ready, ● blocked, ✓ complete, ⚠ blocker info
- [ ] All research agents run_in_background: true

**Workflow:**

- [ ] Feature branch created (Step 0)
- [ ] EnterPlanMode at start (Step 1)
- [ ] 4 research agents launched parallel (Step 3)
- [ ] Draft plan written with open_questions (Step 5)
- [ ] ExitPlanMode before review (Step 6)
- [ ] plan-review called (Step 7)
- [ ] Refine loop runs until no open_questions (Step 8)
- [ ] Build/Stop choice offered (Step 9)

**Output:**

- [ ] Valid YAML at `.claude/plans/<slug>.yaml`
- [ ] Stories with `id`, `priority`, `status`, `mvp`
- [ ] Acceptance as `given`/`when`/`then`
- [ ] open_questions resolved before build

</success_criteria>
