# File Operation Tools

## Read — Read File Contents

Reads files with line numbers, handles images, PDFs, and notebooks.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file_path` | string | Yes | Absolute path to file |
| `offset` | number | No | Line number to start from |
| `limit` | number | No | Number of lines to read |

### Capabilities

| File Type | Behavior |
|-----------|----------|
| Text files | Returns with line numbers |
| Images (PNG, JPG) | Visual content displayed |
| PDF files | Text and visual extraction |
| Jupyter notebooks | All cells with outputs |
| Binary files | Error returned |

### Best Practices

```javascript
// GOOD: Read entire file
Read({file_path: "/absolute/path/to/file.ts"})

// GOOD: Read portion of large file
Read({
  file_path: "/path/to/large-file.ts",
  offset: 100,
  limit: 50
})

// GOOD: Read image for analysis
Read({file_path: "/path/to/screenshot.png"})

// BAD: Relative path
Read({file_path: "src/file.ts"})  // Must be absolute

// BAD: Using cat
Bash({command: "cat file.ts"})  // Use Read instead
```

### Common Use Cases

```javascript
// Read configuration
Read({file_path: "/project/tsconfig.json"})

// Read specific section
Read({
  file_path: "/project/src/long-file.ts",
  offset: 250,
  limit: 100
})

// Read screenshot for review
Read({file_path: "/tmp/screenshot.png"})

// Read multiple files in parallel
// (Use multiple Read calls in single message)
Read({file_path: "/project/src/a.ts"})
Read({file_path: "/project/src/b.ts"})
Read({file_path: "/project/src/c.ts"})
```

---

## Edit — Modify Files

Makes targeted, atomic edits to files.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file_path` | string | Yes | Absolute path to file |
| `old_string` | string | Yes | Exact text to replace |
| `new_string` | string | Yes | Replacement text |
| `replace_all` | boolean | No | Replace all occurrences (default: false) |

### Critical Rules

1. **MUST Read Before Edit** — Tool fails if file wasn't read first
2. **old_string Must Be Unique** — Use more context if not unique
3. **Preserve Exact Indentation** — Match whitespace exactly

### Best Practices

```javascript
// GOOD: Read first, then edit
Read({file_path: "/project/src/auth.ts"})

Edit({
  file_path: "/project/src/auth.ts",
  old_string: "const timeout = 5000",
  new_string: "const timeout = 10000"
})

// GOOD: Include context for uniqueness
Edit({
  file_path: "/project/src/auth.ts",
  old_string: `function handleLogin(user: User) {
  const timeout = 5000`,
  new_string: `function handleLogin(user: User) {
  const timeout = 10000`
})

// GOOD: Replace all occurrences
Edit({
  file_path: "/project/src/auth.ts",
  old_string: "oldFunctionName",
  new_string: "newFunctionName",
  replace_all: true
})

// BAD: Editing without reading
Edit({...})  // Will fail

// BAD: Non-unique old_string
Edit({
  old_string: "const x",  // Might match multiple locations
  new_string: "const y"
})
```

### Common Patterns

```javascript
// Rename variable/function
Edit({
  file_path: path,
  old_string: "oldName",
  new_string: "newName",
  replace_all: true
})

// Add import
Edit({
  file_path: path,
  old_string: `import { existingImport } from './module'`,
  new_string: `import { existingImport, newImport } from './module'`
})

// Add function parameter
Edit({
  file_path: path,
  old_string: "function process(data: Data)",
  new_string: "function process(data: Data, options?: Options)"
})

// Fix bug with context
Edit({
  file_path: path,
  old_string: `if (user.id = null) {  // Bug: assignment instead of comparison
    return false`,
  new_string: `if (user.id === null) {
    return false`
})
```

---

## Write — Create/Overwrite Files

Creates new files or completely overwrites existing ones.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `file_path` | string | Yes | Absolute path to file |
| `content` | string | Yes | Complete file content |

### Critical Rules

1. **Read Before Overwriting** — Must read existing file first
2. **Prefer Edit Over Write** — Use Edit for modifications
3. **No Unnecessary Files** — Don't create docs/READMEs unless asked

### Best Practices

```javascript
// GOOD: Create new file
Write({
  file_path: "/project/src/new-component.tsx",
  content: `import React from 'react';

export function NewComponent() {
  return <div>Hello</div>;
}
`
})

// GOOD: Read before overwrite
Read({file_path: "/project/config.json"})
Write({
  file_path: "/project/config.json",
  content: JSON.stringify(updatedConfig, null, 2)
})

// BAD: Overwriting without reading
Write({file_path: "/project/existing-file.ts", content: "..."})

// BAD: Creating unnecessary docs
Write({file_path: "/project/README.md", content: "..."})  // Unless asked

// BAD: Using echo/cat
Bash({command: "echo 'content' > file.ts"})  // Use Write
```

### Common Use Cases

```javascript
// Create new component
Write({
  file_path: "/project/src/components/Button.tsx",
  content: componentContent
})

// Create test file
Write({
  file_path: "/project/src/utils/format.test.ts",
  content: testContent
})

// Create configuration
Write({
  file_path: "/project/.eslintrc.json",
  content: JSON.stringify(config, null, 2)
})
```

---

## NotebookEdit — Modify Jupyter Notebooks

Edits cells in Jupyter notebooks (.ipynb files).

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `notebook_path` | string | Yes | Absolute path to notebook |
| `new_source` | string | Yes | New cell content |
| `cell_id` | string | No | Target cell ID |
| `cell_type` | enum | No | `code` or `markdown` |
| `edit_mode` | enum | No | `replace`, `insert`, `delete` |

### Common Patterns

```javascript
// Replace cell content
NotebookEdit({
  notebook_path: "/project/analysis.ipynb",
  cell_id: "abc123",
  new_source: "import pandas as pd\nimport numpy as np"
})

// Insert new cell
NotebookEdit({
  notebook_path: "/project/analysis.ipynb",
  cell_id: "after-this-cell",
  edit_mode: "insert",
  cell_type: "code",
  new_source: "# New analysis\ndf.describe()"
})

// Delete cell
NotebookEdit({
  notebook_path: "/project/analysis.ipynb",
  cell_id: "cell-to-delete",
  edit_mode: "delete",
  new_source: ""
})
```

---

## Anti-Patterns

### Never Use Bash for File Operations

```javascript
// BAD: cat for reading
Bash({command: "cat src/file.ts"})
// GOOD:
Read({file_path: "/project/src/file.ts"})

// BAD: head/tail for partial read
Bash({command: "head -n 50 src/file.ts"})
// GOOD:
Read({file_path: "/project/src/file.ts", limit: 50})

// BAD: sed for editing
Bash({command: "sed -i 's/old/new/g' file.ts"})
// GOOD:
Edit({file_path: path, old_string: "old", new_string: "new", replace_all: true})

// BAD: echo for writing
Bash({command: "echo 'content' > file.ts"})
// GOOD:
Write({file_path: "/project/file.ts", content: "content"})

// BAD: rm for deletion
Bash({command: "rm file.ts"})
// ACCEPTABLE: rm is fine for deletion (no native equivalent)
Bash({command: "rm /project/file.ts"})
```

### Edit vs Write Decision

| Scenario | Use |
|----------|-----|
| Changing part of file | Edit |
| Adding to existing file | Edit |
| Renaming across file | Edit with replace_all |
| Creating new file | Write |
| Complete file rewrite | Write (read first) |
| Small config change | Edit |
| Generated file | Write |
