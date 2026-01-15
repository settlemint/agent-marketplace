---
name: flow-analysis
description: Codebase analysis patterns. Use when analyzing project structure, identifying patterns, or evaluating code quality.
triggers:
  - "analyze"
  - "analysis"
  - "evaluate"
  - "assess"
  - "review structure"
  - "code quality"
---

<objective>

Provide systematic approaches for analyzing codebases to identify patterns, potential improvements, and areas of concern.

</objective>

<quick_start>

**Step 1: Choose Analysis Type**

- **Structure Analysis**: Directory layout, file organization
- **Pattern Analysis**: Code patterns, architecture decisions
- **Quality Analysis**: Code smells, technical debt
- **Dependency Analysis**: Module dependencies, coupling

**Step 2: Gather Data**

Use appropriate tools:

- `Glob` for file patterns
- `Grep` for code patterns
- `Read` for file contents

**Step 3: Synthesize Findings**

Compile findings into actionable insights.

</quick_start>

<routing>

| Task              | Resource                          | ~Tokens |
| ----------------- | --------------------------------- | ------- |
| Analysis patterns | `references/analysis-patterns.md` | ~400    |

</routing>

<analysis_types>

## Structure Analysis

Examine project organization:

```
Questions to answer:
- Is the directory structure logical?
- Are files grouped by feature or type?
- Is naming consistent?
- Are there orphaned files?
```

**Metrics:**

- Directory depth
- Files per directory
- Naming pattern adherence

## Pattern Analysis

Identify code patterns:

```
Questions to answer:
- What architectural patterns are used?
- Are patterns applied consistently?
- Are there anti-patterns present?
```

**Look for:**

- Component patterns
- State management patterns
- API patterns
- Error handling patterns

## Quality Analysis

Evaluate code quality:

```
Questions to answer:
- Is there code duplication?
- Are functions appropriately sized?
- Is complexity manageable?
- Are there code smells?
```

**Metrics:**

- Cyclomatic complexity
- Function length
- Duplication percentage
- Test coverage

## Dependency Analysis

Map dependencies:

```
Questions to answer:
- What are the module boundaries?
- Is there circular dependency?
- Is coupling appropriate?
- Are external dependencies up to date?
```

**Outputs:**

- Dependency graph
- Coupling metrics
- Version status

</analysis_types>

<constraints>

- Focus on actionable insights
- Prioritize findings by impact
- Avoid analysis paralysis
- Document assumptions

</constraints>

<related_skills>

```javascript
Skill({ skill: "flow:analyze" }); // Run a full codebase analysis
Skill({ skill: "flow:suggest" }); // Get improvement suggestions
Skill({ skill: "flow:flow-optimization" }); // Apply optimizations
```

</related_skills>

<success_criteria>

- [ ] Analysis type selected
- [ ] Data gathered systematically
- [ ] Findings documented
- [ ] Recommendations actionable
- [ ] Priority assigned to each finding

</success_criteria>
