---
name: ast-grep
description: AST-based code search and refactoring using ast-grep (sg). Use for structural code patterns like function calls, imports, class definitions - not just text matching.
triggers: ["ast-grep", "sg ", "structural search", "refactor pattern", "find function", "find import", "code pattern"]
---

<objective>
Search and refactor code using AST patterns. Unlike grep/ripgrep, ast-grep understands syntax - it finds code structures while ignoring strings and comments.
</objective>

<quick_start>
**Search for pattern:**
```bash
sg --pattern "console.log($$$)" --lang typescript
```

**Search in directory:**
```bash
sg -p "async function $FUNC($$$)" -l typescript src/
```

**Refactor (dry run first):**
```bash
sg -p "console.log($MSG)" -r "logger.info($MSG)" -l typescript --debug-query
```

**Apply refactor:**
```bash
sg -p "console.log($MSG)" -r "logger.info($MSG)" -l typescript
```
</quick_start>

<pattern_syntax>
| Syntax | Meaning | Example |
|--------|---------|---------|
| `$NAME` | Single node (variable, expr) | `$FUNC($ARG)` |
| `$$$` | Multiple nodes (args, statements) | `function($$$ARGS)` |
| `$_` | Any single node (wildcard) | `$_.map($$$)` |
</pattern_syntax>

<common_patterns>
**Functions:**
```bash
sg -p "async function $FUNC($$$)" -l typescript
sg -p "const $NAME = ($$$) => $BODY" -l typescript
sg -p "function $NAME($$$): $RETURN { $$$BODY }" -l typescript
```

**Imports:**
```bash
sg -p 'import { $$$IMPORTS } from "$MODULE"' -l typescript
sg -p 'import $DEFAULT from "$MODULE"' -l typescript
```

**React:**
```bash
sg -p "use$HOOK($$$)" -l tsx
sg -p "useState($INIT)" -l tsx
sg -p "<$COMPONENT $$$PROPS />" -l tsx
```

**Types:**
```bash
sg -p "interface $NAME { $$$BODY }" -l typescript
sg -p "type $NAME = $TYPE" -l typescript
sg -p "$EXPR as $TYPE" -l typescript
```

**Error handling:**
```bash
sg -p "try { $$$TRY } catch ($ERR) { $$$CATCH }" -l typescript
sg -p "throw new $ERROR($$$)" -l typescript
```

**Exports:**
```bash
sg -p "export { $$$EXPORTS }" -l typescript
sg -p "export const $NAME = $VALUE" -l typescript
sg -p "export default $EXPR" -l typescript
```
</common_patterns>

<parameters>
| Flag | Description |
|------|-------------|
| `-p, --pattern` | AST pattern to match (required) |
| `-l, --lang` | Language: `typescript`, `tsx`, `javascript`, `go`, `rust`, `python` |
| `-r, --rewrite` | Replacement pattern |
| `--debug-query` | Preview matches without changing |
| `-A/-B/-C` | Context lines after/before/around |
| `--json` | JSON output for scripting |
</parameters>

<vs_grep>
| Use ast-grep (sg) | Use ripgrep (rg) |
|-------------------|------------------|
| Syntax-aware patterns | Raw text/regex |
| Ignores strings/comments | All text matches |
| Refactoring with precision | Fast file search |
| Complex code structures | Simple keywords |
</vs_grep>

<success_criteria>
- [ ] Pattern matches expected code structures
- [ ] `--debug-query` shows correct matches before refactoring
- [ ] Refactoring doesn't break syntax
- [ ] Correct language flag used (`tsx` for JSX, `typescript` for pure TS)
</success_criteria>
