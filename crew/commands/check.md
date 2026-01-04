---
name: crew:check
description: Multi-agent code review with automatic triage
argument-hint: "[PR number, GitHub URL, branch name, or latest]"
aliases:
  - check
---

<objective>

Perform comprehensive code review with parallel agents, then auto-triage findings.

</objective>

<input>

<review_target>$ARGUMENTS</review_target>

</input>

<process>

**IMPORTANT:** Execute directly in main thread for native UI access.

## Phase 1: Determine Review Target

Parse input to determine what to review. If unclear:

```javascript
AskUserQuestion({
  questions: [{
    question: "What would you like me to check?",
    header: "Target",
    options: [
      {label: "Current branch", description: "Review changes on this branch vs main"},
      {label: "Latest PR", description: "Review the most recent pull request"},
      {label: "Specify PR number", description: "I'll tell you which PR"}
    ],
    multiSelect: false
  }]
})
```

## Phase 2: Fetch Metadata

```bash
# For PR reviews
gh pr view --json number,title,files,body

# For branch reviews
git diff main...HEAD --stat
git diff main...HEAD --name-only
```

## Phase 3: Create Progress Tracking

```javascript
TodoWrite([
  {content: "Fetch PR metadata", status: "completed", activeForm: "Fetching metadata"},
  {content: "Categorize changed files", status: "in_progress", activeForm: "Categorizing files"},
  {content: "Launch parallel review agents", status: "pending", activeForm: "Launching reviewers"},
  {content: "Collect agent findings", status: "pending", activeForm: "Collecting findings"},
  {content: "Synthesize and prioritize", status: "pending", activeForm: "Synthesizing"},
  {content: "Create todo files", status: "pending", activeForm: "Creating todos"},
  {content: "Auto-triage findings", status: "pending", activeForm: "Triaging"}
])
```

## Phase 4: Smart File Routing

| File Pattern | Primary Agent | Condition |
|--------------|---------------|-----------|
| `*.ts`, `*.tsx` | kieran-typescript-reviewer | Always for TS |
| `*.sol` | solidity-security-auditor | When .sol changed |
| `*/orpc/**`, `*/api/**` | data-integrity-guardian | When API changed |
| `*/migrations/*` | data-migration-expert | When migrations changed |
| `.claude/**/*.md` | agent-context-reviewer | When skills changed |
| All files | security-sentinel | Always |
| All files | code-simplicity-reviewer | Always |
| All files | architecture-strategist | Always |

## Phase 5: Launch Parallel Review Agents

```javascript
// CORE AGENTS - Always launch
Task({ subagent_type: "kieran-typescript-reviewer", prompt: "Review TypeScript quality for: [files]", run_in_background: true });
Task({ subagent_type: "security-sentinel", prompt: "Security audit for: [files]", run_in_background: true });
Task({ subagent_type: "code-simplicity-reviewer", prompt: "Simplicity review for: [files]", run_in_background: true });
Task({ subagent_type: "architecture-strategist", prompt: "Architecture review for: [files]", run_in_background: true });

// CONDITIONAL AGENTS - Based on file types
// Launch solidity-security-auditor when .sol files present
// Launch data-migration-expert when migrations present
// Launch agent-context-reviewer when .claude/ files present
```

## Phase 6: Collect and Synthesize

1. Use `TaskOutput` to collect results from each agent
2. **Deduplicate** - merge similar findings
3. Categorize by priority:
   - **P1 (Critical)** - Blocks merge, security issues
   - **P2 (Important)** - Should fix, not blocking
   - **P3 (Nice-to-have)** - Improvements

## Phase 7: Create Todo Files

For each finding, create in `.claude/todos/`:

```markdown
# [NNN]-pending-[priority]-[brief-slug].md
---
status: pending
priority: p1
tags: [review, agent-name]
---

## Finding
[Description]

## Location
[file:line]

## Proposed Fix
[How to resolve]
```

## Phase 8: Auto-Triage

**Automatically transition to triage:**

```javascript
Skill({ skill: "crew:triage" })
```

This allows user to approve/skip each finding before fixing.

</process>

<key_principles>

1. **Parallel execution** - Launch all agents at once
2. **Smart routing** - Only launch agents for relevant file types
3. **Deduplicate** - Merge similar findings
4. **Structured output** - Todo files enable tracking
5. **Auto-triage** - Don't leave findings unprocessed

</key_principles>

<success_criteria>

- [ ] All relevant agents launched
- [ ] Findings deduplicated and prioritized
- [ ] Todo files created for each finding
- [ ] Triage completed

</success_criteria>
