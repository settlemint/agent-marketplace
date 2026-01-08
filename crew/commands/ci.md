---
name: crew:ci
description: Run CI checks (test, lint, format, typecheck) via background haiku agent
argument-hint: "[test|lint|format|typecheck|all]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
  - Task
  - AskUserQuestion
  - TodoWrite
  - WebFetch
  - WebSearch
  - MCPSearch
  - Skill
context: fork
hooks:
  PostToolUse: false
  PreToolUse: false
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

Use the Bash subagent for CI checks. It runs in a separate context window, preventing output pollution in the main thread.

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
  subagent_type: "Bash",
  prompt: `Run CI check: ${checkType}

1. Run: ${commands[checkType]}
2. Report results:
   - Pass: "ALL CHECKS PASSING"
   - Fail: "[ERROR|WARN] type: file:line - message" (1 line per issue)

The Bash subagent handles large output in its own context - no temp files needed.`,
  description: `ci-${checkType}`,
  run_in_background: true,
});
```

</process>
