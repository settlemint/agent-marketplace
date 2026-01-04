---
name: crew:design
description: Create validated implementation plans with research and gap analysis
argument-hint: "[feature description, bug report, or improvement idea]"
aliases:
  - design
---

<objective>

Create a comprehensive, validated project plan for a feature or improvement.

</objective>

<input>

<feature_description>$ARGUMENTS</feature_description>

</input>

<process>

**IMPORTANT:** Execute directly in main thread for native UI access.

## Phase 1: Validate Input

If `<feature_description>` is empty, use AskUserQuestion:

```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like to design?",
    header: "Feature",
    options: [
      {label: "New feature", description: "Add new functionality to the platform"},
      {label: "Bug fix", description: "Fix an existing issue"},
      {label: "Refactoring", description: "Improve code structure without changing behavior"},
      {label: "Infrastructure", description: "DevOps, deployment, or tooling improvements"}
    ],
    multiSelect: false
  }]
})
```

## Phase 2: Create Progress Tracking

```javascript
TodoWrite([
  {content: "Research codebase patterns", status: "in_progress", activeForm: "Researching patterns"},
  {content: "Gather best practices", status: "pending", activeForm: "Gathering practices"},
  {content: "Analyze for gaps", status: "pending", activeForm: "Analyzing gaps"},
  {content: "Write plan document", status: "pending", activeForm: "Writing plan"},
  {content: "Validate plan with Codex", status: "pending", activeForm: "Validating plan"},
  {content: "Run clarification loop", status: "pending", activeForm: "Clarifying requirements"},
  {content: "Choose next steps", status: "pending", activeForm: "Choosing next steps"}
])
```

## Phase 3: Parallel Research

Launch research agents in parallel:

```javascript
// Launch ALL in a single message for parallel execution
Task({
  subagent_type: "repo-research-analyst",
  prompt: "Analyze repository patterns for: [feature]. Find existing conventions, similar implementations, relevant files.",
  run_in_background: true,
});

Task({
  subagent_type: "best-practices-researcher",
  prompt: "Research industry best practices for: [feature type]. Include security, scalability, and maintainability.",
  run_in_background: true,
});

Task({
  subagent_type: "framework-docs-researcher",
  prompt: "Gather relevant framework documentation for: [feature]. Focus on TanStack, React 19, Solidity patterns as applicable.",
  run_in_background: true,
});
```

Collect results with `TaskOutput` for each agent.

## Phase 4: Gap Analysis

```javascript
Task({
  subagent_type: "spec-flow-analyzer",
  prompt: "Analyze this feature for user flows and gaps: [synthesized research findings]",
});
```

## Phase 5: Codex Architectural Analysis

```javascript
Skill({ skill: "codex" });

mcp__codex__codex({
  prompt: `You are a senior software architect designing a feature for a blockchain asset tokenization platform.

Feature requirements: [REQUIREMENTS]
Research findings: [RESEARCH]
SpecFlow gaps: [GAPS]

Stack: TypeScript, React 19, TanStack Start, Solidity, PostgreSQL, Kubernetes

Provide:
1. 2-3 implementation approaches with trade-offs
2. Integration points with existing systems
3. Hidden dependencies
4. Implementation phases
5. Risk assessment

Output the recommended approach.`,
  sandbox: "read-only",
});
```

## Phase 6: Write Plan

Write plan to `.claude/plans/<feature-slug>.md` with:
- Problem statement and motivation
- Research findings (summarized)
- Technical approach
- Acceptance criteria with completion promise
- Implementation phases

### 6.1: Set Up Branch

```bash
git checkout -b feature/<feature-slug>
git add .claude/plans/<feature-slug>.md
git commit -m "docs(plan): add plan for <feature-slug>"
```

### 6.2: Add Loop Completion Section

Every plan must include:

```markdown
## Loop Completion

### Completion Promise
When ALL of the following are true, output:
\`\`\`
<promise>FEATURE COMPLETE</promise>
\`\`\`

### Verification Checklist
1. All acceptance criteria met
2. Tests pass: `bun run ci` exits with 0
3. No lint errors
```

## Phase 7: Validation

Use Codex to validate plan completeness, then run clarification loop with user.

## Phase 8: Next Steps

```javascript
AskUserQuestion({
  questions: [{
    question: "Plan created. What's next?",
    header: "Next Step",
    options: [
      {label: "Start building", description: "Run /build with this plan"},
      {label: "Create GitHub issue", description: "Push plan to GitHub for team review"},
      {label: "Review the plan", description: "Walk through key sections"},
      {label: "Done for now", description: "Save and exit"}
    ],
    multiSelect: false
  }]
})
```

</process>

<success_criteria>

- [ ] Plan written to `.claude/plans/<feature-slug>.md`
- [ ] Contains acceptance criteria with completion promise
- [ ] Validated by Codex
- [ ] User confirmed understanding
- [ ] Branch created and plan committed

</success_criteria>

<constraints>

**NEVER CODE!** This command researches and writes plans only.

</constraints>
