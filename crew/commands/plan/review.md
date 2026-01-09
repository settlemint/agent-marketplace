---
name: crew:plan:review
description: Review a plan with parallel reviewers + Codex, add open_questions
argument-hint: "<plan-path>"
hidden: true
allowed-tools:
  - Read
  - Write
  - Task
  - MCPSearch
  - TodoWrite
skills:
  - crew:crew-patterns
  - orchestration
---

<objective>

Review a plan with parallel reviewers + Codex. Collect findings, add new open_questions, update plan. Return to caller.

</objective>

<workflow>

## Step 1: Initialize

```javascript
const planPath = args; // e.g., .claude/plans/feature-x.yaml
const plan = Read({ file_path: planPath });

TodoWrite([
  {
    content: "#1 ○ Architecture review",
    status: "pending",
    activeForm: "Reviewing architecture",
  },
  {
    content: "#2 ○ Completeness review",
    status: "pending",
    activeForm: "Checking completeness",
  },
  {
    content: "#3 ○ Simplicity review",
    status: "pending",
    activeForm: "Checking simplicity",
  },
  {
    content: "#4 ○ Codex analysis",
    status: "pending",
    activeForm: "Deep reasoning",
  },
  {
    content: "#5 ● Update plan ⚠ blocked by #1-4",
    status: "pending",
    activeForm: "Updating plan",
  },
]);
```

## Step 2: Spawn Reviewers (parallel)

```javascript
// 3 reviewer agents + Codex MCP - each returns findings + new open_questions
Task({
  subagent_type: "crew:design:architecture-analyst",
  prompt: `Review plan for: boundaries, data flow, dependencies, trade-offs. Return: { findings: [...], open_questions: [...] }\n\n${plan}`,
  description: "arch-review",
  run_in_background: true,
});

Task({
  subagent_type: "crew:workflow:spec-flow-analyzer",
  prompt: `Review plan for: user flows, edge cases, acceptance criteria, gaps. Return: { findings: [...], open_questions: [...] }\n\n${plan}`,
  description: "completeness-review",
  run_in_background: true,
});

Task({
  subagent_type: "crew:review:smells-reviewer",
  prompt: `Review plan for: over-engineering, complexity, YAGNI violations, unnecessary abstractions. Return: { findings: [...], open_questions: [...] }\n\n${plan}`,
  description: "simplicity-review",
  run_in_background: true,
});

MCPSearch({ query: "select:mcp__plugin_crew_codex__codex" });
mcp__plugin_crew_codex__codex({
  question: `Review this plan. What's missing? What could go wrong? What questions must be answered before implementation?\n\n${plan}`,
});
// TodoWrite: #1-4 in_progress
```

## Step 3: Collect & Merge Findings

```javascript
const results = [
  TaskOutput({ task_id: archReviewId, block: true }),
  TaskOutput({ task_id: completenessReviewId, block: true }),
  TaskOutput({ task_id: simplicityReviewId, block: true }),
];

// Merge new open_questions into plan (deduplicate)
const newQuestions = results.flatMap((r) => r.open_questions || []);
plan.open_questions = [...(plan.open_questions || []), ...newQuestions];

// Count high-severity findings
const highSeverity = results
  .flatMap((r) => r.findings || [])
  .filter((f) => f.severity === "high");

// TodoWrite: #1-4 ✓, #5 in_progress
Write({ file_path: planPath, content: updatedPlan });
// TodoWrite: #1-5 ✓
```

## Step 4: Report

```javascript
// Log summary for caller
if (highSeverity.length > 0) {
  console.log(`Review found ${highSeverity.length} high-severity issues.`);
}
console.log(`Plan has ${plan.open_questions?.length || 0} open questions.`);
// Returns to caller (plan or plan-refine)
```

</workflow>

<success_criteria>

- [ ] 3 reviewer agents + Codex launched parallel
- [ ] Findings collected from all reviewers
- [ ] New open_questions merged into plan
- [ ] Plan file updated with merged questions
- [ ] Summary logged, returns to caller

</success_criteria>
