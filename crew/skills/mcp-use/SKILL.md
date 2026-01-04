---
name: mcp-use
description: MCP server documentation for Context7, OctoCode, and Codex. Use these for research and code analysis.
triggers:
  - "context7"
  - "octocode"
  - "codex"
  - "mcp server"
  - "library docs"
  - "github search"
---

<objective>

Provide guidance on using the bundled MCP servers for research, documentation lookup, and code analysis.

</objective>

<mcp_servers>

## MCP Servers

### Context7

Fetch accurate, version-specific documentation for any library.

```
mcp__context7__resolve-library-id({ libraryName: "tanstack query" })
mcp__context7__query-docs({ context7CompatibleLibraryID: "/tanstack/query", topic: "mutations" })
```

Reference: `references/context7.md`

### OctoCode

Search and analyze GitHub repositories.

```
mcp__octocode__packageSearch({ queries: [{ mainResearchGoal: "...", researchGoal: "...", reasoning: "...", name: "viem", ecosystem: "npm" }] })
mcp__octocode__githubSearchCode({ queries: [{ ..., keywordsToSearch: ["pattern"], owner: "org", repo: "project" }] })
```

Reference: `references/octocode.md`

### Codex

Deep reasoning for complex analysis and code review.

```
mcp__codex__codex({ prompt: "Analyze this algorithm", cwd: "/project", sandbox: "read-only" })
mcp__codex__codex-reply({ conversationId: "...", prompt: "Follow-up question" })
```

Reference: `references/codex.md`

</mcp_servers>

<references>

## Domain Knowledge

- `references/context7.md` - Fetch up-to-date library documentation
- `references/octocode.md` - GitHub code search and exploration
- `references/codex.md` - Deep reasoning with OpenAI Codex

</references>
