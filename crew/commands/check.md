---
name: crew:check
description: Multi-agent code review with automatic triage
argument-hint: "[PR number, GitHub URL, branch name, or latest]"
---

!`${CLAUDE_PLUGIN_ROOT}/scripts/workflow/check-context.sh`

## Input

<review_target>$ARGUMENTS</review_target>

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
    {content: "Launch review agents", status: "pending", activeForm: "Launching reviewers"},
    {content: "Collect findings", status: "pending", activeForm: "Collecting findings"},
    {content: "Triage and prioritize", status: "pending", activeForm: "Triaging findings"},
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

### Phase 3: Launch Parallel Review Agents

Based on recommended reviewers, launch ALL in a **SINGLE message**:

```javascript
// CORE AGENTS - Always include
Task({
  subagent_type: "typescript-reviewer",
  prompt: `CONTEXT: Code review for ${branchName}
SCOPE: Review: ${tsFiles.join(', ')}
CONSTRAINTS: Type safety, patterns, testability
OUTPUT: P1/P2/P3 findings with file:line

Tools: Use Glob, Grep, Read (not bash find/grep/cat)`,
  description: "TypeScript review",
  run_in_background: true
})

Task({
  subagent_type: "security-sentinel",
  prompt: `CONTEXT: Security audit for ${branchName}
SCOPE: Audit: ${changedFiles.join(', ')}
CONSTRAINTS: OWASP Top 10, injection, auth, secrets
OUTPUT: Vulnerabilities with severity and remediation

MCP Tools: Use Codex for deep threat analysis if complex`,
  description: "Security audit",
  run_in_background: true
})

Task({
  subagent_type: "code-simplicity-reviewer",
  prompt: `CONTEXT: Simplicity review for ${branchName}
SCOPE: Check: ${changedFiles.join(', ')}
CONSTRAINTS: Flag complexity, YAGNI violations, over-engineering
OUTPUT: Simplification opportunities with rationale`,
  description: "Simplicity review",
  run_in_background: true
})

Task({
  subagent_type: "architecture-strategist",
  prompt: `CONTEXT: Architecture review for ${branchName}
SCOPE: Review: ${changedFiles.join(', ')}
CONSTRAINTS: Patterns, layer boundaries, SOLID principles
OUTPUT: Architectural concerns with recommendations

MCP Tools: Use Codex for complex architectural analysis`,
  description: "Architecture review",
  run_in_background: true
})

Task({
  subagent_type: "performance-oracle",
  prompt: `CONTEXT: Performance review for ${branchName}
SCOPE: Analyze: ${changedFiles.join(', ')}
CONSTRAINTS: Algorithmic complexity, queries, caching
OUTPUT: Performance issues with optimization suggestions`,
  description: "Performance review",
  run_in_background: true
})

// CONDITIONAL AGENTS - Based on file types

// If .sol files present:
Task({
  subagent_type: "solidity-security-auditor",
  prompt: `CONTEXT: Smart contract audit for ${branchName}
SCOPE: Audit: ${solFiles.join(', ')}
CONSTRAINTS: OWASP SC Top 10, reentrancy, overflow
OUTPUT: Security findings with severity`,
  description: "Solidity audit",
  run_in_background: true
})

// If migrations present:
Task({
  subagent_type: "data-migration-expert",
  prompt: `CONTEXT: Migration review for ${branchName}
SCOPE: Validate: ${migrationFiles.join(', ')}
CONSTRAINTS: Mapping correctness, rollback safety, dual-write
OUTPUT: Migration risks with verification SQL`,
  description: "Migration review",
  run_in_background: true
})

// If .claude/ files present:
Task({
  subagent_type: "agent-context-reviewer",
  prompt: `CONTEXT: Agent/skill review for ${branchName}
SCOPE: Check: ${claudeFiles.join(', ')}
CONSTRAINTS: Context engineering patterns, prompt-native design
OUTPUT: Pattern violations with fixes`,
  description: "Agent review",
  run_in_background: true
})

// For strict TypeScript review:
Task({
  subagent_type: "kieran-typescript-reviewer",
  prompt: `CONTEXT: Strict TS review for ${branchName}
SCOPE: Review: ${tsFiles.join(', ')}
CONSTRAINTS: Kieran's quality bar - no any, 5-sec naming, testable
OUTPUT: Quality issues that block merge`,
  description: "Strict TS review",
  run_in_background: true
})

// Pattern analysis:
Task({
  subagent_type: "pattern-recognition-specialist",
  prompt: `CONTEXT: Pattern analysis for ${branchName}
SCOPE: Analyze: ${changedFiles.join(', ')}
CONSTRAINTS: Design patterns, anti-patterns, duplication

Skills: Use ast-grep skill for structural code matching
OUTPUT: Pattern issues with refactoring suggestions`,
  description: "Pattern analysis",
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

// Collect from each agent
const tsResults = TaskOutput({task_id: "ts-id", block: true})
const secResults = TaskOutput({task_id: "sec-id", block: true})
// ... collect all

// Deduplicate and merge similar findings
// Categorize: P1 (blocks merge), P2 (should fix), P3 (nice-to-have)
```

### Phase 5: Deep Meta-Analysis (Optional)

For critical reviews, analyze cross-cutting concerns:

```javascript
Task({
  subagent_type: "codex-deep-reviewer",
  prompt: `CONTEXT: Meta-analysis of code review findings
SCOPE: Analyze synthesized findings:
  Security: ${securityFindings}
  Performance: ${performanceFindings}
  Architecture: ${architectureFindings}
  Quality: ${qualityFindings}

CONSTRAINTS: Find emergent risks, priority adjustments, missed issues
OUTPUT: Cross-cutting concerns, priority changes, additional findings

MCP: Use Codex for deep reasoning about systemic issues`,
  description: "Deep analysis",
  run_in_background: false  // Wait for this one
})
```

### Phase 6: Confirm Next Steps

```javascript
AskUserQuestion({
  questions: [{
    question: `Found ${p1Count} critical, ${p2Count} important, ${p3Count} minor issues. How to proceed?`,
    header: "Action",
    options: [
      {label: "Create todo files (Recommended)", description: "Write findings to .claude/todos/"},
      {label: "Fix P1 issues now", description: "Immediately address critical issues"},
      {label: "Show full report", description: "Display all findings in detail"},
      {label: "Skip todo creation", description: "Just show summary"}
    ],
    multiSelect: false
  }]
})
```

### Phase 7: Create Todo Files

For each finding, create in `.claude/todos/`:

```markdown
# [NNN]-pending-[priority]-[brief-slug].md

## Finding
[Description of the issue]

## Location
- File: [path]
- Line: [number]

## Fix
[Recommended fix]

## Agent
[Which agent found this]
```

## Success Criteria

- [ ] AskUserQuestion used for target clarification
- [ ] TodoWrite tracks progress throughout
- [ ] All relevant agents launched in parallel (single message)
- [ ] Findings deduplicated and prioritized (P1/P2/P3)
- [ ] AskUserQuestion confirms next steps
- [ ] Todo files created for findings
