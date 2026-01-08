---
name: srp
description: Single Responsibility Principle - each module/function should have one reason to change
globs: "**/*.{ts,tsx,js,jsx,go,rs,py}"
alwaysApply: false
---

# Single Responsibility Principle (SRP)

> "A module should have one, and only one, reason to change."
> — Robert C. Martin

**Key insight**: "Reason to change" = "actor" or "stakeholder". A module should serve one stakeholder.

## What is a Responsibility?

A responsibility is a reason for change. Ask: "Who would request changes to this code?"

- **UI team** requests display changes
- **Business team** requests logic changes
- **DBA** requests persistence changes
- **Security team** requests auth changes

If multiple teams could request changes, the module has multiple responsibilities.

## SRP at Function Level

```go
// Bad: multiple responsibilities
func ProcessOrder(order Order) error {
    if order.Total <= 0 { return errors.New("invalid total") }  // Validation
    if order.HasCoupon { order.Total *= 0.9 }                   // Discount
    return db.Save(order)                                        // Persistence
}

// Good: single responsibility per function
func ValidateOrder(order Order) error {
    if order.Total <= 0 { return errors.New("invalid total") }
    return nil
}

func ApplyDiscount(order Order) Order {
    if order.HasCoupon {
        return Order{...order, Total: order.Total * 0.9}
    }
    return order
}

func SaveOrder(order Order) error {
    return db.Save(order)
}
```

## SRP at Class/Module Level

### God Class (Violation)

```typescript
// Bad: does everything
class UserManager {
  // Authentication (Security team)
  login(email: string, password: string): User { }
  logout(user: User): void { }

  // Profile (Product team)
  updateProfile(user: User, data: ProfileData): void { }

  // Persistence (DBA)
  saveUser(user: User): void { }
  loadUser(id: string): User { }

  // Notifications (Marketing team)
  sendWelcomeEmail(user: User): void { }
}
```

### Separated Responsibilities (Correct)

```typescript
class AuthService {
  login(email: string, password: string): User { }
  logout(user: User): void { }
}

class ProfileService {
  updateProfile(user: User, data: ProfileData): void { }
}

class UserRepository {
  save(user: User): void { }
  load(id: string): User { }
}

class UserNotifications {
  sendWelcomeEmail(user: User): void { }
}
```

## Mixed Abstraction Levels (Violation)

```go
// Bad: HTTP handling + business logic + persistence
func HandleCreateOrder(w http.ResponseWriter, r *http.Request) {
    var req OrderRequest
    json.NewDecoder(r.Body).Decode(&req)        // HTTP parsing

    order := Order{                              // Business logic
        Items: req.Items,
        Total: calculateTotal(req.Items),
    }

    db.Save(&order)                              // Persistence

    json.NewEncoder(w).Encode(order)             // HTTP response
}

// Good: separated layers
func HandleCreateOrder(w http.ResponseWriter, r *http.Request) {
    req, err := decodeOrderRequest(r)            // HTTP layer
    if err != nil { writeError(w, err); return }

    order, err := orderService.Create(req)       // Business layer
    if err != nil { writeError(w, err); return }

    writeJSON(w, order)                          // HTTP layer
}
```

## Signs of SRP Violations

1. **Class/module is hard to name** - ends up as "Manager", "Handler", "Utils"
2. **Many imports** from different domains
3. **Changes for different reasons** affect same file
4. **Large test files** with unrelated test cases
5. **God objects** that everything depends on

## SRP Checklist

When writing or reviewing code:

1. **Name test**: Can you name it with a single noun? (Not "XManager" or "XHandler")
2. **Stakeholder test**: Who would request changes? Should be one answer.
3. **Change test**: What could change? All changes should be related.
4. **Import test**: Are imports from one domain or many?
5. **Description test**: Can you describe it without "and"?

## Refactoring for SRP

When you find a violation:

1. Identify the distinct responsibilities
2. Create separate modules/classes for each
3. Use dependency injection to compose them
4. Create a facade if needed for simple external interface
