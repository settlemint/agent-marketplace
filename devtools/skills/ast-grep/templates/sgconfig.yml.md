# ast-grep Project Configuration Template

## Basic Configuration

```yaml
# sgconfig.yml
ruleDirs:
  - rules/
```

## Full Configuration

```yaml
# sgconfig.yml - ast-grep project configuration

# Directories containing YAML rule files
ruleDirs:
  - rules/
  - custom-rules/

# Test configuration
testConfigs:
  - testDir: rules/__tests__/

# Custom language to file extension mapping
languageGlobs:
  typescript:
    - "**/*.ts"
    - "**/*.mts"
    - "**/*.cts"
  tsx:
    - "**/*.tsx"
  javascript:
    - "**/*.js"
    - "**/*.mjs"
    - "**/*.cjs"
  bash:
    - "**/*.sh"
    - "**/*.bash"
    - "**/.*rc"
  hcl:
    - "**/*.tf"
    - "**/*.tfvars"
  yaml:
    - "**/*.yaml"
    - "**/*.yml"

# Utility rules available to all rules
utilDirs:
  - rules/utils/

# Custom registered languages (for tree-sitter grammars)
# customLanguages:
#   - name: custom-lang
#     extensions: [".custom"]
#     libraryPath: "./tree-sitter-custom.so"
```

## Directory Structure

```
project/
├── sgconfig.yml          # Main configuration
├── rules/
│   ├── typescript/       # Language-specific rules
│   │   ├── no-console.yml
│   │   └── no-any.yml
│   ├── security/         # Category-based rules
│   │   ├── no-eval.yml
│   │   └── no-innerHTML.yml
│   ├── utils/            # Shared utility rules
│   │   └── common-patterns.yml
│   └── __tests__/        # Rule tests
│       ├── no-console-test.yml
│       └── snapshots/
└── src/                  # Your source code
```

## Configuration Options

### ruleDirs

Directories containing rule YAML files. Searched recursively.

```yaml
ruleDirs:
  - rules/ # All .yml files in rules/
  - lint/custom/ # Additional rules
```

### testConfigs

Configure rule testing.

```yaml
testConfigs:
  - testDir: rules/__tests__/
    snapshotDir: rules/__tests__/snapshots/
```

### languageGlobs

Map file patterns to languages.

```yaml
languageGlobs:
  typescript:
    - "**/*.ts"
    - "!**/*.d.ts" # Exclude declaration files
  tsx:
    - "**/*.tsx"
  yaml:
    - "**/*.yml"
    - "**/*.yaml"
    - "!**/node_modules/**"
```

### utilDirs

Directories containing utility rules for `matches` references.

```yaml
utilDirs:
  - rules/utils/
```

Utils are available in all rules:

```yaml
# rules/utils/common.yml
id: is-test-file
rule:
  inside:
    kind: program
    # Pattern matches test files

# rules/no-console.yml
id: no-console
rule:
  pattern: console.log($$$)
  not:
    matches: is-test-file
```

## CLI Usage

```bash
# Initialize new project
sg new project

# Scan with config
sg scan -c sgconfig.yml

# Scan specific directory
sg scan -c sgconfig.yml src/

# Test rules
sg test -c sgconfig.yml

# Test specific rules
sg test -c sgconfig.yml -f "no-console"
```

## Minimal Configurations

### TypeScript Project

```yaml
# sgconfig.yml
ruleDirs:
  - .ast-grep/rules/
```

### Monorepo

```yaml
# sgconfig.yml
ruleDirs:
  - tools/lint/rules/

languageGlobs:
  typescript:
    - "packages/**/*.ts"
    - "apps/**/*.ts"
  tsx:
    - "packages/**/*.tsx"
    - "apps/**/*.tsx"
```

### Multi-language Project

```yaml
# sgconfig.yml
ruleDirs:
  - rules/typescript/
  - rules/bash/
  - rules/terraform/

languageGlobs:
  typescript:
    - "src/**/*.ts"
  bash:
    - "scripts/**/*.sh"
    - "bin/*"
  hcl:
    - "infra/**/*.tf"
```

## Integration Examples

### Pre-commit Hook

```yaml
# .pre-commit-config.yaml
repos:
  - repo: local
    hooks:
      - id: ast-grep
        name: ast-grep lint
        entry: sg scan -c sgconfig.yml
        language: system
        types: [file]
        pass_filenames: false
```

### GitHub Actions

```yaml
# .github/workflows/lint.yml
name: Lint
on: [push, pull_request]

jobs:
  ast-grep:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install ast-grep
        run: npm install -g @ast-grep/cli
      - name: Run ast-grep
        run: sg scan -c sgconfig.yml --format github
```

### VS Code Integration

Install the ast-grep VS Code extension. It automatically detects `sgconfig.yml`.

## Create with CLI

```bash
# Create new project with configuration
sg new project

# Follow prompts to configure:
# - Rule directories
# - Test directories
# - Language settings
```
