# Context7 MCP Reference

Fetch accurate, version-specific documentation for any library or framework.

## Two-Step Process

**Step 1: Resolve Library ID**

```
mcp__context7__resolve-library-id({
  libraryName: "tanstack query"
})
```

**Step 2: Fetch Documentation**

```
mcp__context7__query-docs({
  context7CompatibleLibraryID: "/tanstack/query",
  topic: "mutations"
})
```

## Parameters

**query-docs:**

| Parameter                    | Required | Description                                      |
| ---------------------------- | -------- | ------------------------------------------------ |
| context7CompatibleLibraryID  | Yes      | ID from resolve step (e.g., "/tanstack/query")   |
| topic                        | No       | Focus area (e.g., "routing", "hooks")            |

## Common Library IDs

Skip the resolve step for these known IDs:

### Frontend

| Library         | Context7 ID               |
| --------------- | ------------------------- |
| React           | /reactjs/react.dev        |
| TanStack Router | /tanstack/router          |
| TanStack Query  | /tanstack/query           |
| TanStack Form   | /tanstack/form            |
| TanStack Table  | /tanstack/table           |
| TanStack Start  | /tanstack/start           |
| Tailwind CSS    | /tailwindlabs/tailwindcss |
| Radix UI        | /radix-ui/primitives      |

### Validation & Schema

| Library    | Context7 ID           |
| ---------- | --------------------- |
| Zod        | /colinhacks/zod       |
| TypeScript | /microsoft/typescript |

### Blockchain

| Library      | Context7 ID                          |
| ------------ | ------------------------------------ |
| Viem         | /wevm/viem                           |
| Wagmi        | /wevm/wagmi                          |
| Foundry      | /foundry-rs/book                     |
| OpenZeppelin | /openzeppelin/openzeppelin-contracts |
| The Graph    | /graphprotocol/docs                  |

### Database & ORM

| Library     | Context7 ID               |
| ----------- | ------------------------- |
| Drizzle ORM | /drizzle-team/drizzle-orm |

### Testing

| Library         | Context7 ID                           |
| --------------- | ------------------------------------- |
| Vitest          | /vitest-dev/vitest                    |
| Playwright      | /microsoft/playwright                 |
| Testing Library | /testing-library/testing-library-docs |

### Build & Tooling

| Library   | Context7 ID       |
| --------- | ----------------- |
| Vite      | /vitejs/vite      |
| Turborepo | /vercel/turborepo |
| Bun       | /oven-sh/bun      |

## Best Practices

1. **Always resolve first** - Don't guess library IDs (unless known from list above)
2. **Use specific topics** - "useMutation" not just "mutations"
3. **Version-specific docs** - Append version to ID (e.g., `/tanstack/router/v1.120.0`)
