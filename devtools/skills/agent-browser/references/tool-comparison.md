# Browser Tool Comparison

## Playwright MCP

**When to use:**

- Writing E2E tests with assertions
- Test fixtures and setup/teardown
- Parallel test execution
- CI/CD integration
- Cross-browser testing

**Available via MCP tools:**

```typescript
// The Playwright MCP server provides browser automation
// Use MCPSearch to find available tools:
MCPSearch({ query: "playwright" });

// Common operations:
mcp__playwright__browser_navigate({ url: "https://example.com" });
mcp__playwright__browser_click({ selector: "button" });
mcp__playwright__browser_snapshot();
```

**Playwright MCP vs agent-browser:**

| Feature         | Playwright MCP  | agent-browser |
| --------------- | --------------- | ------------- |
| Interface       | MCP tools       | CLI           |
| Best for        | Testing         | AI automation |
| Assertions      | Built-in expect | Manual        |
| Parallelization | Native          | Sessions      |
| Output          | Structured      | JSON/text     |

## Claude Chrome Integration

**When to use:**

- User is actively watching
- Interactive debugging
- Recording GIFs of flows
- Quick page inspection
- Visual verification needed

**Available tools (mcp**claude-in-chrome**\*):**

- `navigate` - Go to URL
- `click` - Click element
- `form_input` - Fill forms
- `read_page` - Read page content
- `screenshot` - Take screenshot
- `gif_creator` - Record interaction
- `computer` - Low-level mouse/keyboard

**Chrome vs agent-browser:**

| Feature      | Claude Chrome     | agent-browser    |
| ------------ | ----------------- | ---------------- |
| Visibility   | User sees browser | Headless         |
| Recording    | GIF support       | Screenshots only |
| Intervention | User can help     | Autonomous       |
| Speed        | Slower (visual)   | Faster           |
