# TypeScript ast-grep Patterns

Comprehensive pattern reference for TypeScript and TSX files.

**Language flags:** `-l typescript` for `.ts`, `-l tsx` for `.tsx`

## Functions

### Function Declarations

```bash
# Named functions
sg -p "function $NAME($$$PARAMS) { $$$BODY }" -l typescript
sg -p "async function $NAME($$$PARAMS) { $$$BODY }" -l typescript
sg -p "function* $NAME($$$PARAMS) { $$$BODY }" -l typescript  # Generators

# Exported functions
sg -p "export function $NAME($$$PARAMS) { $$$BODY }" -l typescript
sg -p "export async function $NAME($$$PARAMS) { $$$BODY }" -l typescript
sg -p "export default function $NAME($$$PARAMS) { $$$BODY }" -l typescript
```

### Arrow Functions

```bash
# Basic arrow functions
sg -p "const $NAME = ($$$PARAMS) => $BODY" -l typescript
sg -p "const $NAME = async ($$$PARAMS) => $BODY" -l typescript
sg -p "const $NAME = ($$$PARAMS) => { $$$BODY }" -l typescript

# With type annotations
sg -p "const $NAME: $TYPE = ($$$PARAMS) => $BODY" -l typescript
sg -p "const $NAME = ($$$PARAMS): $RETURN => $BODY" -l typescript

# Single parameter (no parens)
sg -p "const $NAME = $PARAM => $BODY" -l typescript
```

### Methods

```bash
# Class methods
sg -p "$NAME($$$PARAMS) { $$$BODY }" -l typescript
sg -p "async $NAME($$$PARAMS) { $$$BODY }" -l typescript
sg -p "static $NAME($$$PARAMS) { $$$BODY }" -l typescript
sg -p "private $NAME($$$PARAMS) { $$$BODY }" -l typescript

# Object methods
sg -p "$NAME($$$PARAMS) { $$$BODY }" -l typescript
sg -p "$NAME: function($$$PARAMS) { $$$BODY }" -l typescript
sg -p "$NAME: ($$$PARAMS) => $BODY" -l typescript
```

### Function Calls

```bash
# Basic calls
sg -p "$FUNC($$$ARGS)" -l typescript
sg -p "$OBJ.$METHOD($$$ARGS)" -l typescript
sg -p "await $FUNC($$$ARGS)" -l typescript

# Chained calls
sg -p "$_.$METHOD1($$$).$METHOD2($$$)" -l typescript
sg -p "$_.then($CALLBACK)" -l typescript
sg -p "$_.catch($CALLBACK)" -l typescript
```

## Imports

### Named Imports

```bash
# Single import
sg -p 'import { $NAME } from "$MODULE"' -l typescript

# Multiple imports
sg -p 'import { $$$IMPORTS } from "$MODULE"' -l typescript

# Aliased import
sg -p 'import { $NAME as $ALIAS } from "$MODULE"' -l typescript

# Mixed with default
sg -p 'import $DEFAULT, { $$$NAMED } from "$MODULE"' -l typescript
```

### Default Imports

```bash
sg -p 'import $NAME from "$MODULE"' -l typescript
sg -p 'import $DEFAULT, { $$$NAMED } from "$MODULE"' -l typescript
```

### Namespace Imports

```bash
sg -p 'import * as $NAMESPACE from "$MODULE"' -l typescript
```

### Dynamic Imports

```bash
sg -p 'import("$MODULE")' -l typescript
sg -p 'await import("$MODULE")' -l typescript
sg -p 'const $VAR = await import("$MODULE")' -l typescript
```

### Type-only Imports

```bash
sg -p 'import type { $$$TYPES } from "$MODULE"' -l typescript
sg -p 'import type $TYPE from "$MODULE"' -l typescript
sg -p 'import { type $TYPE } from "$MODULE"' -l typescript
```

### Require (CommonJS)

```bash
sg -p 'const $VAR = require("$MODULE")' -l typescript
sg -p 'const { $$$IMPORTS } = require("$MODULE")' -l typescript
sg -p 'require("$MODULE")' -l typescript
```

### Import Refactoring

```bash
# Remove specific import
sg -p 'import { $NAME } from "old-module"' -r '' -l typescript

# Rename module
sg -p 'import { $$$X } from "old-module"' -r 'import { $$$X } from "new-module"' -l typescript

# Add type to import
sg -p 'import { $NAME } from "$MODULE"' -r 'import type { $NAME } from "$MODULE"' -l typescript
```

