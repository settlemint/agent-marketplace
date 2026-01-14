# Work-Adaptive Workflow

**Purpose:** Execute a plan using adaptive strategies based on probe story results and real-time metrics.

## Core Concept: Adaptive Execution

Instead of rigid phases, this workflow adapts based on actual results:

```
PROBE STORY → METRICS → ADAPTIVE DECISION → REMAINING STORIES
```

## Phase 1: Setup

Load plan and initialize tracking.

```javascript
// Spawn opus worker to:
// 1. Verify not on main branch
// 2. Read plan file and return story list
Task({
  subagent_type: "Explore",
  model: "opus",
  description: "Load plan",
  prompt: `WORKER TASK: Read plan and return stories.
  1. Check branch: git branch --show-current (fail if main/master)
  2. Read: .claude/plans/${slug}.yaml
  3. Return: list of stories with id, title, priority, status`,
  run_in_background: true,
});

// Convert stories to TodoWrite
TodoWrite([
  {
    content: "STORY-001: Title",
    status: "in_progress",
    activeForm: "Implementing...",
  },
  { content: "STORY-002: Title", status: "pending", activeForm: "Waiting..." },
]);

// Initialize failure budget
updateState({
  failure_budget: {
    worker: { current: 0, max: 5, consecutive: 0 },
    ci: { iterations: 0, max: 3 },
    review: { passes: 0, unfixed_p1: 0 },
    error_signatures: [],
  },
});
```

## Phase 2: Probe Story

Run the first story as a probe to calibrate execution strategy.

```javascript
const probeStart = Date.now();

Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "Probe story",
  prompt: `${WORKER_PREAMBLE}

  TASK: Implement ${stories[0].title}

  ACCEPTANCE CRITERIA:
  ${stories[0].acceptance.map((a) => `- Given ${a.given}, when ${a.when}, then ${a.then}`).join("\n")}

  TDD REQUIRED: Write failing test first, then implement.

  Report when complete with: files created, tests passing, time taken.`,
  run_in_background: true,
});
```

### Probe Outcome Matrix

| Outcome                | Signal               | Action                 |
| ---------------------- | -------------------- | ---------------------- |
| Success + Good metrics | Plan solid           | Fan-Out remaining      |
| Success + Poor metrics | Harder than expected | Pipeline + full phases |
| Quick Failure (<2 min) | Missing context      | Retry with context     |
| Slow Failure (2-5 min) | Standard difficulty  | Apply failure budget   |
| Timeout (>5 min)       | Too complex          | Break into subtasks    |
| Partial Success        | Hit specific blocker | Analyze and continue   |

### Probe Failure Handling

```javascript
if (probeResult.status === "failed") {
  const duration = (Date.now() - probeStart) / 1000 / 60; // minutes

  if (duration < 2) {
    // Quick failure - retry with more context
    retryWithContext(stories[0]);
  } else if (duration < 5) {
    // Apply failure budget
    incrementFailureBudget("worker");
    if (state.failure_budget.worker.current >= 3) {
      escalateToUser("Probe story failed 3 times");
    }
  } else {
    // Timeout - escalate immediately
    AskUserQuestion({
      questions: [
        {
          question: `Probe story took ${duration.toFixed(1)} min. Options:`,
          header: "Probe Timeout",
          options: [
            {
              label: "Break into subtasks",
              description: "Split into smaller stories",
            },
            {
              label: "Try different approach",
              description: "Re-plan this story",
            },
            {
              label: "Use Story 2 as probe",
              description: "Try another story first",
            },
            {
              label: "Manual intervention",
              description: "I'll handle this myself",
            },
          ],
          multiSelect: false,
        },
      ],
    });
  }
}
```

## Phase 3: Collect Metrics (Tier 1 - Always)

After probe completes, collect cheap metrics:

```bash
# Run: crew/scripts/metrics/collect-story-metrics.sh
# Returns:
{
  "files_changed": 12,
  "lines_added": 340,
  "lines_removed": 45,
  "collected_at": "ISO-timestamp"
}
```

Store in plan findings for adaptive decisions.

## Phase 4: Adaptive Pattern Selection

Based on probe metrics, choose execution pattern:

| Metric        | Lightweight Path | Full Treatment |
| ------------- | ---------------- | -------------- |
| Files changed | ≤5               | >5             |
| Lines changed | ≤200             | >200           |
| Probe time    | ≤2 min           | >5 min         |
| Complexity    | Low              | High           |

### Decision Logic

```javascript
if (metrics.files_changed <= 5 && metrics.lines_added < 200 && probeTime <= 2) {
  // Lightweight path
  executionPattern = "fan-out";
  skipRefinement = true;
  reviewScope = "lightweight"; // 1-2 agents
} else {
  // Full treatment
  executionPattern = "pipeline";
  skipRefinement = false;
  reviewScope = "full"; // 5 agents
}
```

## Phase 5: Execute Remaining Stories

Based on pattern selected:

### Fan-Out (Parallel)

```javascript
// All remaining stories in parallel
const workers = stories.slice(1).map((story) =>
  Task({
    subagent_type: "general-purpose",
    model: "opus",
    description: story.title,
    prompt: `${WORKER_PREAMBLE}\n\nTASK: ${story.title}\n\n${story.acceptance}`,
    run_in_background: true,
  }),
);

// Wait for all
await Promise.all(workers.map((w) => TaskOutput({ task_id: w.id })));
```

### Pipeline (Sequential)

