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

```javascript
// Load this skill
Skill({ skill: "flow:analyze" });

// For detailed analysis patterns
Skill({ skill: "flow:flow-analysis" });
```

</quick_start>

<orchestration_role>

**You are the ORCHESTRATOR.** For deep analysis:

- Spawn Explore agents to scan different parts of the codebase
- Collect findings and synthesize into a cohesive report
- Use TodoWrite to track analysis progress

</orchestration_role>

<workflow>

## Phase 1: Determine Scope

Analysis levels:

- `quick` (default): High-level structure analysis
- `full`: Complete codebase analysis
- `deep`: In-depth analysis with pattern detection

## Phase 2: Structure Analysis

Analyze project structure:

- Directory layout
- File organization
- Naming conventions
- Module boundaries

## Phase 3: Pattern Detection

Identify patterns:

- Code patterns (components, utilities, etc.)
- Testing patterns
- Configuration patterns
- Documentation patterns

## Phase 4: Improvement Detection

Identify potential improvements:

- Code duplication
- Missing tests
- Documentation gaps
- Performance opportunities

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

Display summary to user with key findings. Suggest next steps:

```javascript
Skill({ skill: "flow:suggest" }); // Get improvement suggestions
Skill({ skill: "flow:flow-optimization" }); // Apply optimizations
```

</workflow>

<success_criteria>

- [ ] Scope determined
- [ ] Structure analyzed
- [ ] Patterns detected
- [ ] Improvements identified
- [ ] Report generated
- [ ] Summary presented with Skill() recommendations

</success_criteria>