## Exports

```bash
# Named exports
sg -p "export const $NAME = $VALUE" -l typescript
sg -p "export function $NAME($$$) { $$$BODY }" -l typescript
sg -p "export class $NAME { $$$BODY }" -l typescript
sg -p "export interface $NAME { $$$BODY }" -l typescript
sg -p "export type $NAME = $TYPE" -l typescript

# Default exports
sg -p "export default $EXPR" -l typescript
sg -p "export default function $NAME($$$) { $$$BODY }" -l typescript
sg -p "export default class $NAME { $$$BODY }" -l typescript

# Re-exports
sg -p 'export { $$$EXPORTS } from "$MODULE"' -l typescript
sg -p 'export * from "$MODULE"' -l typescript
sg -p 'export * as $NAMESPACE from "$MODULE"' -l typescript
```

## React & JSX

### Components

```bash
# Function components
sg -p "function $COMPONENT($PROPS) { $$$BODY return $JSX }" -l tsx
sg -p "const $COMPONENT = ($PROPS) => { $$$BODY return $JSX }" -l tsx
sg -p "const $COMPONENT = ($PROPS) => $JSX" -l tsx
sg -p "const $COMPONENT: React.FC<$PROPS> = ($$$) => $JSX" -l tsx

# Class components
sg -p "class $COMPONENT extends React.Component { $$$BODY }" -l tsx
sg -p "class $COMPONENT extends Component { $$$BODY }" -l tsx
sg -p "class $COMPONENT extends React.PureComponent { $$$BODY }" -l tsx
```

### Hooks

```bash
# All hooks
sg -p "use$HOOK($$$ARGS)" -l tsx

# Specific hooks
sg -p "useState($INITIAL)" -l tsx
sg -p "useState<$TYPE>($INITIAL)" -l tsx
sg -p "useEffect($CALLBACK, [$$$DEPS])" -l tsx
sg -p "useEffect($CALLBACK)" -l tsx
sg -p "useCallback($CALLBACK, [$$$DEPS])" -l tsx
sg -p "useMemo($FACTORY, [$$$DEPS])" -l tsx
sg -p "useRef($INITIAL)" -l tsx
sg -p "useRef<$TYPE>($INITIAL)" -l tsx
sg -p "useContext($CONTEXT)" -l tsx
sg -p "useReducer($REDUCER, $INITIAL)" -l tsx

# Custom hooks
sg -p "function use$NAME($$$PARAMS) { $$$BODY }" -l tsx
sg -p "const use$NAME = ($$$PARAMS) => { $$$BODY }" -l tsx
```

### JSX Elements

```bash
# Self-closing
sg -p "<$COMPONENT />" -l tsx
sg -p "<$COMPONENT $$$PROPS />" -l tsx

# With children
sg -p "<$COMPONENT>$$$CHILDREN</$COMPONENT>" -l tsx
sg -p "<$COMPONENT $$$PROPS>$$$CHILDREN</$COMPONENT>" -l tsx

# Specific props
sg -p '<$_ className="$CLASS" $$$>' -l tsx
sg -p "<$_ onClick={$HANDLER} $$$>" -l tsx
sg -p "<$_ key={$KEY} $$$>" -l tsx
sg -p "<$_ ref={$REF} $$$>" -l tsx

# Fragments
sg -p "<>$$$CHILDREN</>" -l tsx
sg -p "<React.Fragment>$$$CHILDREN</React.Fragment>" -l tsx
```

### Event Handlers

```bash
sg -p "onClick={$HANDLER}" -l tsx
sg -p "onChange={$HANDLER}" -l tsx
sg -p "onSubmit={$HANDLER}" -l tsx
sg -p "on$EVENT={$HANDLER}" -l tsx

# Inline handlers
sg -p "onClick={() => $BODY}" -l tsx
sg -p "onClick={(e) => $BODY}" -l tsx
```

## Types & Interfaces

### Type Aliases

```bash
sg -p "type $NAME = $TYPE" -l typescript
sg -p "type $NAME<$$$PARAMS> = $TYPE" -l typescript
sg -p "export type $NAME = $TYPE" -l typescript

# Union types
sg -p "type $NAME = $A | $B" -l typescript

# Intersection types
sg -p "type $NAME = $A & $B" -l typescript

# Mapped types
sg -p "type $NAME = { [$KEY in $KEYS]: $VALUE }" -l typescript
```

