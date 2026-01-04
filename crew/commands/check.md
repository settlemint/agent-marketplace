---
name: crew:check
description: Multi-agent code review with automatic triage
argument-hint: "[PR number, GitHub URL, branch name, or latest]"
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/check-context.sh`

## Input

<review_target>$ARGUMENTS</review_target>

## Seven-Leg Review System

This command uses the **Gastown Seven-Leg Code Review** pattern with consistent coverage:

| Leg | Focus | Key Checks |
|-----|-------|------------|
| **Correctness** | Logic accuracy | Edge cases, null handling, type safety |
| **Performance** | Speed/efficiency | Complexity, caching, queries, N+1 |
| **Security** | Vulnerability prevention | OWASP, injection, auth, secrets |
| **Elegance** | Design quality | SOLID, clean architecture, cohesion |
| **Resilience** | Failure handling | Error recovery, cleanup, degradation |
| **Style** | Conventions | Naming, formatting, idioms |
| **Smells** | Debt indicators | Anti-patterns, duplication, complexity |

### Severity Levels

All reviewers output findings with consistent severity:

- **P0**: Critical - Must fix before merge, blocks deployment
- **P1**: High - Should fix, significant impact on quality
- **P2**: Medium - Should address, lower priority
- **Observation**: Note for consideration, not blocking

### Output Format

Each finding follows: `[Severity] file:line - Description`

## Native Tools

### AskUserQuestion - Gather Input (Main Thread Only)

```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like me to check?",
    header: "Target",
    options: [
      {label: "Current branch (Recommended)", description: "Review changes on this branch vs main"},
      {label: "Latest PR", description: "Review the most recent pull request"},
      {label: "Specific PR", description: "I'll tell you which PR number"}
    ],
    multiSelect: false
  }]
})
```

### TodoWrite - Track Progress

```javascript
TodoWrite({
  todos: [
    {content: "Determine review target", status: "in_progress", activeForm: "Determining target"},
    {content: "Gather changed files", status: "pending", activeForm: "Gathering files"},
    {content: "Launch 7-leg review agents", status: "pending", activeForm: "Launching reviewers"},
    {content: "Collect findings", status: "pending", activeForm: "Collecting findings"},
    {content: "Triage by severity (P0/P1/P2)", status: "pending", activeForm: "Triaging findings"},
    {content: "Create todo files", status: "pending", activeForm: "Creating todos"}
  ]
})
```

### Task - Spawn Parallel Agents

**CRITICAL: Launch ALL agents in a SINGLE message for maximum parallelism**

```javascript
Task({
  subagent_type: "typescript-reviewer",
  prompt: `CONTEXT: Code review for PR/branch changes
SCOPE: Review TypeScript files: ${changedFiles}
CONSTRAINTS: Focus on type safety, modern patterns, testability
OUTPUT: Findings with file:line, severity (P1/P2/P3), fix recommendation

Use native tools:
- Glob to find related files
- Grep to search patterns
- Read to examine code
NEVER use bash grep/find/cat`,
  description: "TypeScript review",
  run_in_background: true
})
```

### TaskOutput - Collect Results

```javascript
// Wait for each agent
TaskOutput({task_id: "ts-review-id", block: true})

// Check status without blocking
TaskOutput({task_id: "sec-review-id", block: false})
```

## Process

### Phase 1: Determine Review Target

If target unclear from arguments:

```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like me to check?",
    header: "Target",
    options: [
      {label: "Current branch (Recommended)", description: "Review changes on this branch vs main"},
      {label: "Latest PR", description: "Review the most recent pull request"},
      {label: "Specific PR", description: "I'll tell you which PR number"}
    ],
    multiSelect: false
  }]
})
```

### Phase 2: Gather Context

```javascript
// Get changed files
Bash({command: "git diff main...HEAD --name-only", description: "Get changed files"})

// Get diff for context
Bash({command: "git diff main...HEAD", description: "Get diff"})
```

### Phase 3: Launch Seven-Leg Review Agents

Launch ALL 7 canonical reviewers in a **SINGLE message** for maximum parallelism:

```javascript
// === SEVEN-LEG CANONICAL REVIEWERS ===
// Always launch all 7 for complete coverage

// LEG 1: CORRECTNESS
Task({
  subagent_type: "correctness-reviewer",
  prompt: `CONTEXT: Correctness review for ${branchName}
SCOPE: ${changedFiles.join(', ')}
FOCUS: Logic errors, edge cases, null handling, type safety
OUTPUT: [P0|P1|P2|Observation] file:line format

Tools: Use Glob, Grep, Read (not bash find/grep/cat)`,
  description: "Correctness review",
  run_in_background: true
})

