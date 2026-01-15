---
name: turbo
description: Turborepo monorepo build system with task pipelines, caching, and package management. Triggers on turbo, turbo.json, monorepo.
license: MIT
triggers:
  [
    "turbo",
    "turborepo",
    "turbo\\.json",
    "monorepo",
    "mono-repo",
    "mono\\s*repo",
    "workspace",
    "pnpm-workspace",
    "dependsOn.*\\^",
    "\\^build",
    "task\\s*pipeline",
    "remote\\s*cach",
    "vercel.*turbo",
    "turbo\\s+(build|run|prune)",
    "turbo.*filter",
    "--filter=",
    "package.*workspace",
    "lerna",
    "nx\\s+monorepo",
    "build\\s*system.*mono",
  ]
---

<objective>
Configure Turborepo for efficient monorepo builds with task pipelines, remote caching, and proper package dependencies.
</objective>

<mcp_first>
**CRITICAL: Always fetch Turborepo documentation for current configuration.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

```typescript
// Task configuration
mcp__context7__query_docs({
  libraryId: "/vercel/turborepo",
  query: "How do I configure tasks with dependsOn, outputs, and inputs?",
});

// Caching
mcp__context7__query_docs({
  libraryId: "/vercel/turborepo",
  query: "How do I configure cache outputs and remote caching?",
});

// Filtering
mcp__context7__query_docs({
  libraryId: "/vercel/turborepo",
  query: "How do I filter workspaces and packages?",
});
```

**Note:** Context7 v2 uses server-side filtering. Use descriptive natural language queries.
</mcp_first>

<quick_start>
**turbo.json:**

```json
{
  "$schema": "https://turbo.build/schema.json",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**", ".next/**"]
    },
    "test": {
      "dependsOn": ["build"],
      "outputs": []
    },
    "lint": {
      "outputs": []
    },
    "dev": {
      "cache": false,
      "persistent": true
    }
  }
}
```

**Key concepts:**

- `^build` - Run `build` in dependencies first
- `outputs` - Files to cache
- `inputs` - Files that affect cache key
- `cache: false` - Disable caching for dev tasks
- `persistent: true` - Long-running tasks
  </quick_start>

<task_patterns>
**Build pipeline:**

```json
{
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"],
      "inputs": ["src/**", "package.json", "tsconfig.json"]
    }
  }
}
```

**Test after build:**

```json
{
  "tasks": {
    "test": {
      "dependsOn": ["build"],
      "outputs": ["coverage/**"]
    }
  }
}
```

**Parallel independent tasks:**

```json
{
  "tasks": {
    "lint": {
      "outputs": []
    },
    "typecheck": {
      "outputs": []
    }
  }
}
```

</task_patterns>

<commands>
```bash
turbo build                    # Build all packages
turbo build --filter=@org/app  # Build specific package
turbo build --filter=./apps/*  # Build apps only
turbo build --filter=...@org/lib  # Package and dependents
turbo build --force            # Ignore cache
turbo build --dry-run          # Preview what will run
```
</commands>

<constraints>
**Banned:**
- Missing `outputs` on cacheable tasks (breaks caching)
- Circular dependencies in `dependsOn`
- Caching dev/watch mode tasks
- Overly broad `inputs` patterns (cache misses)

**Required:**

- Define `outputs` for cacheable tasks
- Use `^` prefix for dependency ordering
- Set `cache: false` for dev tasks
- Use `persistent: true` for long-running tasks

**Best practices:**

- Keep `inputs` specific to avoid cache misses
- Use workspace filters for targeted builds
- Enable remote caching for CI
  </constraints>

<anti_patterns>

- **Cache Thrashing:** Overly broad `inputs` causing unnecessary cache invalidation
- **Missing Dependencies:** Tasks that depend on others without explicit `dependsOn`
- **Cached Dev Tasks:** Long-running dev tasks with caching enabled; wastes storage
- **Monolithic Pipeline:** All tasks in one pipeline; split by concern for parallelism
- **Implicit Ordering:** Relying on alphabetical ordering instead of explicit dependencies
  </anti_patterns>

<library_ids>
Skip resolve step for these known IDs:

| Library   | Context7 ID       |
| --------- | ----------------- |
| Turborepo | /vercel/turborepo |

</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production Turborepo patterns",
      researchGoal: "Search for task pipeline and caching patterns",
      reasoning: "Need real-world examples of Turborepo usage",
      keywordsToSearch: ["turbo.json", "dependsOn", "outputs"],
      extension: "json",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Pipelines: `keywordsToSearch: ["dependsOn", "^build", "tasks"]`
- Caching: `keywordsToSearch: ["outputs", "inputs", "cache"]`
- Filtering: `keywordsToSearch: ["--filter", "workspace", "packages"]`
- Remote cache: `keywordsToSearch: ["remoteCache", "teamId", "TURBO_TOKEN"]`
  </research>

<related_skills>

**Testing:** Load via `Skill({ skill: "devtools:vitest" })` when:

- Configuring test tasks in turbo pipeline
- Running tests across monorepo packages

**TypeScript:** Load via `Skill({ skill: "devtools:tdd-typescript" })` when:

- Setting up TypeScript builds in pipeline
- Configuring type checking tasks

**Deployment:** Load via `Skill({ skill: "devtools:helm" })` when:

- Deploying monorepo packages to Kubernetes
- Building container images for deployment
  </related_skills>

<success_criteria>

- [ ] Context7 docs fetched for current config
- [ ] Tasks have proper `dependsOn`
- [ ] `outputs` defined for cacheable tasks
- [ ] Dev tasks have `cache: false`
- [ ] Pipeline is efficient (parallel where possible)
      </success_criteria>

<evolution>
**Extension Points:**
- Add team-specific task patterns via templates
- Extend with remote caching configuration for CI providers
- Integrate with deployment workflows for monorepo releases

**Timelessness:** Build orchestration and caching are fundamental to scalable development; task dependency graphs apply to any build system.
</evolution>
