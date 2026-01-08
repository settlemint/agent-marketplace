---
description: CI check requirements before commits and PRs
globs: "**/*"
alwaysApply: true
---

# CI Requirements

These rules ensure code quality through mandatory CI checks.

## Pre-Commit Checks

Before any commit, these checks should pass:

### Quick Checks (Run Direct)

```bash
# Formatting (auto-fixes)
bunx ultracite fix

# Type checking
bun run typecheck
```

### Full CI Suite

```bash
# Run all checks
bun run ci
```

## CI Command Execution

### NEVER Run CI Commands Directly in Main Context

Direct execution pollutes context with verbose output:

```javascript
// WRONG - output floods context
Bash({ command: "bun run test" });
Bash({ command: "bun run ci" });
```

### ALWAYS Use Test-Runner Agent or Bash Subagent

```javascript
// CORRECT - isolated context
Task({
  subagent_type: "Bash",
  prompt: "Run bun run ci and report pass/fail with error details",
  description: "ci-check",
  run_in_background: false,
});
```

Or use the skill:

```javascript
Skill({ skill: "crew:ci" });
```

## Required Checks

### For All Changes

| Check  | Command                | Purpose         |
| ------ | ---------------------- | --------------- |
| Format | `bunx ultracite fix`   | Code formatting |
| Lint   | `bunx ultracite check` | Code quality    |
| Types  | `bun run typecheck`    | Type safety     |

### For Code Changes

| Check       | Command                    | Purpose       |
| ----------- | -------------------------- | ------------- |
| Unit Tests  | `bun run test`             | Functionality |
| Integration | `bun run test:integration` | End-to-end    |

### For PRs

| Check   | Command         | Purpose          |
| ------- | --------------- | ---------------- |
| Full CI | `bun run ci`    | All checks       |
| Build   | `bun run build` | Production build |

## Failure Handling

### On CI Failure

1. Read the error output carefully
2. Create fix task files for each issue
3. Fix issues in priority order (P0 → P1 → P2)
4. Re-run CI after fixes

### Common Issues

| Error Type   | Solution                    |
| ------------ | --------------------------- |
| Type error   | Check types, add assertions |
| Lint error   | Run `bunx ultracite fix`    |
| Test failure | Fix test or implementation  |
| Build error  | Check imports, dependencies |

## Pre-PR Checklist

Before creating a PR:

- [ ] `bun run ci` passes
- [ ] `bun run test:integration` passes (if applicable)
- [ ] No uncommitted changes
- [ ] Branch is rebased on main
- [ ] Commit messages follow conventions

## Blocking Rules

**DO NOT** create a PR if:

- Any CI check fails
- Type errors exist
- Tests are failing
- Linting errors remain

**DO NOT** skip CI checks with:

- `--no-verify`
- Commenting out tests
- Ignoring lint rules inline
