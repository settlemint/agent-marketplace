# ast-grep Exploration Guide

Use ast-grep for **codebase exploration** - understanding patterns, auditing code, and discovering architecture without modifying files.

## Understanding AST Structure

```bash
# See how code is parsed (essential for building patterns)
sg run -p "your pattern here" --debug-query -l typescript

# Example: understand function structure
sg run -p "function $NAME($$$PARAMS) { $$$BODY }" --debug-query -l typescript
```

The `--debug-query` flag shows:

- Matched AST nodes
- Captured meta-variables
- Node kinds (useful for `kind` rules)

## Finding All Usages

```bash
# Find all hook usages in React
sg run -p "use$HOOK($$$)" -l tsx --heading

# Find all API calls
sg run -p "fetch($URL, $$$OPTIONS)" -l typescript --heading

# Find all error handlers
sg run -p "catch ($ERROR) { $$$BODY }" -l typescript -A 5

# Find function definitions by name pattern
sg run -p "function $NAME($$$)" -l typescript | grep -i "auth"
```

**Flags for exploration:**

- `--heading` - Group results by file
- `-A N` - Show N lines after match
- `-B N` - Show N lines before match
- `-C N` - Show N lines of context (before and after)

## JSON Output for Analysis

```bash
# Get structured output
sg run -p "console.log($$$)" -l typescript --json

# Count matches per file
sg run -p "TODO" -l typescript --json | jq 'group_by(.file) | map({file: .[0].file, count: length})'

# Extract unique patterns
sg run -p "import $_ from '$MODULE'" -l typescript --json | jq -r '.[].metaVariables.single.MODULE.text' | sort -u

# Find files with specific patterns
sg run -p "useState($$$)" -l tsx --json | jq -r '.[].file' | sort -u
```

## Auditing Code

### Security Audit

```bash
# Find dangerous patterns
sg run -p "eval($$$)" -l typescript                    # eval usage
sg run -p "dangerouslySetInnerHTML" -l tsx             # XSS risk
sg run -p "document.write($$$)" -l typescript          # DOM injection
sg run -p "innerHTML = $VALUE" -l typescript           # innerHTML assignment
sg run -p "new Function($$$)" -l typescript            # Dynamic function creation

# Find hardcoded secrets
sg run -p 'const $VAR = "$VALUE"' -l typescript | grep -iE "(key|secret|password|token)"

# Find SQL injection risks
sg run -p '$DB.query(`$$$`)' -l typescript             # Template string queries
sg run -p '$DB.query($QUERY + $VAR)' -l typescript     # String concatenation
```

### Quality Audit

```bash
# Find console statements
sg run -p "console.$METHOD($$$)" -l typescript

# Find TODO/FIXME comments (use grep, not ast-grep for comments)
rg "TODO|FIXME" --type ts

# Find any type annotations
sg run -p ": any" -l typescript
sg run -p "as any" -l typescript

# Find empty catch blocks
sg run -p "catch ($E) { }" -l typescript

# Find unused variables (variables that are assigned but never read)
sg run -p "const $VAR = $VALUE" -l typescript --json | jq -r '.[].metaVariables.single.VAR.text' | sort | uniq -c
```

### Deprecation Audit

```bash
# Find deprecated API usage
sg run -p "componentWillMount($$$)" -l tsx             # React lifecycle
sg run -p "componentWillReceiveProps($$$)" -l tsx      # React lifecycle
sg run -p "UNSAFE_$METHOD($$$)" -l tsx                 # React UNSAFE methods

# Find old import patterns
sg run -p 'import $_ from "old-package"' -l typescript
sg run -p 'require("old-package")' -l typescript
```

## Discovering Architecture

### Find All Component Definitions

```bash
# React function components
sg run -p "function $COMPONENT($PROPS): JSX.Element { $$$BODY }" -l tsx
sg run -p "const $COMPONENT = ($PROPS) => { $$$BODY }" -l tsx

# React class components
sg run -p "class $COMPONENT extends React.Component { $$$BODY }" -l tsx
sg run -p "class $COMPONENT extends Component { $$$BODY }" -l tsx

# Custom hooks
sg run -p "function use$HOOK($$$) { $$$BODY }" -l tsx
```

### Find All API Endpoints

```bash
# Express routes
sg run -p '$APP.get("$PATH", $$$HANDLERS)' -l typescript
sg run -p '$APP.post("$PATH", $$$HANDLERS)' -l typescript

# Next.js API routes (look in pages/api or app/api)
sg run -p "export async function $METHOD(req, res) { $$$BODY }" -l typescript
sg run -p "export async function GET($$$) { $$$BODY }" -l typescript
sg run -p "export async function POST($$$) { $$$BODY }" -l typescript
```

### Find All Types/Interfaces

```bash
# Interfaces
sg run -p "interface $NAME { $$$BODY }" -l typescript --heading

# Type aliases
sg run -p "type $NAME = $TYPE" -l typescript --heading

# Exported types
sg run -p "export interface $NAME { $$$BODY }" -l typescript
sg run -p "export type $NAME = $TYPE" -l typescript
```

## Building Patterns Interactively

### Workflow

1. **Start with playground:** https://ast-grep.github.io/playground.html
2. **Paste sample code** you want to match
3. **Build pattern** using meta-variables
4. **Test with --debug-query** locally
5. **Refine** based on matches

### Common Pattern Building Tips

```bash
# Start broad, then narrow
sg run -p "$FUNC($$$)" -l typescript                   # Too broad
sg run -p "async $FUNC($$$)" -l typescript             # Better
sg run -p "async function $FUNC($$$)" -l typescript    # Most specific

# Use $_ for parts you don't care about
sg run -p "$_.map($CALLBACK)" -l typescript            # Any .map() call
sg run -p "$ARRAY.map($CALLBACK)" -l typescript        # Named array

# Match multiple alternatives (run multiple commands)
sg run -p "let $VAR = $VALUE" -l typescript
sg run -p "const $VAR = $VALUE" -l typescript
sg run -p "var $VAR = $VALUE" -l typescript
```

## Cross-Language Exploration

```bash
# TypeScript
sg run -p "import { $$$IMPORTS } from '$MODULE'" -l typescript

# Bash
sg run -p '$VAR="$VALUE"' -l bash                      # Variable assignment
sg run -p 'if [[ $COND ]]; then $$$BODY; fi' -l bash  # Conditionals

# HCL (Terraform)
sg run -p 'resource "$TYPE" "$NAME" { $$$BODY }' -l hcl

# YAML
sg run -p '$KEY: $VALUE' -l yaml
```

## Performance Tips

```bash
# Limit search scope with paths
sg run -p "$PATTERN" -l typescript src/
sg run -p "$PATTERN" -l typescript src/components/

# Use --json for large result sets (easier to process)
sg run -p "$PATTERN" -l typescript --json > results.json

# Combine with other tools
sg run -p "console.log($$$)" -l typescript --json | jq 'length'  # Count matches
sg run -p "$PATTERN" -l typescript | wc -l                        # Line count
```
