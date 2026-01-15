---
name: flow:analyze
description: Analyze codebase for patterns and improvements. Use when evaluating project structure, code quality, or identifying technical debt.
triggers:
  - "analyze codebase"
  - "analyze project"
  - "code analysis"
  - "audit code"
  - "review structure"
---

<objective>

Analyze the codebase to identify patterns, potential improvements, and optimization opportunities.

**Output:** `.claude/flow/analysis-{timestamp}.json`

</objective>

<quick_start>

1. Determine analysis scope: `quick`, `full`, or `deep`
2. Analyze structure, patterns, and potential improvements
3. Generate report at `.claude/flow/analysis-{timestamp}.json`

</quick_start>

<workflow>

## Phase 1: Determine Scope

Analysis levels:

- `quick` (default): High-level structure analysis
- `full`: Complete codebase analysis
- `deep`: In-depth analysis with pattern detection

## Phase 2: Structure Analysis

Analyze: directory layout, file organization, naming conventions, module boundaries.

## Phase 3: Pattern Detection

Identify: code patterns, testing patterns, configuration patterns, documentation patterns.

## Phase 4: Improvement Detection

Identify: code duplication, missing tests, documentation gaps, performance opportunities.

## Phase 5: Generate Report

Create analysis report at `.claude/flow/analysis-{timestamp}.json`:

```json
{
  "timestamp": "ISO date",
  "scope": "quick|full|deep",
  "structure": { ... },
  "patterns": [ ... ],
  "improvements": [ ... ],
  "recommendations": [ ... ]
}
```

## Phase 6: Present Summary

Display key findings to user with actionable next steps.

</workflow>

<related_skills>

```javascript
Skill({ skill: "flow:suggest" }); // Get improvement suggestions
Skill({ skill: "flow:guides:optimization" }); // Optimization patterns
Skill({ skill: "flow:guides:analysis" }); // Analysis patterns
```

</related_skills>

<success_criteria>

- [ ] Scope determined and analysis completed
- [ ] Report generated at `.claude/flow/analysis-{timestamp}.json`
- [ ] Summary presented with actionable recommendations

</success_criteria>
