---
name: flow:guides:analysis
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

1. Choose analysis type: Structure, Pattern, Quality, or Dependency
2. Gather data using Glob, Grep, and Read tools
3. Synthesize findings into actionable insights

</quick_start>

<routing>

| Task              | Resource                          | ~Tokens |
| ----------------- | --------------------------------- | ------- |
| Analysis patterns | `references/analysis-patterns.md` | ~400    |

</routing>

<analysis_types>

## Structure Analysis

Directory layout, file organization, naming consistency. Metrics: directory depth, files per directory, naming adherence.

## Pattern Analysis

Architectural patterns, consistency, anti-patterns. Look for: component, state management, API, error handling patterns.

## Quality Analysis

Code duplication, function size, complexity, smells. Metrics: cyclomatic complexity, function length, duplication, test coverage.

## Dependency Analysis

Module boundaries, circular dependencies, coupling, external dependency status. Outputs: dependency graph, coupling metrics, version status.

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
Skill({ skill: "flow:guides:optimization" }); // Apply optimizations
```

</related_skills>

<success_criteria>

- [ ] Analysis completed with prioritized findings
- [ ] Actionable recommendations documented

</success_criteria>
