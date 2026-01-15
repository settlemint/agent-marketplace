---
name: flow:suggest
description: Suggest improvements based on analysis. Use when looking for actionable recommendations to improve code quality.
triggers:
  - "suggest improvements"
  - "get suggestions"
  - "improvement recommendations"
  - "what to improve"
---

<objective>

Based on previous analysis, suggest specific improvements for the codebase.

</objective>

<quick_start>

```javascript
// Load this skill
Skill({ skill: "flow:suggest" });

// Requires prior analysis - if none exists:
Skill({ skill: "flow:analyze" });
```

</quick_start>

<workflow>

## Phase 1: Load Analysis

1. Find most recent analysis in `.claude/flow/analysis-*.json`
2. If no analysis exists, suggest:
   ```javascript
   Skill({ skill: "flow:analyze" });
   ```

## Phase 2: Filter by Category

Categories:

- `all` (default): All suggestions
- `code`: Code quality improvements
- `tests`: Testing improvements
- `docs`: Documentation improvements
- `perf`: Performance optimizations

## Phase 3: Prioritize Suggestions

Rank suggestions by:

1. Impact (high/medium/low)
2. Effort (high/medium/low)
3. Quick wins (high impact, low effort)

## Phase 4: Present Suggestions

Display categorized suggestions:

```
Improvement Suggestions
=======================

Quick Wins (High Impact, Low Effort):
1. [Suggestion] - {description}
   Impact: High | Effort: Low
   Files: {affected files}

Medium Priority:
2. [Suggestion] - {description}
   ...

Long-term Improvements:
3. [Suggestion] - {description}
   ...
```

## Phase 5: Create Action Plan

Offer to create a workflow from selected suggestions:

```
Would you like to:
1. Create a workflow from these suggestions
   → Skill({ skill: "flow:workflow:start" })
2. Focus on quick wins only
3. Export suggestions to a file
4. Dismiss
```

</workflow>

<related_skills>

```javascript
Skill({ skill: "flow:guides:optimization" }); // Apply optimizations
Skill({ skill: "flow:workflow:start" }); // Start improvement workflow
```

</related_skills>

<success_criteria>

- [ ] Analysis loaded
- [ ] Suggestions filtered by category
- [ ] Suggestions prioritized
- [ ] Clear presentation provided
- [ ] Action options offered with Skill() format

</success_criteria>
