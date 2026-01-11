# File Search Tools

## Glob — Find Files by Pattern

Fast file pattern matching that respects `.gitignore`.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pattern` | string | Yes | Glob pattern (e.g., `**/*.ts`, `src/components/*.tsx`) |
| `path` | string | No | Directory to search in (defaults to cwd) |

### Pattern Syntax

| Pattern | Matches |
|---------|---------|
| `*` | Any file in current directory |
| `**` | Any file recursively |
| `*.ts` | All `.ts` files in current directory |
| `**/*.ts` | All `.ts` files recursively |
| `src/**/*.{ts,tsx}` | All TypeScript files in src/ |
| `!**/node_modules/**` | Exclude node_modules |

### Best Practices

```javascript
// GOOD: Specific patterns
Glob({pattern: "src/components/**/*.tsx"})
Glob({pattern: "**/*.test.ts"})

// GOOD: Scoped to directory
Glob({pattern: "*.md", path: "docs/"})

// BAD: Too broad
Glob({pattern: "**/*"})  // Returns too many results
```

### Common Use Cases

```javascript
// Find all TypeScript files
Glob({pattern: "**/*.ts"})

// Find test files
Glob({pattern: "**/*.{test,spec}.{ts,tsx}"})

// Find config files
Glob({pattern: "**/tsconfig*.json"})

// Find files in specific directory
Glob({pattern: "*.md", path: "crew/commands"})
```

---

## Grep — Search File Contents

Powerful content search built on ripgrep.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `pattern` | string | Yes | Regex pattern to search |
| `path` | string | No | File/directory to search |
| `type` | string | No | File type filter (e.g., `ts`, `py`, `rust`) |
| `glob` | string | No | Glob pattern to filter files |
| `output_mode` | enum | No | `files_with_matches` (default), `content`, `count` |
| `-A` | number | No | Lines after match (with `content` mode) |
| `-B` | number | No | Lines before match (with `content` mode) |
| `-C` | number | No | Lines around match (with `content` mode) |
| `-i` | boolean | No | Case insensitive |
| `-n` | boolean | No | Show line numbers (default: true with content) |
| `multiline` | boolean | No | Match across lines |
| `head_limit` | number | No | Limit results |

### Output Modes

| Mode | Returns | Use When |
|------|---------|----------|
| `files_with_matches` | File paths only | Finding which files contain pattern |
| `content` | Matching lines with context | Seeing actual matches |
| `count` | Match counts per file | Measuring frequency |

### Best Practices

```javascript
// GOOD: Find files containing pattern
Grep({pattern: "handleAuth", type: "ts", output_mode: "files_with_matches"})

// GOOD: See matching lines with context
Grep({
  pattern: "function handleAuth",
  output_mode: "content",
  "-C": 3  // 3 lines before and after
})

// GOOD: Case-insensitive search
Grep({pattern: "error", "-i": true, type: "ts"})

// GOOD: Search specific directory
Grep({pattern: "API_KEY", path: "src/config/"})

// BAD: Too broad without type filter
Grep({pattern: "import"})  // Will match too many files
```

### Pattern Syntax (Ripgrep Regex)

```javascript
// Literal search
Grep({pattern: "handleAuth"})

// Word boundary
Grep({pattern: "\\bauth\\b"})

// Function definitions
Grep({pattern: "function\\s+\\w+"})

// Export statements
Grep({pattern: "export (const|function|class)"})

// Interface definitions
Grep({pattern: "interface\\s+\\w+\\s*\\{"})

// Multiline (for spanning lines)
Grep({
  pattern: "struct\\s*\\{[\\s\\S]*?field",
  multiline: true
})
```

### Common Use Cases

```javascript
// Find function definitions
Grep({
  pattern: "function handleAuth",
  type: "ts",
  output_mode: "content",
  "-A": 10
})

// Find all imports of a module
Grep({
  pattern: "from ['\"]./auth",
  type: "ts"
})

// Find TODO comments
Grep({
  pattern: "TODO|FIXME|HACK",
  output_mode: "content"
})

// Find class definitions
Grep({
  pattern: "class \\w+ (extends|implements)",
  type: "ts",
  output_mode: "content",
  "-B": 2,  // Include decorators
  "-A": 5   // Include class body start
})

// Count occurrences
Grep({
  pattern: "console\\.log",
  output_mode: "count"
})
```

---

## Anti-Patterns

### Never Use Bash for Search

```javascript
// BAD: Bash find
Bash({command: "find . -name '*.ts'"})
// GOOD: Native Glob
Glob({pattern: "**/*.ts"})

// BAD: Bash grep
Bash({command: "grep -r 'pattern' src/"})
// GOOD: Native Grep
Grep({pattern: "pattern", path: "src/"})

// BAD: Bash for listing
Bash({command: "ls -la src/"})
// GOOD: Read directory with Glob
Glob({pattern: "*", path: "src/"})
```

### Search Strategy

1. **Start narrow, expand if needed**
   - Begin with specific directory/file type
   - Broaden only if no results

2. **Use type filters**
   - `type: "ts"` is faster than `glob: "*.ts"`

3. **Check output mode**
   - `files_with_matches` for discovery
   - `content` for understanding matches

4. **Limit results**
   - Use `head_limit` for large codebases
