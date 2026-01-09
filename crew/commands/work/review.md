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
  - MCPSearch
skills:
  - crew:crew-patterns
  - n-skills:orchestration
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
// Per n-skills:orchestration - haiku for fast parallel checks
for (const leg of legs) {
  Task({
    subagent_type: `crew:review:${leg}-reviewer`,
    prompt: `Review changed files for ${leg} issues.

FILES: ${changedFiles.join(", ")}

OUTPUT FORMAT (one per line):
[P0|P1|P2|Obs] file:line - description
Fix: recommended solution

Focus on ${legFocus[leg]}. Be thorough.`,
    description: `${leg}-review`,
    model: "haiku",
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

## Step 4: Meta-Review Cross-Cutting Analysis

```javascript
// Use meta-reviewer for cross-leg pattern detection
Task({
  subagent_type: "crew:review:meta-reviewer",
  prompt: `Synthesize findings from all 7 review legs.

FINDINGS BY LEG:
${JSON.stringify(groupByLeg(findings), null, 2)}

Identify:
1. Cross-leg patterns (same issue across multiple legs)
2. Priority escalations (P2→P1 when risks compound)
3. Priority demotions (dedupe findings across legs)
4. Systemic root causes explaining multiple findings
5. Contradictions between legs to resolve

OUTPUT: Additional findings with adjusted priorities.`,
  description: "meta-review",
});

const metaResult = TaskOutput({ task_id: "meta-review", block: true });
findings.push(...parseMetaFindings(metaResult));
```

## Step 5: Codex Deep Analysis

```javascript
// Load Codex MCP for deep reasoning
MCPSearch({ query: "select:mcp__plugin_crew_codex__codex" });

// Use Codex for cross-cutting analysis
mcp__plugin_crew_codex__codex({
  prompt: `Analyze these code review findings for patterns and systemic issues:

FINDINGS:
${findings.map((f) => `[${f.severity}] ${f.file}:${f.line} - ${f.description}`).join("\n")}

Identify:
1. Root causes that explain multiple findings
2. Architectural issues causing repeated problems
3. Priority escalations (P2 that should be P1 due to systemic nature)
4. Missing findings the individual reviewers may have missed

Output additional findings in format:
[P0|P1|P2] file:line - description (CODEX: systemic issue)`,
});

// Add Codex findings to the list
findings.push(...parseCodexFindings(codexResult));
```

## Step 6: Update Plan Findings

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

## Step 7: Report Summary

```javascript
const p0 = findings.filter((f) => f.severity === "p0").length;
const p1 = findings.filter((f) => f.severity === "p1").length;
const p2 = findings.filter((f) => f.severity === "p2").length;
const obs = findings.filter((f) => f.severity === "obs").length;
const total = p0 + p1 + p2 + obs;

if (total > 0) {
  console.log(
    `REVIEW: ${total} findings added to plan (${p0} P0, ${p1} P1, ${p2} P2, ${obs} Obs) - fix ALL before completion`,
  );
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
- [ ] Meta-reviewer for cross-cutting analysis
- [ ] Codex deep analysis for systemic issues
- [ ] ALL findings (P0/P1/P2/Obs) written to plan
- [ ] Existing open findings preserved
- [ ] Summary reports total - ALL must be fixed

</success_criteria>
