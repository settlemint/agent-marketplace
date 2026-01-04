# OctoCode MCP Reference

Search, analyze, and extract insights from GitHub repositories.

## Required Fields

Every query must include:

| Field              | Description                          |
| ------------------ | ------------------------------------ |
| `mainResearchGoal` | High-level objective of the research |
| `researchGoal`     | Specific goal of this query          |
| `reasoning`        | Why this query is needed             |

## Tools

| Tool                       | Purpose             | When to Use                             |
| -------------------------- | ------------------- | --------------------------------------- |
| `packageSearch`            | Find package repos  | NPM/Python package → owner/repo lookup  |
| `githubSearchRepositories` | Find repositories   | Discover projects, find implementations |
| `githubSearchCode`         | Search code content | Find patterns, locate files             |
| `githubViewRepoStructure`  | Explore directories | Understand project layout               |
| `githubGetFileContent`     | Read file content   | Get implementation details              |
| `githubSearchPullRequests` | Search PRs          | Find changes, review history            |

## Common Workflows

### Package Discovery

```
mcp__octocode__packageSearch({
  queries: [{
    mainResearchGoal: "Find viem library source code",
    researchGoal: "Locate the GitHub repository for viem",
    reasoning: "Need to explore viem internals",
    name: "viem",
    ecosystem: "npm",
    searchLimit: 1
  }]
})
```

### Explore Repository

```
mcp__octocode__githubViewRepoStructure({
  queries: [{
    mainResearchGoal: "Understand project structure",
    researchGoal: "Map the source directory",
    reasoning: "Need to find implementation files",
    owner: "tanstack",
    repo: "query",
    branch: "main",
    path: "packages",
    depth: 1
  }]
})
```

### Search Code

```
mcp__octocode__githubSearchCode({
  queries: [{
    mainResearchGoal: "Find mutation patterns",
    researchGoal: "Locate useMutation implementations",
    reasoning: "Need error handling examples",
    owner: "tanstack",
    repo: "query",
    keywordsToSearch: ["useMutation", "onError"],
    match: "file",
    extension: "ts",
    limit: 10
  }]
})
```

### Read File Content

```
mcp__octocode__githubGetFileContent({
  queries: [{
    mainResearchGoal: "Understand parseAbi implementation",
    researchGoal: "Read the parseAbi function",
    reasoning: "Need to understand ABI parsing",
    owner: "wevm",
    repo: "viem",
    path: "src/utils/abi/parseAbi.ts",
    matchString: "export function parseAbi",
    matchStringContextLines: 30
  }]
})
```

### Search Pull Requests

```
mcp__octocode__githubSearchPullRequests({
  queries: [{
    mainResearchGoal: "Find how auth was fixed",
    researchGoal: "Locate merged PRs about auth bugs",
    reasoning: "Need to understand the fix approach",
    owner: "org",
    repo: "project",
    query: "auth bug fix",
    state: "closed",
    merged: true,
    type: "metadata",
    limit: 5
  }]
})
```

## Best Practices

1. **Start with packages** - Use `packageSearch` to get exact owner/repo
2. **Map structure first** - Use `githubViewRepoStructure` depth=1
3. **Narrow scope** - Always specify owner/repo when known
4. **Use parallel queries** - Up to 3 related but independent searches
5. **Cite precisely** - Include full GitHub links in findings

## Error Recovery

| Problem          | Solution                             |
| ---------------- | ------------------------------------ |
| Empty results    | Try semantic variants (auth → login) |
| Too many results | Add filters (path, extension, stars) |
| Rate limited     | Wait briefly, try different tools    |

## Semantic Variants

When searches return empty:

| Original | Variants                                    |
| -------- | ------------------------------------------- |
| auth     | authentication, login, credentials, session |
| config   | settings, options, configuration            |
| util     | helper, lib, common, shared                 |
| error    | exception, failure, fault                   |
