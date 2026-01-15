---
name: flow:guides:optimization
description: Optimization strategies and patterns. Use when improving performance, refactoring code, or reducing technical debt.
triggers:
  - "optimize"
  - "optimization"
  - "improve"
  - "refactor"
  - "performance"
  - "technical debt"
---

<objective>

Provide systematic approaches for optimizing code, improving performance, and reducing technical debt while maintaining stability.

</objective>

<quick_start>

1. Identify target: Performance, Quality, or Technical Debt
2. Measure baseline metrics
3. Apply optimization using workflow from `workflows/`
4. Verify improvement against baseline

</quick_start>

<routing>

| Task                  | Resource                             | ~Tokens |
| --------------------- | ------------------------------------ | ------- |
| Optimization workflow | `workflows/optimization-workflow.md` | ~300    |

</routing>

<optimization_types>

## Performance Optimization

Targets: speed, memory, bundle size, load time. Wins: lazy loading, memoization, code splitting, caching.

## Code Quality Optimization

Targets: readability, maintainability, testability, reusability. Refactors: extract function, rename, split files, remove duplication.

## Technical Debt Reduction

Targets: outdated deps, legacy patterns, missing tests, doc gaps. Common debt: TODO/FIXME, deprecated APIs, inconsistent patterns.

</optimization_types>

<principles>

1. **Measure First**: No metrics = no optimization
2. **Focus on Bottlenecks**: 80/20 rule - 80% of problems from 20% of code
3. **Preserve Behavior**: Tests are your safety net
4. **Small Steps**: Large refactors are risky
5. **Document Decisions**: Future you will want to know why

</principles>

<constraints>

- Always have tests before refactoring
- Measure before and after
- Make incremental changes
- Don't optimize prematurely
- Maintain backwards compatibility when possible

</constraints>

<related_skills>

```javascript
Skill({ skill: "flow:analyze" }); // Analyze before optimizing
Skill({ skill: "flow:suggest" }); // Get improvement suggestions
Skill({ skill: "flow:workflow:start" }); // Start an optimization workflow
Skill({ skill: "flow:guides:analysis" }); // Analysis patterns
```

</related_skills>

<success_criteria>

- [ ] Baseline measured and optimization applied
- [ ] Improvement verified against baseline

</success_criteria>
