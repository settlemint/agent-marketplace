# Exploration Guide for ast-grep

Use ast-grep for codebase exploration and auditing without making changes.

## Understanding AST Structure

Before writing patterns, understand what the AST looks like:

```bash
# Debug query shows how pattern matches AST
sg run -p "your code pattern" --debug-query -l typescript

# Example: See how useState is parsed
sg run -p "useState($INITIAL)" --debug-query -l tsx
```

## Codebase Auditing

### Security Audit

```bash
# Find eval usage (dangerous)
sg run -p "eval($$$)" -l typescript

# Find dynamic code execution
sg run -p "new Function($$$)" -l typescript

# Find innerHTML (XSS risk)
sg run -p "dangerouslySetInnerHTML={{ __html: $CONTENT }}" -l tsx
sg run -p "$ELEM.innerHTML = $VALUE" -l typescript

# Find hardcoded secrets (pattern-based)
sg run -p 'const $NAME = "$VALUE"' -l typescript | grep -i "key\|secret\|password\|token"
```

### Code Quality Audit

```bash
# Find any type usage
sg run -p ": any" -l typescript
sg run -p "as any" -l typescript

# Find console statements
sg run -p "console.$METHOD($$$)" -l typescript

# Find TODO comments (needs grep complement)
sg run -p "// TODO: $$$" -l typescript  # May not work - comments are tricky

# Find empty catch blocks
sg run -p "catch ($ERR) { }" -l typescript
```

### React-Specific Audit

```bash
# Find useEffect without deps (infinite loop risk)
sg run -p "useEffect($CALLBACK)" -l tsx

# Find useState with object literal (reference issue)
sg run -p "useState({ $$$PROPS })" -l tsx

# Find inline function props (performance)
sg run -p "<$COMP $PROP={() => $$$} />" -l tsx
sg run -p "<$COMP onClick={() => $$$} />" -l tsx

# Find missing keys in lists
sg run -p "$ARR.map(($ITEM) => <$COMP $$$PROPS />)" -l tsx
```

## Finding Usage Patterns

### Function Usage

```bash
# Find all calls to a function
sg run -p "myFunction($$$)" -l typescript --heading

# Find all calls with specific argument count
sg run -p "myFunction($A, $B)" -l typescript  # Exactly 2 args
sg run -p "myFunction($A, $$$REST)" -l typescript  # At least 1 arg

# Find chained calls
sg run -p "$EXPR.method1($$$).method2($$$)" -l typescript
```

### Import Analysis

```bash
# Find all imports of a module
sg run -p 'import $$$IMPORTS from "react"' -l typescript --heading

# Find specific named import
sg run -p 'import { useState } from "react"' -l typescript

# Count imports per module (JSON output)
sg run -p 'import $$$IMPORTS from "$MODULE"' -l typescript --json | \
  jq -r '.[].meta.MODULE.text' | sort | uniq -c | sort -rn
```

### Type Usage

```bash
# Find all usages of a type
sg run -p ": MyType" -l typescript
sg run -p "<MyType>" -l typescript
sg run -p "MyType[]" -l typescript

# Find type assertions
sg run -p "$EXPR as $TYPE" -l typescript
sg run -p "<$TYPE>$EXPR" -l typescript
```

## Output Modes

### Grouped by File

```bash
sg run -p "console.log($$$)" -l typescript --heading
```

### With Context

```bash
# Show 3 lines before and after
sg run -p "throw new Error($$$)" -l typescript -A 3 -B 3

# Show 5 lines of context both ways
sg run -p "async function $NAME($$$)" -l typescript -C 5
```

### JSON for Processing

```bash
# Basic JSON output
sg run -p "useState($$$)" -l tsx --json

# Extract specific fields
sg run -p "useState($$$)" -l tsx --json | jq '.[].file' | sort -u

# Count matches per file
sg run -p "useEffect($$$)" -l tsx --json | jq -r '.[].file' | sort | uniq -c | sort -rn

# Get line numbers
sg run -p "$PATTERN" -l typescript --json | jq '.[] | "\(.file):\(.range.start.line)"'
```

## Exploration Workflows

### Understand a New Codebase

```bash
# 1. Find entry points
sg run -p "export default function $NAME($$$)" -l tsx --heading

# 2. Find main components
sg run -p "export function $NAME($$$)" -l tsx --heading | head -50

# 3. Find state management
sg run -p "createContext($$$)" -l tsx
sg run -p "useReducer($$$)" -l tsx

# 4. Find data fetching
sg run -p "useQuery($$$)" -l tsx
sg run -p "fetch($$$)" -l typescript
sg run -p "axios.$METHOD($$$)" -l typescript

# 5. Find API routes
sg run -p "export async function $METHOD($REQ, $RES)" -l typescript
```

### Prepare for Refactoring

```bash
# 1. Find all instances of pattern to change
sg run -p "oldFunction($$$)" -l typescript --json > matches.json

# 2. Count scope
cat matches.json | jq length

# 3. Review unique variations
cat matches.json | jq -r '.[].text' | sort -u

# 4. Test replacement on one file
sg run -p "oldFunction($ARGS)" -r "newFunction($ARGS)" -l typescript path/to/one/file.ts --debug-query

# 5. Apply to all
sg run -p "oldFunction($ARGS)" -r "newFunction($ARGS)" -l typescript
```

### Find Dead Code Candidates

```bash
# Find exported functions
sg run -p "export function $NAME($$$)" -l typescript --json | jq -r '.[].meta.NAME.text' | sort > exports.txt

# Find function calls (rough)
sg run -p "$NAME($$$)" -l typescript --json | jq -r '.[].meta.NAME.text' | sort -u > calls.txt

# Compare (manual review needed)
comm -23 exports.txt calls.txt
```

## Interactive Mode

For exploratory refactoring with review:

```bash
# Interactive mode - confirm each change
sg run -p "console.log($MSG)" -r "logger.info($MSG)" -l typescript -i
```

This prompts before each replacement, useful for:
- Learning what matches
- Selective application
- Verifying pattern accuracy
