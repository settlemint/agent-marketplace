---
name: crew:work:ci
description: Run CI checks and write failures to plan findings
argument-hint: "[plan slug]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
context: fork
hooks:
  PostToolUse: false
  PreToolUse: false
---

<objective>

Run CI checks (test, lint, typecheck, format) and write all failures to the plan's findings section.

</objective>

<workflow>

## Step 1: Detect Package Manager

```javascript
const pm = Bash({
  command:
    "[ -f bun.lock ] && echo bun || ([ -f pnpm-lock.yaml ] && echo pnpm || echo npm)",
}).trim();
```

## Step 2: Run CI via Bash Subagent

```javascript
Task({
  subagent_type: "Bash",
  prompt: `Run full CI and report ALL failures:

1. Run: ${pm} run ci || (${pm} run lint && ${pm} run test && ${pm} run typecheck)

2. Parse output and list EVERY failure:
   - Test failures: file:line - test name - error
   - Lint errors: file:line - rule - message
   - Type errors: file:line - TS error - message
   - Format issues: file - description

3. Output format (one per line):
   [TEST|LINT|TYPE|FORMAT] file:line - message

4. End with summary:
   TOTAL: X failures (Y test, Z lint, W type, V format)
   or
   ALL CHECKS PASSING`,
  description: "ci-full",
  run_in_background: false,
});
```

## Step 3: Parse Results

```javascript
const failures = parseFailures(ciOutput);
// Returns: [{ type, file, line, message }]
```

## Step 4: Update Plan Findings

```javascript
const slug = "$ARGUMENTS".trim();
const planPath = `.claude/plans/${slug}.yaml`;
const plan = Read({ file_path: planPath });

// Clear old CI findings (they're stale)
plan.findings = plan.findings || {};
plan.findings.ci = [];

// Add current failures
for (const failure of failures) {
  plan.findings.ci.push({
    id: `CI-${String(plan.findings.ci.length + 1).padStart(3, "0")}`,
    type: failure.type.toLowerCase(),
    status: "open",
    file: failure.file,
    line: failure.line,
    message: failure.message,
    added: new Date().toISOString(),
  });
}

Write({ file_path: planPath, content: yaml.stringify(plan) });
```

## Step 5: Report Status

```javascript
if (failures.length === 0) {
  console.log("CI PASSING - no failures to add to plan");
} else {
  console.log(
    `CI FAILING - added ${failures.length} findings to plan:`,
    failures.map((f) => `  ${f.type}: ${f.file}:${f.line}`).join("\n"),
  );
}
```

</workflow>

<success_criteria>

- [ ] All CI checks run (test, lint, typecheck)
- [ ] Failures parsed with file:line locations
- [ ] Plan findings.ci section updated
- [ ] Old CI findings cleared (replaced with current)
- [ ] Status reported (passing/failing)

</success_criteria>

<notes>

Follow @patterns/ci-requirements.md for CI check requirements.

</notes>
