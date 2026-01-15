# ast-grep Rule Template

## Basic Rule

```yaml
id: { { RULE_ID } }
language: { { LANGUAGE } }
severity: { { SEVERITY } }
message: "{{MESSAGE}}"

rule:
  pattern: { { PATTERN } }

fix: { { FIX } }
```

## Parameters

| Parameter  | Required | Values                                 | Description                                |
| ---------- | -------- | -------------------------------------- | ------------------------------------------ |
| `id`       | Yes      | string                                 | Unique identifier (e.g., `no-console-log`) |
| `language` | Yes      | typescript, tsx, bash, hcl, yaml, etc. | Target language                            |
| `severity` | No       | hint, info, warning, error, off        | Issue severity (default: hint)             |
| `message`  | Yes      | string                                 | One-line explanation                       |
| `rule`     | Yes      | object                                 | Matching rule                              |
| `fix`      | No       | string                                 | Auto-fix pattern                           |

## Full Template

```yaml
id: { { RULE_ID } }
language: typescript
severity: warning
message: "{{BRIEF_DESCRIPTION}}"
note: |
  {{DETAILED_EXPLANATION}}

  **Why this is a problem:**
  - Reason 1
  - Reason 2

  **How to fix:**
  Use `{{REPLACEMENT}}` instead.
url: https://docs.example.com/rules/{{RULE_ID}}
rule:
  pattern: { { PATTERN } }

fix: { { FIX } }

files:
  - "src/**/*.ts"
  - "src/**/*.tsx"

ignores:
  - "**/*.test.ts"
  - "**/*.spec.ts"
  - "**/node_modules/**"

constraints:
  { { VAR } }:
    regex: "{{CONSTRAINT_PATTERN}}"
```

## Examples

### Simple Pattern Match

```yaml
id: no-console-log
language: typescript
severity: warning
message: "Remove console.log statements"

rule:
  pattern: console.log($$$ARGS)

fix: ""
```

### Pattern with Constraint

```yaml
id: no-hardcoded-secrets
language: typescript
severity: error
message: "Hardcoded secrets detected"

rule:
  pattern: const $VAR = "$VALUE"

constraints:
  VAR:
    regex: "(password|secret|apiKey|token)"
```

### Composite Rule (any)

```yaml
id: no-console
language: typescript
severity: warning
message: "Remove console statements"

rule:
  any:
    - pattern: console.log($$$)
    - pattern: console.warn($$$)
    - pattern: console.info($$$)

fix: ""
```

### Composite Rule (all + not)

```yaml
id: no-console-except-catch
language: typescript
severity: warning
message: "Console only allowed in catch blocks"

rule:
  all:
    - pattern: console.$METHOD($$$ARGS)
    - not:
        inside:
          kind: catch_clause
```

### Relational Rule (inside)

```yaml
id: no-await-in-loop
language: typescript
severity: warning
message: "Avoid await inside loops"

rule:
  pattern: await $EXPR
  inside:
    any:
      - kind: for_statement
      - kind: for_in_statement
      - kind: while_statement
```

### With Transform

```yaml
id: modernize-callback
language: typescript
severity: info
message: "Use arrow function instead of callback"

rule:
  pattern: function($PARAMS) { $$$BODY }

transform:
  ARROW:
    replace:
      source: $PARAMS
      replace: "^\\((.*)\\)$"
      by: "$1"

fix: ($ARROW) => { $$$BODY }
```

### With Rewriters

```yaml
id: promise-to-async
language: typescript
severity: info
message: "Convert Promise chain to async/await"

rewriters:
  - id: then-to-await
    rule:
      pattern: $PROMISE.then($CALLBACK)
    fix: await $PROMISE

rule:
  pattern: function $NAME() { return $CHAIN }

transform:
  ASYNC_CHAIN:
    rewrite:
      source: $CHAIN
      rewriters:
        - then-to-await

fix: async function $NAME() { return $ASYNC_CHAIN }
```

## Create with CLI

```bash
# Create new rule interactively
sg new rule

# Create rule with name
sg new rule my-rule-name

# Create rule for specific language
sg new rule -l typescript my-rule-name
```
