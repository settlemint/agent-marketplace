---
name: ast-grep
description: Mass rename/replace across codebase. Use when user asks to rename functions, replace patterns, or refactor code across files. Better than grep for code changes.
triggers:
  - "rename all"
  - "replace all.*with"
  - "refactor.*across"
  - "change all.*to"
  - "find and replace"
  - "ast-grep"
  - "sg "
---

<objective>

Search and refactor code using AST patterns. Unlike grep, ast-grep understands syntax - finds code structures, ignores strings/comments.

</objective>

<quick_start>

```bash
# Search
sg --pattern "console.log($$$)" --lang typescript
sg -p "async function $FUNC($$$)" -l typescript src/

# Refactor (preview first)
sg -p "console.log($MSG)" -r "logger.info($MSG)" -l typescript --debug-query
sg -p "console.log($MSG)" -r "logger.info($MSG)" -l typescript  # Apply
```

</quick_start>

<pattern_syntax>

| Syntax  | Meaning         | Example             |
| ------- | --------------- | ------------------- |
| `$NAME` | Single node     | `$FUNC($ARG)`       |
| `$$$`   | Multiple nodes  | `function($$$ARGS)` |
| `$_`    | Any single node | `$_.map($$$)`       |

</pattern_syntax>

<common_patterns>

```bash
# Functions
sg -p "async function $FUNC($$$)" -l typescript
sg -p "const $NAME = ($$$) => $BODY" -l typescript

# Imports
sg -p 'import { $$$IMPORTS } from "$MODULE"' -l typescript

# React
sg -p "use$HOOK($$$)" -l tsx
sg -p "<$COMPONENT $$$PROPS />" -l tsx

# Types
sg -p "interface $NAME { $$$BODY }" -l typescript
sg -p "type $NAME = $TYPE" -l typescript
```

</common_patterns>

<parameters>

| Flag            | Description                                             |
| --------------- | ------------------------------------------------------- |
| `-p, --pattern` | AST pattern (required)                                  |
| `-l, --lang`    | Language: typescript, tsx, javascript, go, rust, python |
| `-r, --rewrite` | Replacement pattern                                     |
| `--debug-query` | Preview without changing                                |
| `--json`        | JSON output                                             |

</parameters>

<vs_grep>

| ast-grep (sg)            | ripgrep (rg)     |
| ------------------------ | ---------------- |
| Syntax-aware             | Raw text/regex   |
| Ignores strings/comments | All text         |
| Precise refactoring      | Fast file search |

</vs_grep>

<success_criteria>

- Pattern matches expected structures
- `--debug-query` shows correct matches before refactoring
- Correct language flag (`tsx` for JSX, `typescript` for pure TS)

</success_criteria>
