---
name: crew:design
description: Create validated implementation plans with research
argument-hint: "[feature description, bug report, or improvement idea]"
---

## Input

<feature_description>$ARGUMENTS</feature_description>

## Process

### Phase 1: Validate Input

If empty, ask:

```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like to design?",
    header: "Feature",
    options: [
      {label: "New feature", description: "Add new functionality"},
      {label: "Bug fix", description: "Fix an existing issue"},
      {label: "Refactoring", description: "Improve code structure"},
      {label: "Infrastructure", description: "DevOps or tooling"}
    ],
    multiSelect: false
  }]
})
```

### Phase 2: Parallel Research

Launch research agents in parallel:

```javascript
Task({ subagent_type: "repo-research-analyst", prompt: "Analyze patterns for: [feature]", run_in_background: true });
Task({ subagent_type: "best-practices-researcher", prompt: "Research best practices for: [feature]", run_in_background: true });
Task({ subagent_type: "framework-docs-researcher", prompt: "Gather docs for: [feature]", run_in_background: true });
```

### Phase 3: Gap Analysis

```javascript
Task({ subagent_type: "spec-flow-analyzer", prompt: "Analyze user flows and gaps: [findings]" });
```

### Phase 4: Write Plan

Write to `.claude/plans/<feature-slug>.md` with:
- Problem statement
- Research findings
- Technical approach
- Acceptance criteria
- Implementation phases

### Phase 5: Branch Setup

```bash
git checkout -b feature/<feature-slug>
git add .claude/plans/<feature-slug>.md
git commit -m "docs(plan): add plan for <feature-slug>"
```

### Phase 6: Next Steps

```javascript
AskUserQuestion({
  questions: [{
    question: "Plan created. What's next?",
    header: "Next Step",
    options: [
      {label: "Start building", description: "Run /crew:build with this plan"},
      {label: "Create GitHub issue", description: "Push plan for team review"},
      {label: "Review the plan", description: "Walk through key sections"},
      {label: "Done for now", description: "Save and exit"}
    ],
    multiSelect: false
  }]
})
```

## Constraints

**NEVER CODE!** This command researches and writes plans only.

## Success Criteria

- [ ] Plan written to `.claude/plans/<feature-slug>.md`
- [ ] Contains acceptance criteria
- [ ] Branch created and plan committed