// LEG 2: PERFORMANCE
Task({
  subagent_type: "performance-reviewer",
  prompt: `CONTEXT: Performance review for ${branchName}
SCOPE: ${changedFiles.join(', ')}
FOCUS: Algorithmic complexity, caching, N+1 queries, memory
OUTPUT: [P0|P1|P2|Observation] file:line format

Tools: Use Glob, Grep, Read (not bash find/grep/cat)`,
  description: "Performance review",
  run_in_background: true
})

// LEG 3: SECURITY
Task({
  subagent_type: "security-reviewer",
  prompt: `CONTEXT: Security review for ${branchName}
SCOPE: ${changedFiles.join(', ')}
FOCUS: OWASP Top 10, injection, auth, secrets, access control
OUTPUT: [P0|P1|P2|Observation] file:line format

Tools: Use Glob, Grep, Read (not bash find/grep/cat)`,
  description: "Security review",
  run_in_background: true
})

// LEG 4: ELEGANCE
Task({
  subagent_type: "elegance-reviewer",
  prompt: `CONTEXT: Elegance review for ${branchName}
SCOPE: ${changedFiles.join(', ')}
FOCUS: SOLID principles, clean architecture, design clarity
OUTPUT: [P0|P1|P2|Observation] file:line format

Tools: Use Glob, Grep, Read (not bash find/grep/cat)`,
  description: "Elegance review",
  run_in_background: true
})

// LEG 5: RESILIENCE
Task({
  subagent_type: "resilience-reviewer",
  prompt: `CONTEXT: Resilience review for ${branchName}
SCOPE: ${changedFiles.join(', ')}
FOCUS: Error handling, recovery, cleanup, graceful degradation
OUTPUT: [P0|P1|P2|Observation] file:line format

Tools: Use Glob, Grep, Read (not bash find/grep/cat)`,
  description: "Resilience review",
  run_in_background: true
})

// LEG 6: STYLE
Task({
  subagent_type: "style-reviewer",
  prompt: `CONTEXT: Style review for ${branchName}
SCOPE: ${changedFiles.join(', ')}
FOCUS: Naming conventions, formatting, idioms, documentation
OUTPUT: [P0|P1|P2|Observation] file:line format

Tools: Use Glob, Grep, Read (not bash find/grep/cat)`,
  description: "Style review",
  run_in_background: true
})

// LEG 7: SMELLS
Task({
  subagent_type: "smells-reviewer",
  prompt: `CONTEXT: Code smells review for ${branchName}
SCOPE: ${changedFiles.join(', ')}
FOCUS: Anti-patterns, duplication, complexity, dead code
OUTPUT: [P0|P1|P2|Observation] file:line format

Tools: Use Glob, Grep, Read (not bash find/grep/cat)`,
  description: "Smells review",
  run_in_background: true
})

// === CONDITIONAL DOMAIN AGENTS ===
// Add based on file types detected

// If .sol files present:
Task({
  subagent_type: "solidity-security-auditor",
  prompt: `CONTEXT: Smart contract audit for ${branchName}
SCOPE: ${solFiles.join(', ')}
FOCUS: OWASP SC Top 10, reentrancy, overflow
OUTPUT: [P0|P1|P2|Observation] file:line format`,
  description: "Solidity audit",
  run_in_background: true
})

// If migrations present:
Task({
  subagent_type: "data-migration-expert",
  prompt: `CONTEXT: Migration review for ${branchName}
SCOPE: ${migrationFiles.join(', ')}
FOCUS: Mapping correctness, rollback safety
OUTPUT: [P0|P1|P2|Observation] file:line format`,
  description: "Migration review",
  run_in_background: true
})

// If .claude/ files present:
Task({
  subagent_type: "agent-context-reviewer",
  prompt: `CONTEXT: Agent/skill review for ${branchName}
SCOPE: ${claudeFiles.join(', ')}
FOCUS: Context engineering patterns, prompt-native design
OUTPUT: [P0|P1|P2|Observation] file:line format`,
  description: "Agent review",
  run_in_background: true
})
```

### Phase 4: Collect and Synthesize

```javascript
// Update progress
TodoWrite({
  todos: [
    // ... previous completed
    {content: "Collect findings", status: "in_progress", activeForm: "Collecting findings"},
    // ...
  ]
})

// Collect from all 7 canonical reviewers
const correctnessResults = TaskOutput({task_id: "correctness-id", block: true})
const performanceResults = TaskOutput({task_id: "performance-id", block: true})
const securityResults = TaskOutput({task_id: "security-id", block: true})
const eleganceResults = TaskOutput({task_id: "elegance-id", block: true})
const resilienceResults = TaskOutput({task_id: "resilience-id", block: true})
const styleResults = TaskOutput({task_id: "style-id", block: true})
const smellsResults = TaskOutput({task_id: "smells-id", block: true})

// Collect any conditional domain agents
// ... collect solidity, migration, agent reviewers if launched

