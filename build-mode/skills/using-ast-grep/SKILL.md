---
name: using-ast-grep
description: This skill should be used when the user asks to "rename a function", "replace a pattern", "migrate an API", "mass refactor", or when doing AST-based code search. AST-aware search/refactor that ignores strings/comments.
version: 1.0.0
---

# ast-grep (sg)

AST-aware search/replace. Use for code structure; use grep for text/config/markdown.

## Quick Start

```bash
sg run -p "console.log($$$)" -l typescript              # Search
sg run -p "use$HOOK($$$)" -l tsx --debug-query          # Preview AST
sg run -p "console.log($MSG)" -r "logger.info($MSG)" -l ts  # Replace
sg scan -c sgconfig.yml                                 # Lint
```

## Syntax

| Pattern | Meaning | Example |
|---------|---------|---------|
| `$NAME` | Single node | `$FUNC($ARG)` |
| `$$$` | Zero+ nodes | `function($$$ARGS)` |
| `$_` | Anonymous | `$_.map($$$)` |

Rules: `$` + UPPERCASE. Valid: `$A`, `$FUNC1`. Invalid: `$func`.

## Common Patterns

```bash
# TypeScript
sg -p "async function $FUNC($$$)" -l typescript
sg -p 'import { $$$IMPORTS } from "$MODULE"' -l typescript
sg -p "interface $NAME { $$$BODY }" -l typescript

# React
sg -p "use$HOOK($$$)" -l tsx

# Refactors
sg -p "console.log($$$)" -r "" -l typescript
sg -p '$A && $A()' -r '$A?.()' -l typescript
```

## Commands

| Command | Purpose | Key Flags |
|---------|---------|-----------|
| `sg run` | Search/replace | `-p`, `-r`, `-l`, `-i` |
| `sg scan` | Lint | `-c`, `--json` |
| `sg test` | Test rules | `-c`, `-U` |

## Workflow

1. Preview: `--debug-query`
2. Test on single file
3. Review matches
4. Apply

## References

- `references/typescript-patterns.md`
- `references/rule-schema.md`
- https://ast-grep.github.io/playground.html
