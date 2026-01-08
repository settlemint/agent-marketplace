---
description: CRITICAL monorepo rules - ALL commands from root
globs: "**/*"
alwaysApply: true
---

# Monorepo Rules

## ⛔ ABSOLUTE RULE - NO EXCEPTIONS ⛔

# ALL COMMANDS RUN FROM THE ROOT OF THE PROJECT

**This is NON-NEGOTIABLE in a Turborepo setup.**

## NEVER DO THIS

```bash
# ❌ WRONG - NEVER cd into packages
cd packages/app && bun test
cd apps/web && bun run dev
cd kit/dapp && bun run build

# ❌ WRONG - NEVER run commands from subdirectories
packages/core$ bun test
apps/api$ bun run start

# ❌ WRONG - NEVER use relative paths from packages
../node_modules/.bin/vitest
```

## ALWAYS DO THIS

```bash
# ✅ CORRECT - ALL commands from repository root
bun run test
bun run build
bun run dev
bun run ci
bun run test:integration

# ✅ CORRECT - Use turbo filtering if needed
bun run test --filter=@app/core
bun run build --filter=./apps/web
```

## WHY THIS MATTERS

1. **Turborepo caching** - Only works correctly from root
2. **Dependency resolution** - Hoisted node_modules at root
3. **Task orchestration** - Turbo manages task dependencies
4. **Consistent environment** - Root .env files loaded correctly
5. **CI parity** - CI always runs from root

## THE RULE APPLIES TO

- `bun run *` commands
- `bun test` / `bunx` commands
- `npm` / `yarn` / `pnpm` commands
- Any script execution
- Test runners (vitest, jest, playwright)
- Linters (eslint, biome, ultracite)
- Build tools (tsc, vite, webpack)
- **EVERYTHING**

## IF YOU THINK YOU NEED TO CD

**You don't.** Use Turbo's `--filter` flag instead:

```bash
# Run tests for specific package
bun run test --filter=@scope/package-name

# Run build for specific app
bun run build --filter=./apps/my-app

# Run command for package and its dependencies
bun run build --filter=@scope/package...
```

## ENFORCEMENT

This rule is enforced by:

- Pre-commit hooks
- CI pipeline checks
- Code review requirements

**Violations will cause CI failures and blocked PRs.**
