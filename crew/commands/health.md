---
name: crew:health
description: Systematic code health audit. Find code smells, large files, dead code, YAGNI violations, and technical debt.
allowed-tools:
  - Task
  - TaskOutput
  - TodoWrite
  - Glob
  - Grep
  - Read
  - Bash
---

<objective>
Conduct a comprehensive code health audit. Identify technical debt, code smells, and opportunities for improvement. File findings as TodoWrite items with severity ratings.
</objective>

<essential_principles>

- Spend 30-40% of development time on code health (not just feature work).
- Agents will always find problems - the question is how many and how severe.
- Regular audits prevent invisible technical debt from slowing agents down.
- Fix issues in dedicated sessions, not mixed with feature work.
  </essential_principles>

<audit_categories>

| Category                  | What to Look For                       |
| ------------------------- | -------------------------------------- |
| **Large Files**           | Files > 500 lines needing refactoring  |
| **Low Coverage**          | Code paths without test coverage       |
| **Duplication**           | Redundant systems, copy-pasted code    |
| **Dead Code**             | Unused exports, unreachable branches   |
| **YAGNI Violations**      | Over-engineered abstractions           |
| **Library Opportunities** | Hand-rolled code that libraries solve  |
| **Misplaced Files**       | Files in wrong directories or misnamed |
| **Debug Cruft**           | console.log, TODO comments, old plans  |

</audit_categories>

<workflow>

## Phase 1: Automated Discovery

Run parallel agents to scan for issues:

```javascript
// Launch discovery agents in parallel
Task({
  subagent_type: "Explore",
  description: "Find large files",
  prompt: `Find all source files > 500 lines. For each:
    - File path
    - Line count
    - Suggested split points
    Report as severity P2 (files > 1000 lines = P1).`,
  run_in_background: true,
});

Task({
  subagent_type: "Explore",
  description: "Find dead code",
  prompt: `Search for potentially dead code:
    - Exported functions never imported
    - Unreachable switch cases
    - Commented-out code blocks
    Report as P3 (dead exports = P2).`,
  run_in_background: true,
});

Task({
  subagent_type: "Explore",
  description: "Find debug cruft",
  prompt: `Search for debug artifacts:
    - console.log/warn/error statements
    - TODO/FIXME/HACK comments
    - Disabled tests (skip, only)
    - Old plan files in .claude/
    Report as P3.`,
  run_in_background: true,
});
```

## Phase 2: Structural Analysis

After discovery, analyze patterns:

```javascript
Task({
  subagent_type: "general-purpose",
  description: "Find duplication",
  prompt: `Analyze codebase for redundant systems:
    - Multiple implementations of same concept
    - Copy-pasted code blocks
    - Parallel hierarchies
    Report each with affected files and consolidation strategy.`,
  run_in_background: true,
});

Task({
  subagent_type: "general-purpose",
  description: "Find YAGNI violations",
  prompt: `Look for over-engineering:
    - Abstractions used only once
    - Configuration that's never varied
    - Generic handlers with single implementation
    Report with simplification opportunity.`,
  run_in_background: true,
});
```

## Phase 3: Opportunity Scan

Look for improvements:

```javascript
Task({
  subagent_type: "general-purpose",
  description: "Find library opportunities",
  prompt: `Identify hand-rolled code that libraries solve better:
    - Date/time manipulation
    - Validation logic
    - HTTP client wrappers
    - State management patterns
    Suggest specific libraries with migration effort estimate.`,
  run_in_background: true,
});
```

## Phase 4: Triage and Report

Collect all findings and triage:

```javascript
// After all agents complete
const findings = await Promise.all([
  TaskOutput({ task_id: largeFiles.id }),
  TaskOutput({ task_id: deadCode.id }),
  TaskOutput({ task_id: debugCruft.id }),
  TaskOutput({ task_id: duplication.id }),
  TaskOutput({ task_id: yagni.id }),
  TaskOutput({ task_id: libraries.id }),
]);

// Sort by severity and create TodoWrite items
TodoWrite(
  findings
    .flat()
    .sort((a, b) => severityOrder(a.severity) - severityOrder(b.severity))
    .map((f) => ({
      content: `[${f.severity}] ${f.category}: ${f.description}`,
      status: "pending",
      activeForm: `Fixing ${f.category.toLowerCase()}`,
    })),
);
```

</workflow>

<severity_guide>

| Severity | Criteria                                      | Action                |
| -------- | --------------------------------------------- | --------------------- |
| **P1**   | Blocks agents, causes bugs, security risk     | Fix immediately       |
| **P2**   | Slows agents, makes code harder to understand | Fix this sprint       |
| **P3**   | Code smell, minor improvement                 | Fix opportunistically |

</severity_guide>

<output_format>

After audit, produce:

```markdown
# Code Health Report

## Summary

- P1 findings: N
- P2 findings: N
- P3 findings: N
- Estimated cleanup effort: X hours

## Critical (P1)

1. [File]: [Issue] - [Suggested fix]

## High Priority (P2)

1. [File]: [Issue] - [Suggested fix]

## Medium Priority (P3)

1. [File]: [Issue] - [Suggested fix]

## Recommendations

1. Schedule dedicated cleanup session for P1/P2 items
2. Address P3 items during related feature work
3. Re-run audit after cleanup to verify improvement
```

</output_format>

<integration>
- Load `Skill({ skill: "devtools:rule-of-five" })` for multi-pass audit convergence.
- Run after `/crew:work` completes to catch accumulated debt.
- Schedule weekly for active codebases.
</integration>

<success_criteria>

- [ ] All audit categories scanned
- [ ] Findings triaged by severity
- [ ] TodoWrite populated with actionable items
- [ ] Report generated with cleanup recommendations
      </success_criteria>