### Interfaces

```bash
sg -p "interface $NAME { $$$BODY }" -l typescript
sg -p "interface $NAME extends $BASE { $$$BODY }" -l typescript
sg -p "export interface $NAME { $$$BODY }" -l typescript
sg -p "interface $NAME<$$$PARAMS> { $$$BODY }" -l typescript
```

### Type Annotations

```bash
# Variable annotations
sg -p "const $NAME: $TYPE = $VALUE" -l typescript
sg -p "let $NAME: $TYPE" -l typescript

# Parameter annotations
sg -p "($NAME: $TYPE)" -l typescript

# Return type annotations
sg -p "function $NAME($$$): $RETURN { $$$BODY }" -l typescript
sg -p "($$$): $RETURN => $BODY" -l typescript

# Type assertions
sg -p "$EXPR as $TYPE" -l typescript
sg -p "<$TYPE>$EXPR" -l typescript

# Non-null assertion
sg -p "$EXPR!" -l typescript
```

### Generics

```bash
sg -p "$NAME<$$$PARAMS>" -l typescript
sg -p "function $NAME<$T>($$$): $RETURN { $$$BODY }" -l typescript
sg -p "class $NAME<$T> { $$$BODY }" -l typescript
sg -p "interface $NAME<$T> { $$$BODY }" -l typescript

# With constraints
sg -p "<$T extends $CONSTRAINT>" -l typescript
sg -p "<$T extends $A, $U extends $B>" -l typescript
```

## Classes

### Class Declarations

```bash
sg -p "class $NAME { $$$BODY }" -l typescript
sg -p "class $NAME extends $BASE { $$$BODY }" -l typescript
sg -p "class $NAME implements $INTERFACE { $$$BODY }" -l typescript
sg -p "abstract class $NAME { $$$BODY }" -l typescript
sg -p "export class $NAME { $$$BODY }" -l typescript
```

### Properties

```bash
sg -p "$NAME: $TYPE" -l typescript                     # Property signature
sg -p "$NAME: $TYPE = $VALUE" -l typescript            # With initializer
sg -p "private $NAME: $TYPE" -l typescript
sg -p "public $NAME: $TYPE" -l typescript
sg -p "protected $NAME: $TYPE" -l typescript
sg -p "readonly $NAME: $TYPE" -l typescript
sg -p "static $NAME: $TYPE" -l typescript
sg -p "#$NAME: $TYPE" -l typescript                    # Private field
```

### Constructors

```bash
sg -p "constructor($$$PARAMS) { $$$BODY }" -l typescript
sg -p "constructor(private $NAME: $TYPE) { $$$BODY }" -l typescript
sg -p "constructor(public $NAME: $TYPE) { $$$BODY }" -l typescript
```

### Decorators

```bash
sg -p "@$DECORATOR" -l typescript
sg -p "@$DECORATOR($$$ARGS)" -l typescript
sg -p "@$DECORATOR class $NAME { $$$BODY }" -l typescript
sg -p "@$DECORATOR $METHOD($$$) { $$$BODY }" -l typescript
```

## Variables & Assignments

```bash
# Declarations
sg -p "const $NAME = $VALUE" -l typescript
sg -p "let $NAME = $VALUE" -l typescript
sg -p "var $NAME = $VALUE" -l typescript

# Destructuring
sg -p "const { $$$PROPS } = $OBJ" -l typescript
sg -p "const [$$$ITEMS] = $ARRAY" -l typescript
sg -p "const { $NAME: $ALIAS } = $OBJ" -l typescript
sg -p "const { $NAME = $DEFAULT } = $OBJ" -l typescript

# Assignments
sg -p "$VAR = $VALUE" -l typescript
sg -p "$VAR += $VALUE" -l typescript
sg -p "$VAR ||= $VALUE" -l typescript
sg -p "$VAR ??= $VALUE" -l typescript
```

## Control Flow

