---
name: architecture
description: Functional Core, Imperative Shell - separate pure logic from I/O
globs: "**/*.{ts,tsx,js,jsx,go,rs,py}"
alwaysApply: false
---

# Functional Core, Imperative Shell (FCIS)

Structure code into two layers:

1. **Functional Core**: Pure functions with business logic. No I/O, no side effects.
2. **Imperative Shell**: Thin layer that handles I/O and orchestrates the core.

## Why FCIS

- **Testability**: Core logic testable without mocks
- **Predictability**: Pure functions return same output for same input
- **Composability**: Pure functions compose easily
- **Debuggability**: No hidden state changes

## The Pattern

```
┌─────────────────────────────────────┐
│         Imperative Shell            │
│  ┌─────────────────────────────┐    │
│  │     Functional Core         │    │
│  │   (pure business logic)     │    │
│  └─────────────────────────────┘    │
│         ↑           ↓               │
│    [Read I/O]   [Write I/O]         │
└─────────────────────────────────────┘
```

## Implementation

### TypeScript Example

```typescript
// CORE: Pure functions (no I/O)
type Order = { items: Array<{ price: number; qty: number }> };
type OrderResult =
  | { status: 'success'; total: number; tax: number }
  | { status: 'error'; reason: string };

function calculateOrder(order: Order): OrderResult {
  if (order.items.length === 0) {
    return { status: 'error', reason: 'Empty order' };
  }
  const subtotal = order.items.reduce((sum, i) => sum + i.price * i.qty, 0);
  const tax = subtotal * 0.1;
  return { status: 'success', total: subtotal + tax, tax };
}

// SHELL: I/O orchestration
async function processOrder(orderId: string): Promise<void> {
  const order = await db.findOrder(orderId);      // Input I/O
  const result = calculateOrder(order);            // Pure computation
  if (result.status === 'error') throw new Error(result.reason);
  await db.updateOrder(orderId, { total: result.total }); // Output I/O
}
```

### Go Example

```go
// CORE: Pure function
func DetermineLevel(score int) string {
    switch {
    case score > 100: return "gold"
    case score > 50:  return "silver"
    default:          return "bronze"
    }
}

// SHELL: I/O orchestration
func ProcessUser(db *sql.DB, userID string) error {
    user, err := fetchUser(db, userID)  // Input I/O
    if err != nil { return err }
    updated := UpdateUserLevel(user)     // Pure computation
    return saveUser(db, updated)         // Output I/O
}
```

## FCIS Checklist

1. **Identify I/O**: Database, network, filesystem, console, time, randomness
2. **Extract pure logic**: Move calculations to pure functions
3. **Return data, not effects**: Core returns new data, shell applies effects
4. **Push I/O to edges**: Shell does I/O → calls core → does more I/O
5. **Test the core**: Should be testable without any mocks

## Common Mistakes

### Logger in Core

```typescript
// Bad: I/O in core
function calculate(data: Data): number {
  logger.info('Calculating...');  // I/O!
  return data.a + data.b;
}

// Good: Return what would be logged
function calculate(data: Data): { result: number; events: string[] } {
  return { result: data.a + data.b, events: ['calculation_performed'] };
}
```

### Time/Random in Core

```typescript
// Bad: non-deterministic
function createOrder(items: Item[]): Order {
  return { id: uuid(), createdAt: new Date(), items };
}

// Good: inject non-determinism
function createOrder(items: Item[], id: string, createdAt: Date): Order {
  return { id, createdAt, items };
}
```

### Throwing in Core

```typescript
// Bad: exceptions are side effects
function divide(a: number, b: number): number {
  if (b === 0) throw new Error('Division by zero');
  return a / b;
}

// Good: return result type
function divide(a: number, b: number): { ok: true; value: number } | { ok: false; error: string } {
  if (b === 0) return { ok: false, error: 'Division by zero' };
  return { ok: true, value: a / b };
}
```
