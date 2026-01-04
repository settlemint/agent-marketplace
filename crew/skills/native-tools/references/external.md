# External Resource Tools

## WebFetch — Fetch URL Content

Fetches and processes content from URLs using AI summarization.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `url` | string | Yes | Fully-formed URL to fetch |
| `prompt` | string | Yes | What to extract from the page |

### Behavior

- HTTP automatically upgraded to HTTPS
- HTML converted to markdown
- Large content summarized
- 15-minute cache for repeated requests
- Redirects reported (fetch again with new URL)

### Best Practices

```javascript
// GOOD: Specific extraction prompt
WebFetch({
  url: "https://docs.example.com/api/auth",
  prompt: "Extract the authentication flow and required headers"
})

// GOOD: Handle redirects
const result = WebFetch({
  url: "https://old-url.com/docs",
  prompt: "Get API documentation"
})
// If redirect detected, fetch the new URL

// GOOD: Extract specific information
WebFetch({
  url: "https://github.com/org/repo/blob/main/README.md",
  prompt: "Extract installation steps and configuration options"
})
```

### Common Use Cases

```javascript
// Documentation lookup
WebFetch({
  url: "https://tanstack.com/query/latest/docs/react/overview",
  prompt: "Extract query configuration options and caching behavior"
})

// API reference
WebFetch({
  url: "https://api.stripe.com/docs",
  prompt: "Find the webhook signature verification method"
})

// Package info
WebFetch({
  url: "https://www.npmjs.com/package/zod",
  prompt: "Get version, dependencies, and basic usage examples"
})
```

---

## WebSearch — Web Search

Performs web searches with optional domain filtering.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `query` | string | Yes | Search query (min 2 chars) |
| `allowed_domains` | array | No | Only include these domains |
| `blocked_domains` | array | No | Exclude these domains |

### Best Practices

```javascript
// GOOD: Specific query with year
WebSearch({
  query: "TypeScript 5.3 satisfies operator best practices 2024"
})

// GOOD: Domain filtering
WebSearch({
  query: "React Server Components",
  allowed_domains: ["react.dev", "nextjs.org", "vercel.com"]
})

// GOOD: Exclude low-quality results
WebSearch({
  query: "PostgreSQL indexing strategies",
  blocked_domains: ["w3schools.com", "tutorialspoint.com"]
})
```

### Source Citation (Required)

After answering with search results, ALWAYS include sources:

```markdown
[Your answer here]

Sources:
- [React Documentation](https://react.dev/...)
- [Vercel Blog](https://vercel.com/blog/...)
```

---

## Bash — Shell Commands

Executes shell commands when native tools aren't sufficient.

### When to Use Bash

| Use Bash For | Don't Use Bash For |
|--------------|-------------------|
| Git commands | Finding files (use Glob) |
| Package managers (npm, bun) | Searching content (use Grep) |
| Build/test scripts | Reading files (use Read) |
| Docker operations | Editing files (use Edit) |
| System utilities | Writing files (use Write) |

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `command` | string | Yes | Command to execute |
| `description` | string | No | 5-10 word description |
| `timeout` | number | No | Max 600000ms (10 min) |
| `run_in_background` | boolean | No | Run asynchronously |

### Best Practices

```javascript
// GOOD: Git commands
Bash({command: "git status", description: "Check git status"})
Bash({command: "git diff main...HEAD", description: "Show changes vs main"})
Bash({command: "git add . && git commit -m 'feat: add auth'", description: "Commit changes"})

// GOOD: Package management
Bash({command: "bun install", description: "Install dependencies"})
Bash({command: "bun run build", description: "Build project"})
Bash({command: "bun run test", description: "Run tests"})

// GOOD: Quote paths with spaces
Bash({command: 'cd "/path/with spaces" && ls'})

// GOOD: Background for long-running
Bash({
  command: "bun run test:integration",
  run_in_background: true,
  description: "Run integration tests"
})
```

### Anti-Patterns

```javascript
// BAD: File search with bash
Bash({command: "find . -name '*.ts'"})
// GOOD:
Glob({pattern: "**/*.ts"})

// BAD: Content search with bash
Bash({command: "grep -r 'pattern' src/"})
// GOOD:
Grep({pattern: "pattern", path: "src/"})

// BAD: Reading files with bash
Bash({command: "cat src/file.ts"})
// GOOD:
Read({file_path: "/project/src/file.ts"})

// BAD: Editing with sed
Bash({command: "sed -i 's/old/new/' file.ts"})
// GOOD:
Edit({file_path: path, old_string: "old", new_string: "new"})

// BAD: Writing with echo
Bash({command: "echo 'content' > file.ts"})
// GOOD:
Write({file_path: path, content: "content"})
```

### Git Workflow

```javascript
// Check status first
Bash({command: "git status", description: "Check status"})

// Stage and commit
Bash({
  command: `git add . && git commit -m "$(cat <<'EOF'
feat(auth): add JWT authentication

- Add login endpoint
- Add signup endpoint
- Add token refresh
EOF
)"`,
  description: "Commit auth feature"
})

// Push and create PR
Bash({command: "git push -u origin feature/auth", description: "Push branch"})
Bash({
  command: `gh pr create --title "Add authentication" --body "$(cat <<'EOF'
## Summary
- JWT-based authentication
- Login and signup endpoints

## Test Plan
- [ ] Test login flow
- [ ] Test signup validation
EOF
)"`,
  description: "Create PR"
})
```

---

## MCP Tools

MCP (Model Context Protocol) tools provide specialized capabilities.

### Available MCP Servers

| Server | Purpose | Tools |
|--------|---------|-------|
| **Context7** | Library documentation | `resolve-library-id`, `query-docs` |
| **OctoCode** | GitHub code search | `githubSearchCode`, `githubGetFileContent`, `githubViewRepoStructure` |
| **Codex** | Deep reasoning | `codex`, `codex-reply` |

### Context7 — Library Documentation

```javascript
// First resolve library ID
mcp__plugin_crew_context7__resolve-library-id({
  libraryName: "tanstack-query"
})

// Then query docs
mcp__plugin_crew_context7__query-docs({
  context7CompatibleLibraryID: "/tanstack/query",
  topic: "query invalidation"
})
```

### OctoCode — GitHub Search

```javascript
// Search code across GitHub
mcp__plugin_crew_octocode__githubSearchCode({
  keywordsToSearch: ["useQuery", "invalidateQueries"],
  owner: "tanstack",
  repo: "query"
})

// Get file content
mcp__plugin_crew_octocode__githubGetFileContent({
  owner: "tanstack",
  repo: "query",
  path: "packages/react-query/src/useQuery.ts"
})

// View repo structure
mcp__plugin_crew_octocode__githubViewRepoStructure({
  owner: "tanstack",
  repo: "query",
  depth: 2
})
```

### Codex — Deep Reasoning

```javascript
// Complex analysis
mcp__plugin_crew_codex__codex({
  prompt: `Analyze the authentication implementation:

Code: ${codeContent}

Questions:
1. Are there security vulnerabilities?
2. Does it follow OWASP guidelines?
3. What improvements would you recommend?`,
  sandbox: "read-only"
})
```

### MCP Tool Loading

Before using MCP tools, they must be loaded:

```javascript
// Search for available tools
MCPSearch({query: "github search code"})

// Or select directly
MCPSearch({query: "select:mcp__plugin_crew_octocode__githubSearchCode"})
```
