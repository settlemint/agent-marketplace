# TypeScript/TSX Patterns for ast-grep

## Function Patterns

```bash
# Named functions
sg -p "function $NAME($$$PARAMS) { $$$BODY }" -l typescript
sg -p "async function $NAME($$$PARAMS) { $$$BODY }" -l typescript

# Arrow functions
sg -p "const $NAME = ($$$PARAMS) => $BODY" -l typescript
sg -p "const $NAME = async ($$$PARAMS) => $BODY" -l typescript
sg -p "const $NAME = ($$$PARAMS): $RETURN => $BODY" -l typescript

# Method definitions
sg -p "$NAME($$$PARAMS) { $$$BODY }" -l typescript
sg -p "async $NAME($$$PARAMS) { $$$BODY }" -l typescript

# Exported functions
sg -p "export function $NAME($$$PARAMS) { $$$BODY }" -l typescript
sg -p "export const $NAME = ($$$PARAMS) => $BODY" -l typescript
```

## Import Patterns

```bash
# Named imports
sg -p 'import { $$$IMPORTS } from "$MODULE"' -l typescript
sg -p 'import { $NAME } from "$MODULE"' -l typescript

# Default imports
sg -p 'import $DEFAULT from "$MODULE"' -l typescript

# Namespace imports
sg -p 'import * as $NAMESPACE from "$MODULE"' -l typescript

# Side-effect imports
sg -p 'import "$MODULE"' -l typescript

# Combined
sg -p 'import $DEFAULT, { $$$NAMED } from "$MODULE"' -l typescript

# Type imports
sg -p 'import type { $$$TYPES } from "$MODULE"' -l typescript
```

## React Patterns (TSX)

```bash
# Hooks
sg -p "use$HOOK($$$ARGS)" -l tsx
sg -p "useState($INITIAL)" -l tsx
sg -p "useEffect($$$ARGS)" -l tsx
sg -p "useMemo($$$ARGS)" -l tsx
sg -p "useCallback($$$ARGS)" -l tsx
sg -p "useRef($INITIAL)" -l tsx

# Component definitions
sg -p "function $NAME($PROPS) { $$$BODY }" -l tsx
sg -p "const $NAME = ($PROPS) => { $$$BODY }" -l tsx
sg -p "const $NAME: React.FC<$PROPS> = ($$$ARGS) => $BODY" -l tsx

# JSX elements
sg -p "<$COMPONENT $$$PROPS />" -l tsx
sg -p "<$COMPONENT $$$PROPS>$$$CHILDREN</$COMPONENT>" -l tsx
sg -p "<$COMPONENT $ATTR={$VALUE} />" -l tsx

# Event handlers
sg -p "on$EVENT={$HANDLER}" -l tsx
sg -p "onClick={$HANDLER}" -l tsx
sg -p "onChange={$HANDLER}" -l tsx
```

## Type Patterns

```bash
# Interfaces
sg -p "interface $NAME { $$$BODY }" -l typescript
sg -p "interface $NAME extends $PARENT { $$$BODY }" -l typescript
sg -p "export interface $NAME { $$$BODY }" -l typescript

# Type aliases
sg -p "type $NAME = $TYPE" -l typescript
sg -p "type $NAME<$$$PARAMS> = $TYPE" -l typescript
sg -p "export type $NAME = $TYPE" -l typescript

# Generics
sg -p "$NAME<$$$TYPES>" -l typescript
sg -p "Array<$TYPE>" -l typescript
sg -p "Promise<$TYPE>" -l typescript
sg -p "Record<$KEY, $VALUE>" -l typescript
```

## Common Refactoring Patterns

### Remove console.log

```bash
# Find all
sg -p "console.log($$$)" -l typescript

# Remove all
sg -p "console.log($$$)" -r "" -l typescript

# Replace with logger
sg -p "console.log($MSG)" -r "logger.info($MSG)" -l typescript
sg -p "console.error($MSG)" -r "logger.error($MSG)" -l typescript
```

### Modernize Syntax

```bash
# Optional chaining
sg -p '$A && $A.$B' -r '$A?.$B' -l typescript
sg -p '$A && $A()' -r '$A?.()' -l typescript

# Nullish coalescing
sg -p '$A !== null && $A !== undefined ? $A : $B' -r '$A ?? $B' -l typescript
sg -p '$A || $B' -r '$A ?? $B' -l typescript  # Be careful: different semantics!

# Object shorthand
sg -p '{ $KEY: $KEY }' -r '{ $KEY }' -l typescript
```

### React Migrations

```bash
# Class to function component (manual assist)
sg -p "class $NAME extends React.Component<$PROPS>" -l tsx

# Legacy context to hooks
sg -p "static contextType = $CONTEXT" -l tsx

# PropTypes to TypeScript
sg -p "$NAME.propTypes = $$$" -l tsx
```

### Import Reorganization

```bash
# Find duplicate imports
sg -p 'import { $$$A } from "$MOD"' -l typescript --json | jq -r '.[] | .file + ":" + .meta.MOD.text' | sort | uniq -d

# Find unused type imports (needs verification)
sg -p 'import type { $TYPE } from "$MOD"' -l typescript
```

## Async Patterns

```bash
# Find async/await
sg -p "async function $NAME($$$)" -l typescript
sg -p "await $EXPR" -l typescript

# Find Promise usage
sg -p "new Promise($$$)" -l typescript
sg -p "$EXPR.then($$$)" -l typescript
sg -p "$EXPR.catch($$$)" -l typescript
sg -p "Promise.all($$$)" -l typescript
sg -p "Promise.allSettled($$$)" -l typescript

# Convert then to await (complex - needs context)
# Better to do manually with ast-grep assist
```

## Error Handling Patterns

```bash
# Try-catch blocks
sg -p "try { $$$TRY } catch ($ERR) { $$$CATCH }" -l typescript

# Empty catch blocks (anti-pattern)
sg -p "try { $$$TRY } catch ($ERR) { }" -l typescript

# Error throwing
sg -p "throw new Error($MSG)" -l typescript
sg -p "throw new $TYPE($$$ARGS)" -l typescript
```

## Class Patterns

```bash
# Class definitions
sg -p "class $NAME { $$$BODY }" -l typescript
sg -p "class $NAME extends $PARENT { $$$BODY }" -l typescript
sg -p "class $NAME implements $INTERFACE { $$$BODY }" -l typescript

# Constructors
sg -p "constructor($$$PARAMS) { $$$BODY }" -l typescript

# Methods
sg -p "public $METHOD($$$PARAMS) { $$$BODY }" -l typescript
sg -p "private $METHOD($$$PARAMS) { $$$BODY }" -l typescript
sg -p "static $METHOD($$$PARAMS) { $$$BODY }" -l typescript
```

## Testing Patterns

```bash
# Test blocks
sg -p 'describe("$DESC", $$$)' -l typescript
sg -p 'it("$DESC", $$$)' -l typescript
sg -p 'test("$DESC", $$$)' -l typescript

# Skipped/focused tests (find for removal)
sg -p 'describe.skip($$$)' -l typescript
sg -p 'describe.only($$$)' -l typescript
sg -p 'it.skip($$$)' -l typescript
sg -p 'it.only($$$)' -l typescript
sg -p 'test.skip($$$)' -l typescript
sg -p 'test.only($$$)' -l typescript

# Assertions
sg -p 'expect($ACTUAL).toBe($EXPECTED)' -l typescript
sg -p 'expect($ACTUAL).toEqual($EXPECTED)' -l typescript
```