```javascript
// One at a time, with verification between
for (const story of stories.slice(1)) {
  const result = await executeStory(story);

  // Check progress after each
  if (!result.success) {
    handleFailure(result);
  }

  // Update TodoWrite
  markComplete(story.id);
}
```

## Phase 6: Refinement (Conditional)

**Skip if:**

- `files_changed ≤ 2 AND lines_changed < 100 AND p1_findings = 0`

**Run if:**

- Coverage < 70% OR complexity HIGH OR p1_findings > 0

```javascript
if (!skipRefinement) {
  Task({
    subagent_type: "code-simplifier",
    model: "opus",
    description: "Refine code",
    prompt: `Apply code-simplifier patterns to files changed in this branch.

    Focus on:
    - Simplify complex conditionals
    - Extract reusable functions
    - Improve naming
    - Reduce cognitive complexity

    Run tests after each change.`,
    run_in_background: true,
  });
}
```

## Phase 7: Review (Adaptive Scope)

Based on metrics and probe quality:

### Lightweight Review (1-2 agents)

If probe was fast and clean:

```javascript
// Security review only
Task({
  subagent_type: "general-purpose",
  model: "opus",
  description: "Security review",
  prompt: `Quick security scan of changed files.
  Focus on: injection, auth flaws, sensitive data exposure.
  Output: P1/P2/P3 findings.`,
  run_in_background: true,
});
```

### Full Review (5 agents)

If probe had issues or scope is large:

```javascript
// Spawn all 5 reviewers in parallel (as in original crew:work)
const reviewers = [
  { domain: "security", focus: "OWASP Top 10" },
  { domain: "architecture", focus: "Pattern consistency" },
  { domain: "ui-ux", focus: "Design guidelines" },
  { domain: "tests", focus: "Coverage gaps" },
  { domain: "quality", focus: "Code complexity" },
];

// Fan-out all reviewers
```

### Review Convergence (Rule of Five)

```javascript
if (p1Findings > 0 || p2Findings > 3) {
  // Trigger iterative review
  for (let pass = 1; pass <= 5 && hasFindings; pass++) {
    // Fix findings
    await fixFindings(findings);
    // Re-review changed files only
    findings = await reviewChangedFiles();
    // Check convergence
    hasFindings = findings.length > 0;
  }
}
```

## Phase 8: CI Validation

Run CI with failure categorization:

```javascript
Skill({ skill: "crew:work:ci", args: slug });

// If CI fails, categorize and route
if (ciResult.failures) {
  const categories = categorizeFailures(ciResult);

  // Route to specialists
  if (categories.type_errors) {
    spawnTypescriptSpecialist(categories.type_errors);
  }
  if (categories.test_failures) {
    spawnTddExpert(categories.test_failures);
  }
  if (categories.lint_errors) {
    spawnCodeSimplifier(categories.lint_errors);
  }

  // Apply CI failure budget
  state.failure_budget.ci.iterations++;
  if (state.failure_budget.ci.iterations >= 3) {
    escalateToUser("CI failed 3 iterations");
  }
}
```

## Phase 9: Completion

```javascript
// Update state to COMPLETE
updateState({
  routing: {
    current_mode: "complete",
    completed_at: new Date().toISOString(),
  },
});

AskUserQuestion({
  questions: [
    {
      question: "All work complete. What would you like to do?",
      header: "Git Action",
      options: [
        {
          label: "Create PR",
          description: "Commit, push, and open pull request",
        },
        {
          label: "Commit & Push",
          description: "Commit changes and push to origin",
        },
        { label: "Commit only", description: "Create commit without pushing" },
        { label: "Continue working", description: "Keep making changes" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Failure Budget & Escalation

### Budget Thresholds

| Category          | Auto-Retry Limit | Escalation Trigger |
| ----------------- | ---------------- | ------------------ |
| Worker (per-task) | 2 retries        | 3rd failure        |
| Worker (session)  | 5 total          | 6th failure        |
| CI iterations     | 2                | 3rd iteration      |
| Same CI error     | 2 occurrences    | 3rd occurrence     |
| P1 unfixed        | 0 (immediate)    | 1st occurrence     |
| Review passes     | 4                | 5th pass           |

### Escalation Options

```javascript
AskUserQuestion({
  questions: [
    {
      question: `${failureType} failed ${count} times. Options:`,
      header: "Failure Budget Exceeded",
      options: [
        {
          label: "Retry with context",
          description: "Add more context and try again",
        },
        { label: "Simplify task", description: "Break into smaller pieces" },
        {
          label: "Try different approach",
          description: "Use alternative strategy",
        },
        {
          label: "Skip task",
          description: "Mark as blocked, continue with rest",
        },
        {
          label: "Manual intervention",
          description: "I'll handle this myself",
        },
      ],
      multiSelect: false,
    },
  ],
});
```

### Stuck Detection

```javascript
// Progress = TRUE if ANY of:
// - Error count decreased
// - Tasks completed increased
// - New files modified (not same ones)

// Stuck = TRUE if ALL of:
// - 3+ iterations with no progress
// - Error count stable or increasing
// - Same files being touched repeatedly

if (isStuck()) {
  escalateToUser("No progress after 3 attempts");
}
```

## Success Criteria

- [ ] Probe story calibrates execution strategy
- [ ] Metrics collected after each phase (Tier 1 always)
- [ ] Adaptive decisions reduce unnecessary overhead
- [ ] Failure budget prevents infinite loops
- [ ] Escalation happens only when genuinely blocked
- [ ] State reflects current mode throughout
- [ ] CI passing before completion
- [ ] User presented with git action choices
