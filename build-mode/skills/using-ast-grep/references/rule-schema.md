# YAML Rule Schema for ast-grep

Rules enable reusable linting and refactoring patterns with `sg scan`.

## Basic Rule Structure

```yaml
id: rule-identifier
language: typescript
rule:
  pattern: console.log($$$)
message: "Avoid console.log in production code"
severity: warning  # hint, info, warning, error
```

## Rule Configuration

### sgconfig.yml

Project configuration file:

```yaml
ruleDirs:
  - rules/
  - custom-rules/

testConfigs:
  - testDir: rules/__tests__/

utilities:
  - id: is-inside-function
    rule:
      inside:
        kind: function_declaration
```

### Running Rules

```bash
# Run all configured rules
sg scan -c sgconfig.yml

# Run specific rule file
sg scan -r rules/no-console.yml

# JSON output for CI
sg scan -c sgconfig.yml --json

# GitHub Actions format
sg scan -c sgconfig.yml --format github
```

## Pattern Matching

### Basic Pattern

```yaml
rule:
  pattern: console.log($$$)
```

### Kind Matching (AST Node Type)

```yaml
rule:
  kind: function_declaration
```

### Regex Matching

```yaml
rule:
  regex: "TODO|FIXME|HACK"
```

### Combined Matching

```yaml
rule:
  all:
    - pattern: $FUNC($$$)
    - kind: call_expression
```

## Relational Rules

### Inside (Parent Context)

```yaml
rule:
  pattern: console.log($$$)
  inside:
    kind: function_declaration
```

### Has (Child Content)

```yaml
rule:
  kind: function_declaration
  has:
    pattern: return $VALUE
```

### Follows/Precedes

```yaml
rule:
  pattern: $STMT
  follows:
    pattern: if ($COND) { $$$BODY }
```

### Not (Negation)

```yaml
rule:
  pattern: fetch($URL)
  not:
    inside:
      kind: try_statement
```

## Composite Rules

### All (AND)

```yaml
rule:
  all:
    - pattern: useState($INITIAL)
    - inside:
        kind: function_declaration
    - not:
        inside:
          pattern: use$HOOK
```

### Any (OR)

```yaml
rule:
  any:
    - pattern: console.log($$$)
    - pattern: console.warn($$$)
    - pattern: console.error($$$)
```

### Matches (Reference Utility)

```yaml
rule:
  pattern: $EXPR
  matches: is-inside-function
```

## Fix Patterns

### Simple Replacement

```yaml
fix: logger.info($MSG)
```

### Template with Captured Variables

```yaml
rule:
  pattern: console.log($MSG)
fix: |
  logger.info($MSG)
```

### Conditional Fixes

```yaml
rule:
  any:
    - pattern: console.log($MSG)
    - pattern: console.warn($MSG)
fix: logger.info($MSG)
```

## Constraints

### Regex Constraints on Captures

```yaml
rule:
  pattern: $FUNC($$$)
constraints:
  FUNC:
    regex: "^(get|fetch|load)"
```

### Kind Constraints

```yaml
rule:
  pattern: $EXPR.$METHOD($$$)
constraints:
  METHOD:
    kind: property_identifier
```

## Example Rules

### No Console in Production

```yaml
id: no-console
language: typescript
severity: warning
message: "Remove console.log before production"
rule:
  any:
    - pattern: console.log($$$)
    - pattern: console.warn($$$)
    - pattern: console.debug($$$)
  not:
    inside:
      any:
        - kind: catch_clause
        - pattern: if (process.env.NODE_ENV === 'development') { $$$ }
fix: ""
```

### Prefer Optional Chaining

```yaml
id: prefer-optional-chaining
language: typescript
severity: info
message: "Use optional chaining instead of && guard"
rule:
  pattern: $OBJ && $OBJ.$PROP
fix: $OBJ?.$PROP
```

### React Hook Dependencies

```yaml
id: useEffect-missing-deps
language: tsx
severity: warning
message: "useEffect without dependency array may cause infinite loops"
rule:
  pattern: useEffect($CALLBACK)
  not:
    has:
      kind: array
```

### No Empty Catch

```yaml
id: no-empty-catch
language: typescript
severity: error
message: "Empty catch block swallows errors silently"
rule:
  kind: catch_clause
  has:
    kind: statement_block
    not:
      has:
        any:
          - kind: expression_statement
          - kind: throw_statement
          - kind: return_statement
```

### Enforce Await in Async

```yaml
id: async-function-needs-await
language: typescript
severity: warning
message: "Async function without await is suspicious"
rule:
  kind: function_declaration
  has:
    kind: async
  not:
    has:
      kind: await_expression
```

## Testing Rules

### Test File Structure

```yaml
# rules/__tests__/no-console-test.yml
id: no-console
valid:
  - |
    // This is fine
    logger.info("message")
  - |
    if (process.env.NODE_ENV === 'development') {
      console.log("debug")
    }

invalid:
  - |
    console.log("bad")  # Should be flagged
  - |
    function test() {
      console.warn("also bad")
    }
```

### Running Tests

```bash
# Run all rule tests
sg test -c sgconfig.yml

# Update snapshots
sg test -c sgconfig.yml -U
```

## Best Practices

1. **Start simple** - Begin with basic pattern, add constraints as needed
2. **Test thoroughly** - Include edge cases in test files
3. **Document intent** - Use clear messages explaining why rule matters
4. **Appropriate severity** - error for bugs, warning for style, info for suggestions
5. **Minimal fixes** - Fix should change only what's necessary
6. **Consider context** - Use `inside`/`not` to avoid false positives
