---
name: crew:ci
description: Run CI checks (test, lint, format, typecheck) via background haiku agent
argument-hint: "[test|lint|format|typecheck|all]"
---

## Task

Run CI checks in a dedicated background agent to keep the main thread responsive.

**Usage:**

- `/crew:ci` or `/crew:ci all` - Run all checks
- `/crew:ci test` - Run tests only
- `/crew:ci lint` - Run linting only
- `/crew:ci format` - Run format check only
- `/crew:ci typecheck` - Run type checking only

## Process

1. Spawn a haiku agent to run the requested checks
2. Agent reports only failures (not full output)
3. Main thread continues working while checks run

```javascript
// Detect package manager
const pm = Bash({
  command:
    "[ -f bun.lockb ] && echo bun || ([ -f pnpm-lock.yaml ] && echo pnpm || echo npm)",
}).trim();

// Map check type to command (supports eslint/prettier and biome)
const commands = {
  test: `${pm} run test || ${pm} exec vitest run`,
  lint: `${pm} run lint || ${pm} exec biome lint .`,
  format: `${pm} run format:check || ${pm} run format --check || ${pm} exec biome format . --check`,
  typecheck: `${pm} run typecheck || ${pm} exec tsc --noEmit`,
  all: `${pm} run ci || (${pm} run lint && ${pm} run test && ${pm} run typecheck)`,
};

const checkType = "$ARGUMENTS" || "all";
const cmd = commands[checkType] || commands.all;

Task({
  subagent_type: "general-purpose",
  model: "haiku",
  prompt: `TASK: Run ${checkType} checks

COMMAND: ${cmd}

OUTPUT FORMAT:
If all checks pass with no warnings: "ALL CHECKS PASSING"
If warnings or failures exist, report ALL issues:
- Check type (test/lint/format/typecheck)
- Severity (ERROR or WARN)
- File:line of issue (if available)
- Brief message (1 line per issue)

Example:
  ERROR lint: src/utils.ts:42 - 'foo' is declared but never used
  WARN  test: auth.test.ts - Test is skipped
  ERROR typecheck: api.ts:88 - Property 'bar' does not exist

Do NOT include:
- Passing tests/checks
- Full stack traces
- Timing information
- Success messages for individual files

Report ALL errors and warnings - do not truncate or limit.`,
  description: `ci-${checkType}`,
  run_in_background: true,
});
```

## Example Output

```
CI check complete: ALL CHECKS PASSING
```

or

```
CI check failed:
- lint: src/utils.ts:42 - 'foo' is declared but never used
- test: auth.test.ts:15 - Expected true, received false
- typecheck: api.ts:88 - Property 'bar' does not exist on type 'Foo'
```