// Deduplicate and merge similar findings across legs
// Categorize by severity:
//   P0 (critical, blocks merge)
//   P1 (high, should fix before merge)
//   P2 (medium, address soon)
//   Observation (note for consideration)
```

### Phase 5: Deep Meta-Analysis (Optional)

For critical reviews with many findings, analyze cross-cutting concerns:

```javascript
Task({
  subagent_type: "meta-reviewer",
  prompt: `CONTEXT: Meta-analysis of seven-leg code review findings
SCOPE: Synthesize findings from all 7 legs:
  Correctness: ${correctnessFindings}
  Performance: ${performanceFindings}
  Security: ${securityFindings}
  Elegance: ${eleganceFindings}
  Resilience: ${resilienceFindings}
  Style: ${styleFindings}
  Smells: ${smellsFindings}

CONSTRAINTS: Find emergent risks, priority adjustments, cross-cutting concerns
OUTPUT:
- Cross-leg patterns (same issue appearing in multiple dimensions)
- Priority escalations (P2→P1 when combined risks compound)
- Priority demotions (duplicate findings across legs)
- Systemic issues not visible to individual reviewers

MCP: Use Codex for deep reasoning about systemic issues`,
  description: "Meta-analysis",
  run_in_background: false  // Wait for this one
})
```

### Phase 6: Confirm Next Steps

```javascript
AskUserQuestion({
  questions: [{
    question: `Found ${p0Count} P0, ${p1Count} P1, ${p2Count} P2, ${obsCount} observations. How to proceed?`,
    header: "Action",
    options: [
      {label: "Create todo files (Recommended)", description: "Write findings to .claude/branches/<branch>/tasks/"},
      {label: "Fix P0 issues now", description: "Immediately address critical blockers"},
      {label: "Show full report", description: "Display all findings grouped by leg"},
      {label: "Skip todo creation", description: "Just show summary"}
    ],
    multiSelect: false
  }]
})
```

### Phase 7: Create Task Files for Findings

Add findings as new task files in `.claude/branches/<branch>/tasks/`:

```javascript
// Get current branch
const branch = Bash({command: "git branch --show-current"})

// Find next order number (start from 050 for findings)
const existing = Glob({pattern: `.claude/branches/${branch}/tasks/*.md`})
const nextOrder = getNextOrderNumber(existing, 50) // Start findings at 050

// For each finding, create a task file
for (const finding of findings) {
  Write({
    file_path: `.claude/branches/${branch}/tasks/${nextOrder}-pending-${finding.severity}-found-${finding.slug}.md`,
    content: `---
status: pending
priority: ${finding.severity}
leg: ${finding.leg}
story: found
parallel: true
file_path: ${finding.file}
depends_on: []
---

# T${nextOrder}: ${finding.title}

## Description

${finding.description}

## Location

- File: \`${finding.file}\`
- Line: ${finding.line}

## Review Dimension

- **Leg:** ${finding.leg}
- **Severity:** ${finding.severity}

## Acceptance Criteria

- [ ] Issue resolved
- [ ] Tests pass
- [ ] No regressions

## Recommended Fix

${finding.fix}

## Agent

Found by: ${finding.leg}-reviewer

## Work Log

### ${date} - Created
**By:** /crew:check (Seven-Leg Review)
**Severity:** ${finding.severity}
`
  })
  nextOrder++
}
```

**File naming for findings:**

```text
050-pending-p0-found-fix-null-deref-auth.md
051-pending-p1-found-add-rate-limiting.md
052-pending-p2-found-simplify-conditional.md
053-pending-obs-found-consider-memoization.md
```

## Success Criteria

- [ ] AskUserQuestion used for target clarification
- [ ] TodoWrite tracks progress throughout
- [ ] All 7 canonical reviewers launched in parallel (single message)
- [ ] Conditional domain agents launched for relevant file types
- [ ] Findings deduplicated and prioritized (P0/P1/P2/Observation)
- [ ] Cross-leg patterns identified via meta-analysis (if needed)
- [ ] AskUserQuestion confirms next steps
- [ ] Task files created for findings in `.claude/branches/<branch>/tasks/`
- [ ] Task files follow naming: `{order}-pending-{severity}-found-{slug}.md`
- [ ] Each finding includes leg dimension and severity
- [ ] Each finding task has acceptance criteria

## Seven-Leg Coverage Verification

Ensure all 7 dimensions are covered:

| Leg | Reviewer | Required |
|-----|----------|----------|
| Correctness | correctness-reviewer | ✓ Always |
| Performance | performance-reviewer | ✓ Always |
| Security | security-reviewer | ✓ Always |
| Elegance | elegance-reviewer | ✓ Always |
| Resilience | resilience-reviewer | ✓ Always |
| Style | style-reviewer | ✓ Always |
| Smells | smells-reviewer | ✓ Always |