```bash
# Conditionals
sg -p "if ($COND) { $$$BODY }" -l typescript
sg -p "if ($COND) { $$$THEN } else { $$$ELSE }" -l typescript
sg -p "$COND ? $THEN : $ELSE" -l typescript

# Loops
sg -p "for ($INIT; $COND; $UPDATE) { $$$BODY }" -l typescript
sg -p "for (const $ITEM of $ITERABLE) { $$$BODY }" -l typescript
sg -p "for (const $KEY in $OBJ) { $$$BODY }" -l typescript
sg -p "while ($COND) { $$$BODY }" -l typescript
sg -p "$ARRAY.forEach($CALLBACK)" -l typescript

# Switch
sg -p "switch ($EXPR) { $$$CASES }" -l typescript

# Try/catch
sg -p "try { $$$TRY } catch ($E) { $$$CATCH }" -l typescript
sg -p "try { $$$TRY } finally { $$$FINALLY }" -l typescript
```

## Async/Await

```bash
sg -p "async function $NAME($$$) { $$$BODY }" -l typescript
sg -p "async ($$$) => $BODY" -l typescript
sg -p "await $EXPR" -l typescript
sg -p "await Promise.all([$$$PROMISES])" -l typescript
sg -p "await Promise.allSettled([$$$PROMISES])" -l typescript
sg -p "$PROMISE.then($CALLBACK)" -l typescript
sg -p "$PROMISE.catch($CALLBACK)" -l typescript
sg -p "new Promise(($RESOLVE, $REJECT) => $BODY)" -l typescript
```

## Common Refactoring Patterns

### Console Removal

```bash
# Remove all console statements
sg -p "console.log($$$)" -r "" -l typescript
sg -p "console.warn($$$)" -r "" -l typescript
sg -p "console.error($$$)" -r "" -l typescript
sg -p "console.$METHOD($$$)" -r "" -l typescript
```

### Optional Chaining

```bash
# Convert && to ?.
sg -p '$A && $A.$B' -r '$A?.$B' -l typescript
sg -p '$A && $A()' -r '$A?.()' -l typescript
sg -p '$A && $A[$B]' -r '$A?.[$B]' -l typescript
```

### Nullish Coalescing

```bash
# Convert || to ??
sg -p '$A || $DEFAULT' -r '$A ?? $DEFAULT' -l typescript
```

### Import Cleanup

```bash
# Remove unused imports (find first)
sg -p 'import { $NAME } from "$MODULE"' -l typescript

# Convert require to import
sg -p 'const $VAR = require("$MODULE")' -r 'import $VAR from "$MODULE"' -l typescript
sg -p 'const { $$$X } = require("$MODULE")' -r 'import { $$$X } from "$MODULE"' -l typescript
```

### API Migration

```bash
# Migrate from old API to new
sg -p 'oldFunction($ARGS)' -r 'newFunction($ARGS)' -l typescript
sg -p 'import { old } from "pkg"' -r 'import { new as old } from "pkg"' -l typescript

# Update method calls
sg -p '$OBJ.oldMethod($$$)' -r '$OBJ.newMethod($$$)' -l typescript
```

### React Patterns

```bash
# Convert class to function component (manual steps needed)
sg -p "class $NAME extends React.Component { $$$BODY }" -l tsx

# Update hook dependencies
sg -p "useEffect($CALLBACK, [])" -l tsx

# Convert to named export
sg -p "export default function $NAME($$$) { $$$BODY }" \
   -r "export function $NAME($$$) { $$$BODY }" -l tsx
```

## Zod Patterns

```bash
# Find schema definitions
sg -p "const $SCHEMA = z.$METHOD($$$)" -l typescript
sg -p "z.object({ $$$FIELDS })" -l typescript
sg -p "z.infer<typeof $SCHEMA>" -l typescript

# Find validation calls
sg -p "$SCHEMA.parse($DATA)" -l typescript
sg -p "$SCHEMA.safeParse($DATA)" -l typescript
```

## TanStack Patterns

```bash
# React Query
sg -p "useQuery($$$)" -l tsx
sg -p "useMutation($$$)" -l tsx
sg -p "useQueryClient()" -l tsx
sg -p "queryClient.invalidateQueries($$$)" -l typescript

# React Router
sg -p "useNavigate()" -l tsx
sg -p "useParams()" -l tsx
sg -p "useSearchParams()" -l tsx
sg -p "createFileRoute($PATH)" -l typescript

# React Form
sg -p "useForm($$$)" -l tsx
sg -p "useFormContext()" -l tsx

# React Table
sg -p "useReactTable($$$)" -l tsx
sg -p "getCoreRowModel()" -l tsx
```
