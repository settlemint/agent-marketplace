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

1. Load most recent analysis from `.claude/flow/analysis-*.json`
2. Filter and prioritize suggestions by impact and effort
3. Present actionable recommendations with next steps

</quick_start>

<workflow>

## Phase 1: Load Analysis

Find most recent analysis in `.claude/flow/analysis-*.json`. If none exists, suggest `flow:analyze`.

## Phase 2: Filter and Prioritize

**Categories:** all, code, tests, docs, perf

**Priority by:** Impact (high/medium/low) x Effort (high/medium/low). Highlight quick wins.

## Phase 3: Present Suggestions

Group by priority tier: Quick Wins, Medium Priority, Long-term. Show impact, effort, affected files.

## Phase 4: Offer Action Plan

Options: Create workflow from suggestions, focus on quick wins, export to file, dismiss.

</workflow>

<related_skills>

```javascript
Skill({ skill: "flow:guides:optimization" }); // Apply optimizations
Skill({ skill: "flow:workflow:start" }); // Start improvement workflow
```

</related_skills>

<success_criteria>

- [ ] Analysis loaded and suggestions prioritized
- [ ] Clear presentation with actionable next steps

</success_criteria>
