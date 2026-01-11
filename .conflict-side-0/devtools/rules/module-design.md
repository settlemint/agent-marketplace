---
name: module-design
description: High cohesion, low coupling - design modules that do one thing well with minimal dependencies
globs: "**/*.{ts,tsx,js,jsx,go,rs,py}"
alwaysApply: false
---

# Module Design: High Cohesion, Low Coupling

## Definitions

- **Cohesion**: How closely related elements within a module are. High = does one thing well.
- **Coupling**: How dependent modules are on each other. Low = can change independently.

**Goal**: Maximize cohesion, minimize coupling.

## Coupling Types (Worst to Best)

### Content Coupling (Worst)

One module modifies internals of another.

```typescript
// Bad: directly accessing internal state
class OrderService {
  createOrder(userService: UserService, userId: string) {
    const user = userService.users.find(u => u.id === userId); // Accessing internals!
  }
}
```

### Common Coupling

Modules share global data.

```go
// Bad: shared global state
var AppConfig Config

func ServiceA() { /* uses AppConfig */ }
func ServiceB() { /* uses AppConfig */ }
```

### Stamp Coupling

Passing whole objects when only parts needed.

```typescript
// Bad: passing whole User when only name needed
function greet(user: User) { return `Hello, ${user.name}`; }

// Better: pass only what's needed
function greet(name: string) { return `Hello, ${name}`; }
```

### Data Coupling (Best)

Modules share only necessary primitive data.

```go
func CalculateDiscount(price float64, percentage float64) float64 {
    return price * (percentage / 100)
}
```

## Cohesion Types (Worst to Best)

### Coincidental Cohesion (Worst)

Unrelated functionality grouped together.

```typescript
// Bad: unrelated utilities
class Utils {
  formatDate(d: Date): string { }
  calculateTax(amount: number): number { }
  sendEmail(to: string): void { }
}
```

### Functional Cohesion (Best)

Every element contributes to a single well-defined task.

```typescript
// Good: single responsibility
class PasswordHasher {
  hash(password: string): string { }
  verify(password: string, hash: string): boolean { }
  needsRehash(hash: string): boolean { }
}
```

## Dependency Direction

Dependencies should point toward stability and abstraction.

```
Unstable (changes often)  →  Stable (rarely changes)
Concrete (implementation) →  Abstract (interfaces)
```

### Dependency Inversion

```go
// Bad: high-level depends on low-level
type OrderService struct {
    db *PostgresDB  // concrete dependency
}

// Good: depend on abstraction
type OrderRepository interface {
    Save(order Order) error
    Find(id string) (Order, error)
}

type OrderService struct {
    repo OrderRepository  // abstract dependency
}
```

## Module Boundary Patterns

### Facade Pattern

Hide internal complexity behind a simple interface.

```typescript
class PaymentFacade {
  constructor(
    private validator: PaymentValidator,
    private processor: PaymentProcessor,
    private notifier: PaymentNotifier
  ) {}

  async processPayment(payment: Payment): Promise<Receipt> {
    await this.validator.validate(payment);
    const result = await this.processor.process(payment);
    await this.notifier.notify(result);
    return result.receipt;
  }
}
```

### Anti-Corruption Layer

Translate between bounded contexts.

```go
type LegacyUserAdapter struct {
    legacy *LegacyUserSystem
}

func (a *LegacyUserAdapter) GetUser(id string) (User, error) {
    legacyUser := a.legacy.FetchUser(id)
    return translateToModernUser(legacyUser), nil
}
```

## Coupling Checklist

Before finalizing module design, check:

1. **Import graph**: Can you draw a clean dependency diagram?
2. **Change impact**: If module A changes, how many others are affected?
3. **Test isolation**: Can you test a module without its dependencies?
4. **Interface size**: Are interfaces minimal (ISP)?
5. **Circular dependencies**: Any A → B → A cycles?

## Decoupling Strategies

1. **Dependency injection**: Pass dependencies, don't create them
2. **Events/Messages**: Communicate via events, not direct calls
3. **Interfaces**: Depend on contracts, not implementations
4. **Data transfer objects**: Copy data at boundaries
5. **Configuration**: Externalize environment-specific values
