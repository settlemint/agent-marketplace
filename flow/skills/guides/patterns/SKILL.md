---
name: flow:guides:patterns
description: Core workflow patterns and templates. Use when designing workflows, creating structured processes, or implementing productivity patterns.
triggers:
  - "workflow"
  - "process"
  - "pattern"
  - "template"
  - "flow"
  - "productivity"
---

<objective>

Provide core workflow patterns and templates for structured, repeatable processes. This skill helps design and implement effective workflows for various development tasks.

</objective>

<quick_start>

1. Identify workflow type: Linear, Parallel, Iterative, or Hybrid
2. Apply appropriate template from `templates/`
3. Customize for your specific context

</quick_start>

<routing>

| Task                  | Resource                           | ~Tokens |
| --------------------- | ---------------------------------- | ------- |
| Design new workflow   | `templates/workflow-template.md`   | ~200    |
| Create task checklist | `templates/checklist-template.md`  | ~150    |
| Understand patterns   | `references/core-concepts.md`      | ~300    |
| Best practices        | `references/best-practices.md`     | ~250    |
| Standard workflow     | `workflows/standard-workflow.md`   | ~200    |
| Quick workflow        | `workflows/fast-track-workflow.md` | ~150    |

</routing>

<patterns>

## Linear Workflow

`START → Task A → Task B → Task C → END`

Best for: Sequential processes, approval chains, build pipelines

## Parallel Workflow

Tasks A, B, C run concurrently, all must complete before END.

Best for: Independent research, parallel testing, concurrent processing

## Iterative Workflow

Repeat tasks until check passes.

Best for: Refinement, quality assurance, optimization cycles

## Checkpoint Pattern

`Task → Checkpoint → Decision → Continue/Rollback`

Best for: Risky operations, staged deployments, review gates

</patterns>

<constraints>

- Keep workflows focused (max 10 tasks per workflow)
- Every task must have clear success criteria
- Include checkpoints for long workflows
- Document dependencies explicitly

</constraints>

<related_skills>

```javascript
Skill({ skill: "flow:workflow:start" }); // Start a workflow using these patterns
Skill({ skill: "flow:guides:analysis" }); // Analyze existing workflows
Skill({ skill: "flow:guides:optimization" }); // Optimize workflow efficiency
```

</related_skills>

<success_criteria>

- [ ] Workflow type identified and template applied
- [ ] Tasks have clear success criteria and dependencies

</success_criteria>
