---
name: simplicity
description: Rich Hickey's simplicity principles - prefer simple over easy, decomplect intertwined concerns
globs: "**/*.{ts,tsx,js,jsx,go,rs,py,sol}"
alwaysApply: false
---

# Simplicity Principles

Apply Rich Hickey's simplicity philosophy when writing code.

## Simple vs Easy

- **Simple**: Not intertwined. One role, one concept, one dimension.
- **Easy**: Familiar, convenient. Relative to the person.

Always prefer simple over easy. Easy now creates complexity later.

## Decomplection Checklist

Separate these concerns that are often complected:

| Complected | Decomplect To |
|------------|---------------|
| State + Identity | Immutable values + managed references |
| What + How | Declarative spec + implementation |
| What + When | Logic + scheduling/ordering |
| Behavior + Data | Plain data + functions on data |

## Patterns to Follow

### Values Over State

```typescript
// Complected: value tied to identity
class User {
  name: string;
  setName(n: string) { this.name = n; }
}

// Decomplected: immutable values
type User = { readonly name: string };
const rename = (user: User, name: string): User => ({ ...user, name });
```

### Functions Over Methods

```go
// Complected: behavior tied to struct
func (u *User) Validate() error { /* ... */ }

// Decomplected: function operates on data
func ValidateUser(u User) error { /* ... */ }
```

### Data Over Objects

Prefer plain structs/records over actor objects that mix data with behavior.

### Explicit Over Implicit

- No hidden dependencies (globals, singletons)
- Pass dependencies explicitly
- Return new data instead of mutating

### Composition Over Inheritance

Build complex behavior from small, composable functions.

## Self-Check Questions

Before finalizing code, ask:

1. Can I understand this in isolation? (no hidden dependencies)
2. Can I change this without fear? (no action at a distance)
3. Can I test this without mocks? (pure functions)
4. Can I reuse this elsewhere? (not tied to framework/context)
5. Is state mutation necessary? (prefer transformations)

## Complexity Smells

Avoid these patterns:

- Mutable state shared across functions
- Implicit dependencies (globals, singletons)
- Callbacks that modify external state
- Objects that are both data containers and actors
- Methods that do I/O and computation together
- Inheritance hierarchies for code reuse
