---
description: TypeScript code standards and best practices
globs: "**/*.ts,**/*.tsx,tsconfig.json,tsconfig.*.json"
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

## Type Strictness

### Avoid `any` Entirely

```typescript
// BAD: defeats the type system
function process(data: any): any {
  return data.foo.bar;  // No safety
}

// GOOD: use unknown and narrow
function process(data: unknown): string {
  if (isValidData(data)) {
    return data.foo.bar;
  }
  throw new Error('Invalid data');
}
```

### Use Discriminated Unions

```typescript
// BAD: optional fields create ambiguity
interface ApiResponse {
  success?: boolean;
  data?: User;
  error?: string;
}

// GOOD: discriminated union makes states explicit
type ApiResponse =
  | { status: 'success'; data: User }
  | { status: 'error'; error: string }
  | { status: 'loading' };

function handle(response: ApiResponse) {
  switch (response.status) {
    case 'success': return response.data;  // data is available
    case 'error': throw new Error(response.error);  // error is available
  }
}
```

### Use Branded Types for Domain Concepts

```typescript
// BAD: stringly typed - can swap IDs
function getUser(id: string): User { }
function getOrder(id: string): Order { }
getUser(orderId);  // No error, but wrong!

// GOOD: branded types prevent mixing
type UserId = string & { readonly __brand: 'UserId' };
type OrderId = string & { readonly __brand: 'OrderId' };

function userId(id: string): UserId { return id as UserId; }
function orderId(id: string): OrderId { return id as OrderId; }

function getUser(id: UserId): User { }
function getOrder(id: OrderId): Order { }
getUser(orderId('123'));  // Type error!
```

### Explicit Nullability

```typescript
// BAD: implicit null handling
function findUser(id: string): User {
  // might return undefined, but type says User
}

// GOOD: explicit nullability
function findUser(id: string): User | undefined {
  // Return type is honest
}
```

### Const Assertions for Literals

```typescript
// Without const: mutable, wide types
const config = {
  env: 'production',  // type: string
  ports: [8080, 8081]  // type: number[]
};

// With const: immutable, narrow types
const config = {
  env: 'production',
  ports: [8080, 8081]
} as const;
// env: 'production' (literal)
// ports: readonly [8080, 8081] (tuple)
```

## Type Strictness Checklist

1. **No `any`**: Use `unknown` and narrow, or proper types
2. **Domain types**: Business concepts have their own types (branded)
3. **Explicit nullability**: Nullable values are in the type signature
4. **Discriminated unions**: Use sum types over optional fields
5. **Const correctness**: Use `as const` and `readonly` where appropriate

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
