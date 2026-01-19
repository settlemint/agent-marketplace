---
name: using-ast-grep
description: Performs AST-based code search and refactoring across codebases. Understands syntax structure, ignores strings and comments. Use when renaming functions, replacing patterns, migrating APIs, finding code structures, or doing mass refactors. Better than grep for code changes.
version: 1.0.0
---

## Overview

ast-grep (sg) searches and refactors code using Abstract Syntax Tree patterns. Unlike grep which matches text, ast-grep understands code structure - it finds code patterns while ignoring strings and comments.

**When to use ast-grep vs grep:**
- **ast-grep**: Code structure changes, function renames, API migrations, pattern-based refactoring
- **grep/ripgrep**: Text search, configuration files, markdown, comments

## Quick Start

```bash
# SEARCH - Find patterns
sg run -p "console.log($$$)" -l typescript           # Find all console.log calls
sg run -p "async function $FUNC($$$)" -l typescript  # Find async functions

# EXPLORE - Understand code (read-only)
sg run -p "use$HOOK($$$)" -l tsx --debug-query       # See AST structure

# REPLACE - Refactor code
sg run -p "console.log($MSG)" -r "logger.info($MSG)" -l ts --debug-query  # Preview first!
sg run -p "console.log($MSG)" -r "logger.info($MSG)" -l ts                # Apply

# LINT - Use YAML rules
sg scan -c sgconfig.yml                              # Run all rules
```

## Pattern Syntax

| Syntax    | Meaning                | Example                      |
|-----------|------------------------|------------------------------|
| `$NAME`   | Single AST node        | `$FUNC($ARG)`                |
| `$$$`     | Zero or more nodes     | `function($$$ARGS)`          |
| `$$$NAME` | Named multiple nodes   | `import { $$$IMPORTS } from` |
| `$_`      | Anonymous (no capture) | `$_.map($$$)`                |

**Rules:** `$` + UPPERCASE + optional digits. Valid: `$A`, `$FUNC1`, `$_`. Invalid: `$func`, `$123`.

## Common Patterns

### TypeScript/TSX

```bash
# Functions
sg -p "async function $FUNC($$$)" -l typescript
sg -p "const $NAME = ($$$) => $BODY" -l typescript
sg -p "const $NAME = async ($$$) => $BODY" -l typescript

# Imports
sg -p 'import { $$$IMPORTS } from "$MODULE"' -l typescript
sg -p 'import $DEFAULT from "$MODULE"' -l typescript

# React Hooks
sg -p "use$HOOK($$$)" -l tsx
sg -p "useState($INITIAL)" -l tsx

# Types
sg -p "interface $NAME { $$$BODY }" -l typescript
sg -p "type $NAME = $TYPE" -l typescript

# Common Refactors
sg -p "console.log($$$)" -r "" -l typescript         # Remove console.log
sg -p '$A && $A()' -r '$A?.()' -l typescript         # Optional chaining
```

## CLI Commands

| Command   | Purpose          | Key Flags                                               |
|-----------|------------------|--------------------------------------------------------|
| `sg run`  | Search/replace   | `-p` pattern, `-r` rewrite, `-l` lang, `-i` interactive |
| `sg scan` | Lint with rules  | `-c` config, `-r` rule, `--json`, `--format github`     |
| `sg test` | Test YAML rules  | `-c` config, `-U` update snapshots                      |
| `sg new`  | Scaffold rules   | `project`, `rule`, `test`                               |

**Common flags:** `--debug-query` (preview), `--json` (output), `-A/-B/-C` (context), `--heading` (group)

## Workflow

**Always preview before applying:**

1. Write pattern with `--debug-query` to verify AST matching
2. Test on single file first
3. Review matches with `--json` for programmatic analysis
4. Apply changes when confident

**Integration with LSP:**

1. ast-grep scan to find patterns → identify files/lines
2. LSP `findReferences` → verify scope is as expected
3. ast-grep apply → execute transformation

## Language Support

**Supported (31 languages):** Bash, C, C++, C#, CSS, Elixir, Go, Haskell, HCL (Terraform), HTML, Java, JavaScript, JSON, Kotlin, Lua, Nix, PHP, Python, Ruby, Rust, Scala, Solidity, Swift, TypeScript, TSX, YAML

**Language flags:** `-l typescript`, `-l tsx`, `-l hcl`, `-l bash`, `-l yaml`

**Not supported:** Markdown (use ripgrep)

## Constraints

**Required:**
- Always preview with `--debug-query` before refactors
- Use correct language flag for file type (`tsx` vs `typescript` matters)
- Test patterns on single file before codebase-wide changes

**Avoid:**
- Using grep for code structure changes
- Applying changes without preview
- Using `$_` when capture is needed for replacement
- Forgetting `$$$` for variadic matches (function arguments)

## Additional Resources

### Reference Files

For detailed patterns by language, consult:
- **`references/typescript-patterns.md`** - Functions, imports, React, types
- **`references/exploration-guide.md`** - Codebase exploration techniques
- **`references/rule-schema.md`** - YAML rule syntax for `sg scan`

### External Resources

- **Playground:** https://ast-grep.github.io/playground.html
- **Documentation:** https://ast-grep.github.io/
