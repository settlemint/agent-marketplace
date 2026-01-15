# ast-grep Transformations

Transform meta-variables before using them in fixes.

## Overview

Transformations let you modify captured meta-variables before applying fixes. They're defined in the `transform` section and referenced with `$NEW_VAR` in the `fix`.

```yaml
rule:
  pattern: oldFunction($ARG)
transform:
  UPPER_ARG:
    convert:
      source: $ARG
      toCase: upperCase
fix: newFunction($UPPER_ARG)
```

## Substring

Extract a portion of the matched text.

### Basic Usage

```yaml
transform:
  SHORT:
    substring:
      source: $NAME
      startChar: 0
      endChar: 10
```

### Parameters

| Parameter   | Type   | Description                                      |
| ----------- | ------ | ------------------------------------------------ |
| `source`    | string | Meta-variable to transform (with `$` prefix)     |
| `startChar` | int    | Starting character index (inclusive, default: 0) |
| `endChar`   | int    | Ending character index (exclusive, default: end) |

### Negative Indexing

Negative indices count from the end (Python-style).

```yaml
# Get last 5 characters
transform:
  SUFFIX:
    substring:
      source: $NAME
      startChar: -5

# Remove last 3 characters
transform:
  WITHOUT_SUFFIX:
    substring:
      source: $NAME
      endChar: -3

# Get everything except first and last character
transform:
  MIDDLE:
    substring:
      source: $NAME
      startChar: 1
      endChar: -1
```

### Examples

```yaml
# Remove 'get' prefix from getter name
id: rename-getter
rule:
  pattern: get$NAME()
transform:
  PROP_NAME:
    substring:
      source: $NAME
      startChar: 0  # Already without 'get' due to pattern
fix: $PROP_NAME

# Extract extension from filename
id: extract-extension
rule:
  pattern: '"$FILENAME"'
transform:
  EXT:
    substring:
      source: $FILENAME
      startChar: -3  # Assumes 3-char extension
```

## Replace

Use regex to find and replace text within a meta-variable.

### Basic Usage

```yaml
transform:
  NEW_NAME:
    replace:
      source: $NAME
      replace: "Old"
      by: "New"
```

### Parameters

| Parameter | Type   | Description                 |
| --------- | ------ | --------------------------- |
| `source`  | string | Meta-variable to transform  |
| `replace` | string | Rust regex pattern to match |
| `by`      | string | Replacement string          |

### Regex Features

