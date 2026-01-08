---
description: TypeScript code standards and best practices
globs: "**/*.ts,**/*.tsx"
alwaysApply: false
---

# TypeScript Standards

## Type Safety

### Prefer Explicit Types

```typescript
// GOOD - explicit return type
function getUser(id: string): User | undefined {
  return users.get(id);
}

// AVOID - implicit any
function getUser(id) {
  return users.get(id);
}
```

### Use Type-Only Imports

```typescript
// GOOD
import type { User } from "./types";
import { createUser } from "./users";

// AVOID
import { User, createUser } from "./users";
```

### Prefer `unknown` Over `any`

```typescript
// GOOD
function parse(input: unknown): Result {
  if (typeof input === "string") {
    return parseString(input);
  }
  throw new Error("Invalid input");
}

// AVOID
function parse(input: any): Result {
  return parseString(input);
}
```

## Null Handling

### Use Optional Chaining

```typescript
// GOOD
const name = user?.profile?.name;

// AVOID
const name = user && user.profile && user.profile.name;
```

### Use Nullish Coalescing

```typescript
// GOOD
const value = input ?? defaultValue;

// AVOID - falsy values treated differently
const value = input || defaultValue;
```

## Error Handling

### Type Narrowing for Errors

```typescript
try {
  await riskyOperation();
} catch (error) {
  if (error instanceof CustomError) {
    handleCustomError(error);
  } else if (error instanceof Error) {
    handleGenericError(error);
  } else {
    handleUnknownError(error);
  }
}
```

## Generics

### Constrain Generic Types

```typescript
// GOOD - constrained
function merge<T extends object>(a: T, b: Partial<T>): T {
  return { ...a, ...b };
}

// AVOID - unconstrained
function merge<T>(a: T, b: T): T {
  return { ...a, ...b };
}
```

## Enums vs Union Types

### Prefer Union Types

```typescript
// GOOD - union type
type Status = "pending" | "active" | "completed";

// AVOID - enum (unless numeric values needed)
enum Status {
  Pending,
  Active,
  Completed,
}
```

## Strict Mode

Enable all strict options in `tsconfig.json`:

```json
{
  "compilerOptions": {
    "strict": true,
    "noUncheckedIndexedAccess": true,
    "exactOptionalPropertyTypes": true
  }
}
```
