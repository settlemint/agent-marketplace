# ast-grep YAML Rule Schema

Complete reference for writing ast-grep YAML rules.

## Rule File Structure

```yaml
id: rule-id # Required: Unique identifier
language: typescript # Required: Language to match
severity: warning # hint | info | warning | error | off
message: "Why this rule fired" # Required: Concise explanation
note: | # Optional: Additional details (markdown)
  More context about the issue.
  Can include code examples.
url: https://docs.example.com # Optional: Documentation link
# The matching rule
rule:
  pattern: console.log($MSG)

# Optional: Auto-fix
fix: logger.info($MSG)

# Optional: File filtering
files:
  - "src/**/*.ts"
ignores:
  - "**/*.test.ts"
  - "**/node_modules/**"

# Optional: Meta-variable constraints
constraints:
  MSG:
    regex: '^[''"]' # MSG must start with quote

# Optional: Utility rules for reuse
utils:
  is-inside-function:
    inside:
      kind: function_declaration

# Optional: Transformations
transform:
  NEW_VAR:
    replace:
      source: $MSG
      replace: "old"
      by: "new"
```

## Rule Object

### Atomic Rules

Match basic AST nodes.

#### pattern

Matches code structure using meta-variables.

```yaml
# Simple pattern
rule:
  pattern: console.log($MSG)

# Pattern with context (for ambiguous syntax)
rule:
  pattern:
    context: "class C { $METHOD() {} }"
    selector: method_definition

# Pattern strictness
rule:
  pattern:
    context: "let x = 1"
    strictness: relaxed  # cst | smart | ast | relaxed | signature
```

#### kind

Matches tree-sitter node kinds.

```yaml
rule:
  kind: function_declaration

# Find node kinds in playground or with --debug-query
```

Common TypeScript kinds:

- `function_declaration`, `arrow_function`, `method_definition`
- `import_statement`, `export_statement`
- `variable_declarator`, `lexical_declaration`
- `call_expression`, `member_expression`
- `interface_declaration`, `type_alias_declaration`
- `class_declaration`, `class_body`
- `jsx_element`, `jsx_self_closing_element`

#### regex

Matches node text with regex.

```yaml
rule:
  regex: "^test_"

# Combined with kind
rule:
  kind: identifier
  regex: "^unused"
```

### Relational Rules

Filter by position relative to other nodes.

#### inside

Target must be inside another matching node.

```yaml
rule:
  pattern: console.log($MSG)
  inside:
    kind: function_declaration

# With stopBy (controls search scope)
rule:
  pattern: await $EXPR
  inside:
    pattern: Promise.all($ARRAY)
    stopBy: end  # Search all ancestors (default: neighbor)

# stopBy can be a rule
rule:
  pattern: $VAR
  inside:
    kind: function_body
    stopBy:
      kind: function_declaration
```

#### has

Target must contain a matching descendant.

```yaml
rule:
  kind: function_declaration
  has:
    pattern: return $EXPR

# With stopBy
rule:
  pattern: Promise.all($ARRAY)
  has:
    pattern: await $EXPR
    stopBy: end
```

#### follows

Target must appear after a matching node.

```yaml
rule:
  pattern: $A.use($MIDDLEWARE)
  follows:
    pattern: import $_ from 'express'
```

#### precedes

Target must appear before a matching node.

```yaml
rule:
  pattern: const $VAR = $VALUE
  precedes:
    pattern: export { $VAR }
```

#### Relational Rule Options

```yaml
stopBy: neighbor  # Only immediate parent/child
stopBy: end       # Search all ancestors/descendants
stopBy:           # Stop at matching rule
  kind: function_declaration

field: body       # Match specific AST field
```

### Composite Rules

Combine rules with logic operators.

#### all

All sub-rules must match (AND).

```yaml
rule:
  all:
    - pattern: console.log($MSG)
    - inside:
        kind: function_declaration
    - not:
        inside:
          kind: catch_clause
```

#### any

At least one sub-rule must match (OR).

```yaml
rule:
  any:
    - pattern: console.log($MSG)
    - pattern: console.warn($MSG)
    - pattern: console.error($MSG)
```

#### not

Sub-rule must NOT match.

```yaml
rule:
  pattern: console.log($MSG)
  not:
    inside:
      kind: catch_clause
```

#### matches

Reference a utility rule.

```yaml
utils:
  is-async-function:
    any:
      - pattern: async function $NAME($$$) { $$$BODY }
      - pattern: async ($$$) => $BODY

rule:
  pattern: await $EXPR
  not:
    inside:
      matches: is-async-function
```

### Positional Rules

#### nthChild

Match by position in sibling list.

```yaml
rule:
  kind: argument
  nthChild: 1        # First argument (0-indexed)

rule:
  kind: parameter
  nthChild: "2n"     # Even positions (CSS-style)

rule:
  kind: parameter
  nthChild:
    position: 1
    reverse: true    # Last position (like nth-last-child)
    ofRule:          # Only count matching siblings
      kind: required_parameter
```