Uses [Rust regex syntax](https://docs.rs/regex/latest/regex/#syntax).

```yaml
# Capture groups
transform:
  RENAMED:
    replace:
      source: $NAME
      replace: "^get(.+)$"
      by: "fetch$1"

# Named capture groups
transform:
  REORDERED:
    replace:
      source: $IMPORT
      replace: "(?P<module>\\w+)/(?P<file>\\w+)"
      by: "${file}/${module}"

# Multiple replacements (chain transforms)
transform:
  STEP1:
    replace:
      source: $TEXT
      replace: "foo"
      by: "bar"
  STEP2:
    replace:
      source: $STEP1
      replace: "baz"
      by: "qux"
```

### Common Patterns

```yaml
# Remove prefix
transform:
  WITHOUT_PREFIX:
    replace:
      source: $NAME
      replace: "^prefix_"
      by: ""

# Remove suffix
transform:
  WITHOUT_SUFFIX:
    replace:
      source: $NAME
      replace: "_suffix$"
      by: ""

# Replace underscores with hyphens
transform:
  KEBAB:
    replace:
      source: $NAME
      replace: "_"
      by: "-"

# Escape special characters
transform:
  ESCAPED:
    replace:
      source: $STRING
      replace: '"'
      by: '\\"'

# Convert path separators
transform:
  UNIX_PATH:
    replace:
      source: $PATH
      replace: "\\\\"
      by: "/"
```

### Examples

```yaml
# Convert console.log to structured logging
id: structured-logging
rule:
  pattern: console.log("$MSG", $DATA)
transform:
  LOG_KEY:
    replace:
      source: $MSG
      replace: "\\s+"
      by: "_"
fix: logger.info({ $LOG_KEY: $DATA })

# Rename React hooks
id: rename-use-query
rule:
  pattern: useQuery($ARGS)
transform:
  NEW_ARGS:
    replace:
      source: $ARGS
      replace: "queryKey"
      by: "key"
fix: useCustomQuery($NEW_ARGS)
```

## Convert

Change the case format of text.

### Basic Usage

```yaml
transform:
  SNAKE_CASE:
    convert:
      source: $NAME
      toCase: snakeCase
```

### Case Options

| Case         | Input         | Output        |
| ------------ | ------------- | ------------- |
| `lowerCase`  | `MyVariable`  | `myvariable`  |
| `upperCase`  | `MyVariable`  | `MYVARIABLE`  |
| `capitalize` | `myVariable`  | `MyVariable`  |
| `camelCase`  | `my_variable` | `myVariable`  |
| `snakeCase`  | `myVariable`  | `my_variable` |
| `kebabCase`  | `myVariable`  | `my-variable` |
| `pascalCase` | `my_variable` | `MyVariable`  |

### Separators

Control how words are split before conversion.

```yaml
transform:
  CONVERTED:
    convert:
      source: $NAME
      toCase: snakeCase
      separatedBy:
        - caseChange # Split on case changes (camelCase -> camel, Case)
        - underscore # Split on underscores
        - dash # Split on dashes
        - dot # Split on dots
        - slash # Split on slashes
        - space # Split on spaces
```

### Examples

```yaml
# Convert camelCase to SCREAMING_SNAKE_CASE
id: const-naming
rule:
  pattern: const $NAME = $VALUE
transform:
  CONST_NAME:
    convert:
      source: $NAME
      toCase: snakeCase
      separatedBy:
        - caseChange
fix: const $CONST_NAME = $VALUE

# Convert PascalCase component to kebab-case file
id: component-filename
rule:
  pattern: export function $COMPONENT() { $$$BODY }
transform:
  FILENAME:
    convert:
      source: $COMPONENT
      toCase: kebabCase
      separatedBy:
        - caseChange
# Use $FILENAME for file renaming logic

# Convert snake_case to camelCase
id: js-naming
rule:
  pattern: $OBJECT.$snake_method($ARGS)
transform:
  CAMEL_METHOD:
    convert:
      source: $snake_method
      toCase: camelCase
      separatedBy:
        - underscore
fix: $OBJECT.$CAMEL_METHOD($ARGS)
```

## Rewrite

Apply rewriter rules to transform nested code.

### Basic Usage

```yaml
rewriters:
  - id: promise-to-await
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
        - promise-to-await
fix: async function $NAME() { $NEW_BODY }
```

### Parameters

| Parameter   | Type   | Description                             |
| ----------- | ------ | --------------------------------------- |
| `source`    | string | Meta-variable(s) to transform           |
| `rewriters` | array  | List of rewriter rule IDs to apply      |
| `joinBy`    | string | Optional separator for multiple results |

### Multiple Rewriters

Rewriters are applied in order:

```yaml
rewriters:
  - id: step-one
    rule:
      pattern: oldA($X)
    fix: newA($X)
  - id: step-two
    rule:
      pattern: oldB($X)
    fix: newB($X)

transform:
  TRANSFORMED:
    rewrite:
      source: $CODE
      rewriters:
        - step-one
        - step-two
```

### Multi-Node Source

Use `$$$VAR` for multiple nodes:

```yaml
rule:
  pattern: "[$$$ITEMS]"
transform:
  PROCESSED_ITEMS:
    rewrite:
      source: $$$ITEMS
      rewriters:
        - item-transformer
      joinBy: ", "
fix: "[$PROCESSED_ITEMS]"
```

### Examples

```yaml
# Convert Promise chain to async/await
id: modernize-async
rewriters:
  - id: then-to-await
    rule:
      pattern: $P.then($CB)
    fix: await $P
  - id: catch-to-try
    rule:
      pattern: $P.catch($HANDLER)
    fix: |
      try {
        $P
      } catch (e) {
        $HANDLER(e)
      }

rule:
  pattern: function $NAME() { return $PROMISE_CHAIN }
transform:
  ASYNC_BODY:
    rewrite:
      source: $PROMISE_CHAIN
      rewriters:
        - then-to-await
        - catch-to-try
fix: async function $NAME() { return $ASYNC_BODY }

# Transform array elements
id: map-to-forEach
rewriters:
  - id: element-transform
    rule:
      pattern: $ITEM
    fix: process($ITEM)

rule:
  pattern: "[$$$ELEMENTS].map($FN)"
transform:
  PROCESSED:
    rewrite:
      source: $$$ELEMENTS
      rewriters:
        - element-transform
      joinBy: ", "
fix: "[$PROCESSED].forEach($FN)"
```

## Chaining Transformations

Transformations can reference other transformations:

```yaml
transform:
  # Step 1: Remove prefix
  STEP1:
    replace:
      source: $NAME
      replace: "^old_"
      by: ""

  # Step 2: Convert case
  STEP2:
    convert:
      source: $STEP1
      toCase: camelCase

  # Step 3: Add new prefix
  FINAL:
    replace:
      source: $STEP2
      replace: "^"
      by: "new"

fix: $FINAL
```

## String Syntax (Shorthand)

Since ast-grep 0.38.3+, simple transforms can use string syntax:

```yaml
transform:
  # Substring shorthand
  SHORT: "$NAME[0:10]"
  SUFFIX: "$NAME[-5:]"

  # Replace shorthand (not supported - use object syntax)

  # Convert shorthand (not supported - use object syntax)
```

## Debugging Transformations

Use `--debug-query` to see meta-variable values before transformation:

```bash
sg run -p "function $NAME($$$ARGS) { $$$BODY }" --debug-query -l typescript
```

This helps verify what values your transformations will receive.
