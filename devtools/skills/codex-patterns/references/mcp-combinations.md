# Combining Codex with Other MCP Tools

## Context7 + Codex

Get library docs first, then analyze specific usage:

```javascript
// First get library docs
mcp__plugin_devtools_context7__query_docs({
  libraryId: "/reactjs/react.dev",
  query: "How does useEffect cleanup work?",
});

// Then analyze specific usage
mcp__plugin_devtools_codex__codex({
  prompt: `Given React's useEffect cleanup behavior:
    [paste Context7 result]

    Analyze this useEffect for cleanup issues:
    [code]

    Is cleanup handled correctly?`,
});
```

## OctoCode + Codex

Find real-world examples first, then compare:

```javascript
// First find real-world examples
mcp__plugin_devtools_octocode__githubSearchCode({
  keywordsToSearch: ["useQuery", "error", "retry"],
  owner: "tanstack",
  repo: "query",
});

// Then compare against your implementation
mcp__plugin_devtools_codex__codex({
  prompt: `Compare these implementations:

    Reference (from TanStack):
    [paste OctoCode result]

    My implementation:
    [your code]

    What am I missing or doing differently?`,
});
```

## Pattern: Research → Reason

1. **Research phase** - Use Context7/OctoCode to gather facts
2. **Reason phase** - Use Codex to analyze, compare, evaluate

This separates information gathering from deep analysis, making both more effective.
