---
name: error-handling
description: Fail-fast error handling - surface errors immediately, no silent failures or workarounds
globs: "**/*.{ts,tsx,js,jsx,go,rs,py}"
alwaysApply: false
---

# Fail-Fast Error Handling

> "Fail fast, fail loud."

- **Errors should surface immediately**, not be hidden
- **Workarounds are technical debt** - fix the root cause
- **Fallbacks hide bugs** - they make debugging harder
- **Explicit failures are better** than silent corruption

## Patterns to Avoid

### Silent Error Swallowing

```typescript
// Bad: swallowing errors
try {
  riskyOperation();
} catch (e) {
  // silently ignored
}

// Bad: logging without re-throwing
try {
  riskyOperation();
} catch (e) {
  console.log("something went wrong");  // no rethrow, no details
}

// Good: fail fast or handle explicitly
try {
  riskyOperation();
} catch (e) {
  logger.error("Operation failed", { error: e, context });
  throw e;  // or return Result.error(e)
}
```

### Defensive Fallbacks

```go
// Bad: fallback hides the real problem
func GetConfig() Config {
    cfg, err := loadConfig()
    if err != nil {
        return DefaultConfig{}  // hides that config failed to load!
    }
    return cfg
}

// Good: fail explicitly
func GetConfig() (Config, error) {
    cfg, err := loadConfig()
    if err != nil {
        return Config{}, fmt.Errorf("failed to load config: %w", err)
    }
    return cfg, nil
}
```

### Workarounds / Hacks

```rust
// Bad: workaround instead of fix
fn process(data: &Data) -> Result<Output> {
    // HACK: sometimes data.id is empty, just skip it
    if data.id.is_empty() {
        return Ok(Output::default());  // hiding the bug!
    }
    // ...
}

// Good: fail on invalid state
fn process(data: &Data) -> Result<Output> {
    if data.id.is_empty() {
        return Err(Error::InvalidData("id cannot be empty"));
    }
    // ...
}
```

### Null Coalescing That Hides Bugs

```typescript
// Bad: hiding missing data
const userName = user?.name ?? "Unknown";  // why is user null?

// Bad: optional chaining everywhere
const city = user?.address?.city ?? "N/A";  // masks data issues

// Good: fail if data should exist
if (!user) {
  throw new Error(`User not found: ${userId}`);
}
const userName = user.name;
```

### Catch-All Exception Handlers

```go
// Bad: catch-all that swallows
defer func() {
    if r := recover(); r != nil {
        log.Println("recovered from panic")  // swallowed!
    }
}()
```

```typescript
// Bad: Pokemon exception handling
try {
    everything();
} catch (e) {
    return null;  // hides ALL errors
}
```

### Retry Without Limits

```typescript
// Bad: infinite retry hides persistent failures
async function fetchWithRetry(url: string) {
  while (true) {
    try {
      return await fetch(url);
    } catch {
      await sleep(1000);  // retry forever
    }
  }
}

// Good: bounded retry, then fail
async function fetchWithRetry(url: string, maxAttempts = 3) {
  for (let i = 0; i < maxAttempts; i++) {
    try {
      return await fetch(url);
    } catch (e) {
      if (i === maxAttempts - 1) throw e;
      await sleep(1000 * (i + 1));
    }
  }
}
```

### Default Values That Hide Failures

```rust
// Bad: unwrap_or hides failures
let count = parse_count(input).unwrap_or(0);  // why did parsing fail?

// Good: propagate the error
let count = parse_count(input)?;

// Acceptable: explicit default with logging
let count = parse_count(input).unwrap_or_else(|e| {
    warn!("Failed to parse count: {}, using default", e);
    0
});
```

## Code Smells to Flag

| Smell | Why It's Bad |
|-------|--------------|
| Empty catch blocks | Errors vanish |
| `catch (e) { return null; }` | Masks all failures |
| `?? defaultValue` everywhere | Hides missing data |
| `unwrap_or(default)` without logging | Silent fallback |
| `// HACK:` or `// WORKAROUND:` comments | Admitted technical debt |
| `// TODO: fix this properly` | Unaddressed issues |
| Infinite retry loops | Never surfaces failures |
| `recover()` without re-panic | Swallows panics |

## Fail-Fast Checklist

When writing error handling:

1. **Is this error expected?** If not, don't catch it
2. **Am I hiding the root cause?** Fallbacks often do
3. **Will someone notice this failure?** If not, it's silent
4. **Is there a workaround comment?** Fix the root cause instead
5. **Is the retry bounded?** Infinite retries hide persistent failures
