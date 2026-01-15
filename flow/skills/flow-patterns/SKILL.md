---
name: flow-patterns
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

**Step 1: Identify Workflow Type**

Determine which pattern fits your need:

- **Linear**: Sequential tasks, each depending on previous
- **Parallel**: Independent tasks that can run concurrently
- **Iterative**: Repeating cycles until condition met
- **Hybrid**: Combination of above patterns

**Step 2: Apply Template**

Load the appropriate template from `templates/`:

- `workflow-template.md` - General workflow structure
- `checklist-template.md` - Task checklist format

**Step 3: Customize for Context**

Adapt the template to your specific requirements.

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

```
START → Task A → Task B → Task C → END
```

Best for: Sequential processes, approval chains, build pipelines

## Parallel Workflow

```
START → ┬→ Task A ─┬→ END
        ├→ Task B ─┤
        └→ Task C ─┘
```

Best for: Independent research, parallel testing, concurrent processing

## Iterative Workflow

```
START → ┌→ Task A → Task B → Check ─┐
        └────────── (repeat) ───────┘
                        ↓
                       END
```

Best for: Refinement, quality assurance, optimization cycles

## Checkpoint Pattern

```
Task → Checkpoint → Decision → Continue/Rollback
```

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
Skill({ skill: "flow:flow-analysis" }); // Analyze existing workflows
Skill({ skill: "flow:flow-optimization" }); // Optimize workflow efficiency
```

</related_skills>

<success_criteria>

- [ ] Workflow type identified
- [ ] Appropriate template selected
- [ ] Tasks have clear success criteria
- [ ] Dependencies documented
- [ ] Checkpoints included for long workflows

</success_criteria>
