---
name: crew:work:review
description: Run quality review and write findings to plan
argument-hint: "[plan slug]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
skills:
  - crew:crew-patterns
context: fork
hooks:
  PostToolUse: false
  PreToolUse: false
---

<objective>

Run the seven-leg quality review on changed files and write all findings to the plan's findings section. This allows the Ralph Loop to see issues and fix them in the next iteration.

</objective>

<workflow>

## Step 1: Get Changed Files

```bash
git diff main...HEAD --name-only | grep -E '\.(ts|tsx|js|jsx|py|rb|go|rs)$'
```

## Step 2: Launch Review Agents (parallel)

```javascript
const legs = [
  "correctness",
  "performance",
  "security",
  "elegance",
  "resilience",
  "style",
  "smells",
];

// All 7 in single message for parallelism
for (const leg of legs) {
  Task({
    subagent_type: `crew:review:seven-legs:${leg}-reviewer`,
    prompt: `Review changed files for ${leg} issues.

FILES: ${changedFiles.join(", ")}

OUTPUT FORMAT (one per line):
[P0|P1|P2|Obs] file:line - description
Fix: recommended solution

Focus on ${legFocus[leg]}. Be thorough.`,
    description: `${leg}-review`,
    run_in_background: true,
  });
}
```

## Step 3: Collect Results

```javascript
const findings = [];
for (const leg of legs) {
  const result = TaskOutput({ task_id: `${leg}-review`, block: true });
  findings.push(...parseFindings(result, leg));
}
```

## Step 4: Update Plan Findings

```javascript
const slug = "$ARGUMENTS".trim();
const planPath = `.claude/plans/${slug}.yaml`;
const plan = Read({ file_path: planPath });

// Keep existing review findings that are still open
plan.findings = plan.findings || {};
const existingOpen = (plan.findings.review || []).filter(
  (f) => f.status === "open",
);

// Deduplicate: same file:line = same issue
const seen = new Set(existingOpen.map((f) => `${f.file}:${f.line}`));
const newFindings = findings.filter((f) => !seen.has(`${f.file}:${f.line}`));

// Merge
plan.findings.review = [
  ...existingOpen,
  ...newFindings.map((f, i) => ({
    id: `REV-${String(existingOpen.length + i + 1).padStart(3, "0")}`,
    severity: f.severity,
    leg: f.leg,
    status: "open",
    file: f.file,
    line: f.line,
    message: f.description,
    fix: f.fix,
    added: new Date().toISOString(),
  })),
];

Write({ file_path: planPath, content: yaml.stringify(plan) });
```

## Step 5: Report Summary

```javascript
const p0 = findings.filter((f) => f.severity === "p0").length;
const p1 = findings.filter((f) => f.severity === "p1").length;
const p2 = findings.filter((f) => f.severity === "p2").length;

if (p0 > 0 || p1 > 0) {
  console.log(
    `REVIEW BLOCKING: ${p0} P0, ${p1} P1 findings added to plan - fix before proceeding`,
  );
} else if (p2 > 0) {
  console.log(`REVIEW OK: ${p2} P2 findings added to plan - can proceed`);
} else {
  console.log("REVIEW CLEAN - no issues found");
}
```

</workflow>

<leg_focus>

| Leg         | Focus                                          |
| ----------- | ---------------------------------------------- |
| correctness | Edge cases, null handling, type safety, logic  |
| performance | Complexity, caching, N+1 queries, memory       |
| security    | OWASP, injection, auth, secrets, input         |
| elegance    | SOLID, clean architecture, cohesion, naming    |
| resilience  | Error handling, recovery, cleanup, degradation |
| style       | Conventions, formatting, idioms, consistency   |
| smells      | Duplication, complexity, dead code, debt       |

</leg_focus>

<success_criteria>

- [ ] Changed files identified
- [ ] All 7 review agents launched in parallel
- [ ] Findings parsed with severity and location
- [ ] Plan findings.review section updated
- [ ] Existing open findings preserved
- [ ] Summary reported with blocking status

</success_criteria>
