---
name: crew:ci
description: Run CI checks (test, lint, format, typecheck) via background haiku agent
argument-hint: "[test|lint|format|typecheck|all]"
allowed-tools: Read, Write, Edit, Bash, Grep, Glob, Task, AskUserQuestion, TodoWrite, WebFetch, WebSearch, MCPSearch, Skill
---

<input>
<check_type>$ARGUMENTS</check_type>
</input>

<usage>

| Command              | Effect             |
| -------------------- | ------------------ |
| `/crew:ci`           | Run all checks     |
| `/crew:ci test`      | Tests only         |
| `/crew:ci lint`      | Linting only       |
| `/crew:ci format`    | Format check only  |
| `/crew:ci typecheck` | Type checking only |

</usage>

<process>

Use `<pattern name="large-output"/>` to capture full output for later analysis.

```javascript
const pm = Bash({
  command:
    "[ -f bun.lock ] && echo bun || ([ -f pnpm-lock.yaml ] && echo pnpm || echo npm)",
}).trim();

const commands = {
  test: `${pm} run test || ${pm} exec vitest run`,
  lint: `${pm} run lint || ${pm} exec biome lint .`,
  format: `${pm} run format:check || ${pm} exec biome format . --check`,
  typecheck: `${pm} run typecheck || ${pm} exec tsc --noEmit`,
  all: `${pm} run ci || (${pm} run lint && ${pm} run test && ${pm} run typecheck)`,
};

Task({
  subagent_type: "general-purpose",
  model: "haiku",
  prompt: `Run CI check with output logged to temp file:

1. Create log file:
   LOG=/tmp/ci-${checkType}-$$.log
   echo "Log file: $LOG"

2. Run command with full output captured:
   (${commands[checkType]}) 2>&1 | tee $LOG

3. Report results:
   - Pass: "ALL CHECKS PASSING"
   - Fail: "[ERROR|WARN] type: file:line - message" (1 line per issue)
   - Always include: "Full output: $LOG"

The log file preserves full stack traces and allows re-reading without re-running.`,
  description: `ci-${checkType}`,
  run_in_background: true,
});
```

</process>
