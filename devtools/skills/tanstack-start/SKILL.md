---
name: tanstack-start
description: TanStack Start full-stack React framework. Covers file-based routing, SSR, data loading, and server functions. Triggers on tanstack start, createFileRoute, loader.
triggers:
  [
    "tanstack start",
    "createFileRoute",
    "createRootRoute",
    "loader",
    "serverFn",
    "ssr",
  ]
---

<objective>
Build full-stack React applications with TanStack Start - a type-safe, SSR-capable framework built on TanStack Router with Vinxi/Nitro for the server.
</objective>

<mcp_first>
**CRITICAL: Fetch TanStack Start documentation before implementing.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

```typescript
// TanStack Start patterns
mcp__context7__query_docs({
  libraryId: "/tanstack/start",
  query: "How do I use createFileRoute with loader and serverFn?",
});

// SSR and streaming
mcp__context7__query_docs({
  libraryId: "/tanstack/start",
  query: "How do I implement SSR, streaming, and deferred loading?",
});

// Server functions
mcp__context7__query_docs({
  libraryId: "/tanstack/start",
  query: "How do I use createServerFn and server actions?",
});
```

**Note:** Context7 v2 uses server-side filtering. Use descriptive natural language queries.
</mcp_first>

<quick_start>
**File-based route:**

```typescript
// routes/dashboard.tsx
import { createFileRoute } from "@tanstack/react-router";

export const Route = createFileRoute("/dashboard")({
  loader: async () => {
    const data = await fetchDashboardData();
    return { data };
  },
  component: DashboardPage,
});

function DashboardPage() {
  const { data } = Route.useLoaderData();
  return <Dashboard data={data} />;
}
```

**Root route with layout:**

```typescript
// routes/__root.tsx
import { createRootRoute, Outlet } from "@tanstack/react-router";

export const Route = createRootRoute({
  component: () => (
    <html>
      <body>
        <Header />
        <Outlet />
        <Footer />
      </body>
    </html>
  ),
});
```

**Server function:**

```typescript
import { createServerFn } from "@tanstack/react-start/server";

const getUser = createServerFn({ method: "GET" })
  .validator((userId: string) => userId)
  .handler(async ({ data: userId }) => {
    return await db.query.users.findFirst({
      where: eq(users.id, userId),
    });
  });

// Usage in component
const user = await getUser({ data: userId });
```

</quick_start>

<routing_patterns>
**Dynamic routes:**

```typescript
// routes/users/$userId.tsx
export const Route = createFileRoute("/users/$userId")({
  loader: async ({ params }) => {
    return await getUser(params.userId);
  },
});
```

**Nested layouts:**

```typescript
// routes/_authenticated.tsx (layout route)
export const Route = createFileRoute("/_authenticated")({
  beforeLoad: async ({ context }) => {
    if (!context.session) {
      throw redirect({ to: "/login" });
    }
  },
  component: AuthenticatedLayout,
});

// routes/_authenticated/settings.tsx (nested under layout)
export const Route = createFileRoute("/_authenticated/settings")({
  component: SettingsPage,
});
```

**Search params:**

```typescript
import { z } from "zod";

const searchSchema = z.object({
  page: z.number().optional().default(1),
  search: z.string().optional(),
});

export const Route = createFileRoute("/products")({
  validateSearch: searchSchema,
  component: ProductsPage,
});

function ProductsPage() {
  const { page, search } = Route.useSearch();
}
```

</routing_patterns>

<data_loading>
**Loader with context:**

```typescript
export const Route = createFileRoute("/dashboard")({
  loader: async ({ context }) => {
    const { queryClient, session } = context;
    return queryClient.ensureQueryData({
      queryKey: ["dashboard", session.userId],
      queryFn: () => fetchDashboard(session.userId),
    });
  },
});
```

**Deferred data (streaming):**

```typescript
export const Route = createFileRoute("/analytics")({
  loader: async () => {
    return {
      // Critical data - awaited
      summary: await fetchSummary(),
      // Non-critical - streamed
      details: fetchDetails(), // Returns promise
    };
  },
});

function AnalyticsPage() {
  const { summary, details } = Route.useLoaderData();

  return (
    <div>
      <Summary data={summary} />
      <Suspense fallback={<Skeleton />}>
        <Await promise={details}>
          {(data) => <Details data={data} />}
        </Await>
      </Suspense>
    </div>
  );
}
```

</data_loading>

<file_structure>

```
src/
├── routes/
│   ├── __root.tsx           # Root layout
│   ├── index.tsx            # /
│   ├── _authenticated.tsx   # Layout route (prefix _)
│   ├── _authenticated/
│   │   ├── dashboard.tsx    # /_authenticated/dashboard
│   │   └── settings.tsx     # /_authenticated/settings
│   ├── users/
│   │   ├── index.tsx        # /users
│   │   └── $userId.tsx      # /users/:userId
│   └── api/
│       └── [...].ts         # API routes
├── router.tsx               # Router configuration
└── entry-server.tsx         # Server entry
```

</file_structure>

<constraints>
**Required:**
- Use `createFileRoute` for all routes
- Validate search params with Zod
- Use `context` for shared data (queryClient, session)
- Handle errors with `errorComponent`

**Naming:**

- Layout routes: prefix with `_` (e.g., `_authenticated.tsx`)
- Dynamic params: prefix with `$` (e.g., `$userId.tsx`)
- Catch-all: `[...].tsx`
  </constraints>

<success_criteria>

- [ ] Context7 docs fetched for current API
- [ ] Routes use `createFileRoute`
- [ ] Loaders fetch data server-side
- [ ] Search params validated with Zod
- [ ] Layouts use `Outlet` for children
      </success_criteria>
