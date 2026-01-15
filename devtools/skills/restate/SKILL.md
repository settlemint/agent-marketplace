---
name: restate
description: Restate durable execution for fault-tolerant services and workflows. Triggers on restate, durable, ctx.run, ctx.sleep, awakeable.
license: MIT
triggers: [
    # Library name and imports
    "\\brestate\\b",
    "@restatedev",
    "restate-sdk",

    # Context methods
    "\\bctx\\.(run|sleep|awakeable|set|get)\\b",
    "\\bctx\\.(serviceClient|objectClient|workflowClient)\\b",

    # Service types
    "\\brestate\\.(service|object|workflow)\\b",
    "\\b(Service|Object|Workflow)Context\\b",
    "\\bVirtual\\s*Object\\b",

    # Durable concepts
    "\\bdurable\\s*(execution|function|step|sleep)\\b",
    "\\bexactly.?once\\b",
    "\\bfault.?tolerant\\b",
    "\\bidempoten(t|cy)\\b",

    # Workflow patterns
    "\\b(saga|compensation|rollback)\\s*pattern\\b",
    "\\blong.?running.*workflow\\b",
    "\\bhuman.?in.?the.?loop\\b",
    "\\bawait.*approval\\b",

    # Orchestration intents
    "(orchestrat|coordinat).*(service|microservice|workflow)",
    "(durable|reliable|fault).*(workflow|execution|processing)",
    "(retry|recover|resume).*(failure|crash|restart)",
    "state.*persist",
    "surviv.*(restart|failure|crash)",

    # CLI and deployment
    "\\brestate\\s+(deployments|services|sql)\\b",
    "restate.*register",

    # Comparisons (when users ask about alternatives)
    "(temporal|durable\\s*task|step\\s*function).*alternative",
    "replac.*(temporal|celery|bull)",
  ]
---

<objective>
Build durable, fault-tolerant services using Restate with TypeScript. Restate provides automatic retries, state persistence, and exactly-once execution guarantees.
</objective>

<mcp_first>
**CRITICAL: Use the Restate docs MCP server if available, or OctoCode.**

```
MCPSearch({ query: "restate" })
```

If Restate MCP available:

```typescript
mcp__restate_docs__SearchRestate({
  query: "virtual object state management",
});
```

Otherwise use OctoCode:

```typescript
mcp__octocode__githubSearchCode({
  keywordsToSearch: ["service", "handler", "ctx.run"],
  owner: "restatedev",
  repo: "sdk-typescript",
  path: "packages/restate-sdk/src",
  mainResearchGoal: "Understand Restate SDK",
  researchGoal: "Find service definition patterns",
  reasoning: "Need current API for Restate services",
});
```

</mcp_first>

<quick_start>
**Service definition:**

```typescript
import * as restate from "@restatedev/restate-sdk";

const myService = restate.service({
  name: "MyService",
  handlers: {
    process: async (ctx: restate.Context, input: string): Promise<string> => {
      // Durable step - automatically retried on failure
      const result = await ctx.run("fetch-data", async () => {
        const response = await fetch("https://api.example.com/data");
        return response.json();
      });

      // Durable sleep - survives restarts
      await ctx.sleep(5000);

      return `Processed: ${result}`;
    },
  },
});

// Serve the service
restate.endpoint().bind(myService).listen(9080);
```

**Register with Restate:**

```bash
restate deployments register http://host.docker.internal:9080
```

</quick_start>

<context_methods>
| Method | Purpose | Example |
|--------|---------|---------|
| `ctx.run(name, fn)` | Durable step with retries | `await ctx.run("api-call", () => fetch(...))` |
| `ctx.sleep(ms)` | Durable delay | `await ctx.sleep(60000)` |
| `ctx.awakeable()` | Wait for external signal | `const { id, promise } = ctx.awakeable()` |
| `ctx.serviceClient(svc)` | Call another service | `ctx.serviceClient(other).method(input)` |
| `ctx.objectClient(obj, key)` | Call Virtual Object | `ctx.objectClient(counter, "user-1").increment()` |
</context_methods>

<patterns>
**Virtual Objects (Stateful):**

```typescript
const counter = restate.object({
  name: "Counter",
  handlers: {
    increment: async (ctx: restate.ObjectContext): Promise<number> => {
      const current = (await ctx.get<number>("count")) ?? 0;
      const newCount = current + 1;
      ctx.set("count", newCount);
      return newCount;
    },
  },
});
```

**Workflows (Long-running):**

```typescript
const orderWorkflow = restate.workflow({
  name: "OrderWorkflow",
  handlers: {
    run: async (ctx: restate.WorkflowContext, order: Order): Promise<void> => {
      await ctx.run("validate", () => validateOrder(order));

      // Wait for human approval
      const approval = ctx.awakeable<boolean>();
      await notifyForApproval(approval.id);
      const approved = await approval.promise;

      if (approved) {
        await ctx.run("fulfill", () => fulfillOrder(order));
      }
    },
  },
});
```

</patterns>

<constraints>
**Banned:** Starting Restate server manually (use Docker), blocking without `ctx.run()`

**Required:**

- Wrap all external calls in `ctx.run()` for durability
- Use `ctx.sleep()` for delays (not `setTimeout`)
- Register services with running Restate server
- Handlers must be idempotent
  </constraints>

<anti_patterns>
**Common mistakes to avoid:**

- Forgetting to wrap external calls in `ctx.run()` (loses durability)
- Using `setTimeout` instead of `ctx.sleep()` (doesn't survive restarts)
- Non-idempotent handlers (causes issues on replay)
- Blocking operations outside `ctx.run()` (breaks determinism)
- Manual state management instead of Virtual Objects
  </anti_patterns>

<commands>
```bash
# Health check
curl http://localhost:9170/health

# Register service

restate deployments register http://host.docker.internal:9080

# List services

restate services list

# SQL introspection

restate sql "SELECT \* FROM sys_invocation LIMIT 10"

````
</commands>

<library_ids>
Skip resolve step for these known IDs:

| Library      | Context7 ID          |
| ------------ | -------------------- |
| Restate SDK  | /restatedev/sdk-typescript |
</library_ids>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [{
    mainResearchGoal: "Find production Restate patterns",
    researchGoal: "Search for durable execution patterns",
    reasoning: "Need real-world examples of Restate usage",
    keywordsToSearch: ["restate.service", "ctx.run", "awakeable"],
    extension: "ts",
    limit: 10
  }]
})
````

**Common searches:**

- Services: `keywordsToSearch: ["restate.service", "handlers", "ctx.run"]`
- Workflows: `keywordsToSearch: ["restate.workflow", "WorkflowContext"]`
- Virtual Objects: `keywordsToSearch: ["restate.object", "ctx.get", "ctx.set"]`
  </research>

<related_skills>

**Testing:** Load via `Skill({ skill: "devtools:vitest" })` when:

- Testing Restate handlers
- Mocking context methods

**API development:** Load via `Skill({ skill: "devtools:api" })` when:

- Integrating Restate with API routes
- Building service orchestration
  </related_skills>

<success_criteria>

- [ ] MCP docs fetched for current API
- [ ] External calls wrapped in `ctx.run()`
- [ ] Using `ctx.sleep()` not `setTimeout`
- [ ] Service registered with Restate
- [ ] Handlers are idempotent
      </success_criteria>

<evolution>
**Extension Points:**

- Add domain-specific workflow patterns (saga, compensation)
- Create reusable service templates for common integrations
- Build observability wrappers for tracing and metrics

**Timelessness:** Durable execution and exactly-once semantics are fundamental distributed systems patterns.
</evolution>
