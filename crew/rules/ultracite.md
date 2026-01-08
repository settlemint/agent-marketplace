---
description: Ultracite code quality and formatting standards
globs: "**/*"
alwaysApply: true
---

# Ultracite Code Quality

These rules enforce code formatting and linting standards using Ultracite.

## Commands

### Quick Fix (Auto-Format)

```bash
bunx ultracite fix
```

### Check Only (No Changes)

```bash
bunx ultracite check
```

## When to Run

### Before Every Commit

```bash
bunx ultracite fix
```

### In CI/PR Checks

```bash
bunx ultracite check
```

## Integration with Hooks

The `PostToolUse` hook automatically runs `bunx ultracite fix` on edited files.

## Common Issues

| Issue              | Solution                            |
| ------------------ | ----------------------------------- |
| Import order wrong | `bunx ultracite fix` auto-sorts     |
| Unused imports     | `bunx ultracite fix` removes them   |
| Formatting issues  | `bunx ultracite fix` reformats      |
| Type-only imports  | Ultracite converts to `import type` |

## Rules Enforced

Ultracite combines multiple tools:

- **Biome**: Fast linting and formatting
- **Import sorting**: Organized, consistent imports
- **Unused code detection**: Removes dead imports/variables
- **TypeScript best practices**: Strict type checking patterns

## Package Manager

**ALWAYS** use `bunx` (not `npx`) for running Ultracite:

```bash
# CORRECT
bunx ultracite fix
bunx ultracite check

# WRONG - do not use npx
npx ultracite fix
```
