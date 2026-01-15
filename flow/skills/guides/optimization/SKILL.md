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

**Step 1: Identify Optimization Target**

- **Performance**: Speed, memory, bundle size
- **Quality**: Readability, maintainability
- **Debt**: Accumulated shortcuts, outdated patterns

**Step 2: Measure Current State**

Establish baseline metrics before changes.

**Step 3: Apply Optimization**

Use appropriate workflow from `workflows/`.

**Step 4: Verify Improvement**

Measure again and compare to baseline.

</quick_start>

<routing>

| Task                  | Resource                             | ~Tokens |
| --------------------- | ------------------------------------ | ------- |
| Optimization workflow | `workflows/optimization-workflow.md` | ~300    |

</routing>

<optimization_types>

## Performance Optimization

**Targets:**

- Execution speed
- Memory usage
- Bundle size
- Load time

**Approach:**

1. Profile to identify bottlenecks
2. Focus on biggest impact areas
3. Make targeted changes
4. Measure improvement

**Common wins:**

- Lazy loading
- Memoization
- Code splitting
- Caching

## Code Quality Optimization

**Targets:**

- Readability
- Maintainability
- Testability
- Reusability

**Approach:**

1. Identify code smells
2. Prioritize by impact
3. Refactor incrementally
4. Ensure tests pass

**Common refactors:**

- Extract function
- Rename for clarity
- Split large files
- Remove duplication

## Technical Debt Reduction

**Targets:**

- Outdated dependencies
- Legacy patterns
- Missing tests
- Documentation gaps

**Approach:**

1. Inventory debt items
2. Assess risk and effort
3. Prioritize strategically
4. Tackle incrementally

**Common debt:**

- TODO/FIXME comments
- Deprecated API usage
- Inconsistent patterns
- Missing error handling

</optimization_types>

<principles>

## The Optimization Mindset

### 1. Measure First

Never optimize without metrics. "It feels slow" is not a measurement.

### 2. Focus on Bottlenecks

The 80/20 rule applies: 80% of problems come from 20% of code.

### 3. Preserve Behavior

Refactoring should not change functionality. Tests are your safety net.

### 4. Small Steps

Make small, verifiable changes. Large refactors are risky.

### 5. Document Decisions

Future you (or someone else) will want to know why.

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

- [ ] Target identified and scoped
- [ ] Baseline measured
- [ ] Changes made incrementally
- [ ] Tests passing throughout
- [ ] Improvement verified
- [ ] Documentation updated

</success_criteria>