#### range

Match by source position.

```yaml
rule:
  range:
    start:
      line: 0 # 0-indexed
      column: 0
    end:
      line: 10
      column: 50
```

## Constraints

Additional filtering for meta-variables.

```yaml
constraints:
  # Regex constraint
  MSG:
    regex: '^[''"]'

  # Pattern constraint
  FUNC:
    pattern: async function $NAME($$$) { $$$BODY }

  # Kind constraint
  TYPE:
    kind: type_identifier

  # Composite constraints
  VALUE:
    all:
      - regex: "^[0-9]"
      - not:
          regex: "^0$"
```

## Fix

Auto-fix configuration.

### Simple Fix

```yaml
fix: logger.info($MSG)
```

### Fix with Multiple Options

```yaml
fix:
  - template: logger.info($MSG)
    title: "Convert to logger.info"
  - template: logger.debug($MSG)
    title: "Convert to logger.debug"
```

### Fix with Expansion

```yaml
fix:
  template: $NEW_CODE
  expandStart:
    pattern: // TODO: $COMMENT
  expandEnd:
    pattern: // END TODO
```

## Transform

Manipulate meta-variables before using in fix.

```yaml
transform:
  # String replacement
  NEW_NAME:
    replace:
      source: $NAME
      replace: "old"
      by: "new"

  # Substring extraction
  SHORT_NAME:
    substring:
      source: $NAME
      startChar: 0
      endChar: 10

  # Case conversion
  SNAKE_NAME:
    convert:
      source: $NAME
      toCase: snakeCase # lowerCase | upperCase | camelCase | snakeCase | kebabCase | pascalCase
      separatedBy:
        - caseChange
        - underscore

  # Rewrite with sub-rules
  REWRITTEN:
    rewrite:
      source: $EXPR
      rewriters:
        - rule-id-1
        - rule-id-2
      joinBy: ", "
```

## Rewriters

Sub-rules for transform rewrite.

```yaml
rewriters:
  - id: convert-promise
    rule:
      pattern: $PROMISE.then($CALLBACK)
    fix: await $PROMISE

rule:
  pattern: function $NAME() { $$$BODY }
  transform:
    NEW_BODY:
      rewrite:
        source: $$$BODY
        rewriters:
          - convert-promise
  fix: async function $NAME() { $NEW_BODY }
```

## Utils

Reusable rule definitions.

```yaml
utils:
  is-exported:
    any:
      - pattern: export function $NAME($$$) { $$$BODY }
      - pattern: export const $NAME = $VALUE
      - pattern: export class $NAME { $$$BODY }

  is-test-file:
    inside:
      kind: program
      # File matching handled by files/ignores

rule:
  pattern: console.log($MSG)
  not:
    matches: is-exported
```

## Labels

Custom labels for reporting.

```yaml
labels:
  MSG:
    style: primary # primary | secondary
    message: "This value is logged"
  FUNC:
    style: secondary
    message: "Inside this function"
```

## File Filtering

```yaml
# Include only these files
files:
  - "src/**/*.ts"
  - "lib/**/*.ts"

# Exclude these files
ignores:
  - "**/*.test.ts"
  - "**/*.spec.ts"
  - "**/node_modules/**"
  - "**/dist/**"

# Case-insensitive matching
files:
  - glob: "**/*.TS"
    caseInsensitive: true
```

## Severity Levels

```yaml
severity: hint      # Subtle suggestion
severity: info      # Informational
severity: warning   # Potential issue
severity: error     # Definite problem
severity: off       # Disable rule
```

## Complete Example

```yaml
id: no-console-except-error
language: typescript
severity: warning
message: "Avoid console.log/warn in production code"
note: |
  Console statements should be removed or replaced with proper logging.
  Use logger.info() or logger.debug() instead.

  Exception: console.error is allowed in catch blocks.
url: https://example.com/docs/logging
rule:
  any:
    - pattern: console.log($$$ARGS)
    - pattern: console.warn($$$ARGS)
  not:
    inside:
      kind: catch_clause

fix: logger.info($$$ARGS)

files:
  - "src/**/*.ts"
  - "src/**/*.tsx"

ignores:
  - "**/*.test.ts"
  - "**/*.spec.ts"
  - "**/scripts/**"

constraints:
  ARGS:
    not:
      regex: "^$" # Must have at least one argument
```

## Testing Rules

Create test files alongside rules:

```yaml
# rules/no-console.yml
id: no-console
language: typescript
rule:
  pattern: console.log($MSG)
fix: ""

# __tests__/no-console-test.yml (or inline in rule file)
valid:
  - "logger.info('test')"
  - "console.error('error')" # If allowed

invalid:
  - "console.log('test')"
  - "console.log(variable)"
```

Run tests:

```bash
sg test -c sgconfig.yml
sg test -r rules/no-console.yml
```
