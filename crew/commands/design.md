---
name: crew:design
description: Create validated implementation plans with research
argument-hint: "[feature description, bug report, or improvement idea]"
---

## Input

<feature_description>$ARGUMENTS</feature_description>

## Native Tools

### AskUserQuestion - Gather Input

```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like to design?",
    header: "Type",
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

### TodoWrite - Track Progress

```javascript
TodoWrite({
  todos: [
    {content: "Validate input", status: "in_progress", activeForm: "Validating input"},
    {content: "Launch research agents", status: "pending", activeForm: "Researching"},
    {content: "Analyze gaps", status: "pending", activeForm: "Analyzing gaps"},
    {content: "Write plan", status: "pending", activeForm: "Writing plan"},
    {content: "Create branch", status: "pending", activeForm: "Creating branch"}
  ]
})
```

### Task - Spawn Research Agents

```javascript
// Launch ALL research agents in SINGLE message for parallelism
Task({
  subagent_type: "repo-research-analyst",
  prompt: `CONTEXT: Designing [feature]
SCOPE: Find existing patterns in codebase
CONSTRAINTS: Focus on similar implementations
OUTPUT: Pattern analysis with file references

Tools: Use Glob/Grep/Read (not bash)`,
  description: "Repo analysis",
  run_in_background: true
})

Task({
  subagent_type: "best-practices-researcher",
  prompt: `CONTEXT: Designing [feature]
SCOPE: Research industry best practices
CONSTRAINTS: Current standards, 2026

MCP: Use Context7 for library docs (not WebFetch)
MCP: Use OctoCode for GitHub examples
OUTPUT: Best practices with citations`,
  description: "Best practices",
  run_in_background: true
})
```

## Process

### Phase 1: Validate Input

If empty or unclear:

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

Launch ALL research agents in a **SINGLE message**:

```javascript
// Research agent 1: Codebase patterns
Task({
  subagent_type: "repo-research-analyst",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Analyze existing patterns in this codebase
CONSTRAINTS: Find similar implementations, conventions used
OUTPUT: Pattern analysis with specific file:line references

Tools:
- Glob for file discovery
- Grep for content search
- Read for file examination
- ast-grep (sg) for structural patterns
NEVER use bash find/grep/cat`,
  description: "Repo research",
  run_in_background: true
})

// Research agent 2: Best practices
Task({
  subagent_type: "best-practices-researcher",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Research current best practices (2026)
CONSTRAINTS: Authoritative sources, industry standards
OUTPUT: Prioritized recommendations with citations

MCP Tools (prefer over WebFetch):
- Context7 for library documentation
- OctoCode for GitHub examples and implementations`,
  description: "Best practices",
  run_in_background: true
})

// Research agent 3: Framework docs
Task({
  subagent_type: "framework-docs-researcher",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Gather relevant framework documentation
CONSTRAINTS: Official docs, current versions
OUTPUT: API patterns and configuration options

MCP Tools:
- Context7: Query library docs directly
  mcp__plugin_crew_context7__query-docs({
    context7CompatibleLibraryID: "/library/id",
    topic: "${feature}"
  })`,
  description: "Framework docs",
  run_in_background: true
})

// Research agent 4: Git history context
Task({
  subagent_type: "git-history-analyzer",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Analyze history of related files
CONSTRAINTS: Find past decisions, refactorings
OUTPUT: Historical context and contributor insights

Tools: Git commands via Bash are appropriate
MCP: OctoCode for PR discussions`,
  description: "History analysis",
  run_in_background: true
})
```

### Phase 3: Collect Research

```javascript
// Collect all research results
const repoResearch = TaskOutput({task_id: "repo-id", block: true})
const bestPractices = TaskOutput({task_id: "bp-id", block: true})
const frameworkDocs = TaskOutput({task_id: "fw-id", block: true})
const historyAnalysis = TaskOutput({task_id: "hist-id", block: true})

// Update progress
TodoWrite({
  todos: [
    {content: "Validate input", status: "completed", activeForm: "Validating input"},
    {content: "Launch research agents", status: "completed", activeForm: "Researching"},
    {content: "Analyze gaps", status: "in_progress", activeForm: "Analyzing gaps"},
    // ...
  ]
})
```

### Phase 4: Gap Analysis

```javascript
Task({
  subagent_type: "spec-flow-analyzer",
  prompt: `CONTEXT: Designing ${feature}
SCOPE: Analyze user flows and identify gaps

Research findings:
- Repo patterns: ${repoResearch}
- Best practices: ${bestPractices}
- Framework docs: ${frameworkDocs}

CONSTRAINTS: Be exhaustive - every edge case matters
OUTPUT: Flow matrix, missing elements, critical questions`,
  description: "Gap analysis",
  run_in_background: false  // Wait for this one
})
```

### Phase 5: Architectural Analysis (Optional)

For complex features:

```javascript
Task({
  subagent_type: "codex-architect",
  prompt: `CONTEXT: Architectural design for ${feature}
SCOPE: Propose implementation approaches

Research:
- Repo patterns: ${repoResearch}
- Best practices: ${bestPractices}
- Gaps: ${gapAnalysis}

CONSTRAINTS: 2-3 approaches with trade-offs
OUTPUT: Approach comparison, phases, risks

MCP: Use Codex for deep reasoning
mcp__plugin_crew_codex__codex({...})`,
  description: "Architecture design",
  run_in_background: false
})
```

### Phase 6: UI Refinement (For Frontend)

```javascript
Task({
  subagent_type: "design-iterator",
  prompt: `CONTEXT: UI design for ${feature}
SCOPE: Refine visual implementation
CONSTRAINTS: Match Figma specs if available
OUTPUT: Component structure and styling approach`,
  description: "UI design",
  run_in_background: false
})
```

### Phase 7: Write Plan

Write to `.claude/plans/<feature-slug>.md`:

```markdown
# Plan: [Feature Name]

## Problem Statement
[What we're solving]

## Research Summary
[Key findings from research agents]

## Technical Approach
[Chosen approach with rationale]

## Acceptance Criteria
- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Implementation Phases
### Phase 1: [Name]
- [ ] [Task 1]
- [ ] [Task 2]

### Phase 2: [Name]
- [ ] [Task 1]

## Risks & Mitigations
| Risk | Mitigation |
|------|------------|
| [Risk] | [Mitigation] |
```

### Phase 8: Branch Setup

```bash
git checkout -b feature/<feature-slug>
git add .claude/plans/<feature-slug>.md
git commit -m "docs(plan): add plan for <feature-slug>"
```

### Phase 9: Next Steps

```javascript
AskUserQuestion({
  questions: [{
    question: "Plan created. What's next?",
    header: "Next Step",
    options: [
      {label: "Start building (Recommended)", description: "Run /crew:build with this plan"},
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

- [ ] AskUserQuestion used for type clarification
- [ ] TodoWrite tracks progress throughout
- [ ] Research agents launched in parallel (single message)
- [ ] MCP tools used for docs (Context7, OctoCode) instead of WebFetch
- [ ] Plan written to `.claude/plans/<feature-slug>.md`
- [ ] Plan contains acceptance criteria
- [ ] Branch created and plan committed
- [ ] AskUserQuestion confirms next steps
