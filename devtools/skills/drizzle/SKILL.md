---
name: drizzle
description: Drizzle ORM patterns for PostgreSQL schemas, queries, migrations, and Zod integration. Triggers on drizzle, pgTable, db.select, db.insert, migration.
license: MIT
triggers:
  # Library name and variations
  - "\\bdrizzle\\b"
  - "drizzle-orm"
  - "drizzle-kit"
  - "drizzle-zod"
  - "drizzle/pg-core"
  # Schema definitions
  - "pgTable"
  - "mysqlTable"
  - "sqliteTable"
  - "\\$inferInsert"
  - "\\$inferSelect"
  # Column types
  - "text\\([\"']"
  - "varchar\\([\"']"
  - "boolean\\([\"']"
  - "timestamp\\([\"']"
  - "integer\\([\"']"
  - "serial\\([\"']"
  # Query operations
  - "db\\.select"
  - "db\\.insert"
  - "db\\.update"
  - "db\\.delete"
  - "db\\.query"
  - "db\\.transaction"
  # Query helpers
  - "\\beq\\("
  - "\\band\\("
  - "\\bor\\("
  - "\\bdesc\\("
  - "\\basc\\("
  - "\\blike\\("
  - "\\bilike\\("
  # Migration and commands
  - "db:generate"
  - "db:migrate"
  - "db:push"
  - "db:studio"
  - "drizzle\\.config"
  # Relationships
  - "\\.references\\("
  - "onDelete.*cascade"
  - "relations\\("
  # User intent - database work
  - "create.*table"
  - "database.*schema"
  - "add.*column"
  - "run.*migration"
  - "generate.*migration"
  - "postgres.*query"
  - "sql.*query"
  - "foreign.*key"
  - "database.*index"
  - "orm.*query"
---

<objective>
Build database schemas and queries using Drizzle ORM with PostgreSQL. Drizzle generates efficient SQL with near-zero overhead and excellent TypeScript integration.
</objective>

<mcp_first>
**CRITICAL: Always fetch Drizzle documentation before implementing.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

MCPSearch discovers and loads MCP tools before use.

```typescript
// Drizzle schema patterns
mcp__context7__query_docs({
  libraryId: "/drizzle-team/drizzle-orm",
  query: "How do I define tables with pgTable, text, boolean, and timestamp?",
});

// Query patterns
mcp__context7__query_docs({
  libraryId: "/drizzle-team/drizzle-orm",
  query: "How do I use db.select, db.insert, db.update, and db.delete?",
});

// Relations
mcp__context7__query_docs({
  libraryId: "/drizzle-team/drizzle-orm",
  query: "How do I define relations with one and many, and use db.query?",
});

// Migrations
mcp__context7__query_docs({
  libraryId: "/drizzle-team/drizzle-orm",
  query: "How do I use drizzle-kit for generate, migrate, and push?",
});
```

**Note:** Context7 v2 uses server-side filtering. Use descriptive natural language queries.
</mcp_first>

<quick_start>
**Templates:**

| Template                       | Purpose                     |
| ------------------------------ | --------------------------- |
| `templates/table-schema.ts.md` | Table definition with types |
| `templates/queries.ts.md`      | CRUD query patterns         |

**Define a table:**

```typescript
import { pgTable, text, boolean, timestamp, index } from "drizzle-orm/pg-core";

export const contacts = pgTable(
  "contact",
  {
    id: text("id").primaryKey(),
    name: text("name").notNull(),
    email: text("email").notNull().unique(),
    enabled: boolean("enabled").default(true),
    userId: text("user_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    createdAt: timestamp("created_at", { withTimezone: true })
      .defaultNow()
      .notNull(),
  },
  (table) => [index("idx_contact_user_id").on(table.userId)],
);

// Always export inferred types
export type InsertContact = typeof contacts.$inferInsert;
export type SelectContact = typeof contacts.$inferSelect;
```

**Query patterns:**

```typescript
import { eq, and, desc } from "drizzle-orm";

// Select with filter
const results = await db
  .select()
  .from(contacts)
  .where(eq(contacts.userId, userId))
  .orderBy(desc(contacts.createdAt));

// Insert
await db
  .insert(contacts)
  .values({ id: crypto.randomUUID(), name, email, userId });

// Update
await db.update(contacts).set({ enabled: false }).where(eq(contacts.id, id));

// Delete
await db.delete(contacts).where(eq(contacts.id, id));
```

</quick_start>

<constraints>
**Banned:**
- Raw SQL without `sql` template
- Manual connection management
- Editing migration files
- Re-exports via barrel files (import from canonical source)
- PGLite test database in production (`NODE_ENV` guard required)
- Dev credentials or test mocks in production
- Premature abstractions (three similar lines better than early helper)

**Required:**

- Every table exports `$inferInsert` and `$inferSelect` types
- All timestamps use `{ withTimezone: true }`
- Foreign keys have `onDelete` action specified
- Indexes defined for foreign keys and frequently queried columns
- Import directly from source files, not index barrels
- Gate test database clients with explicit `NODE_ENV === "production"` check
- Prefer simplest schema design
- Delete unused columns/tables completely

**Naming:** Schema files=`lowercase-with-hyphens.ts`, Tables=singular noun
</constraints>

<anti_patterns>

- Forgetting `$inferInsert` and `$inferSelect` type exports
- Timestamps without `{ withTimezone: true }`
- Foreign keys without explicit `onDelete` action
- Editing generated migration files manually
- Multiple snapshots with same `prevId` (breaks migration chain)
  </anti_patterns>

<commands>
```bash
bun run db:generate    # Generate migration from schema changes
bun run db:migrate     # Run pending migrations
bun run db:push        # Push schema directly (dev only)
bun run db:studio      # Open Drizzle Studio
```
</commands>

<gotchas>
**Migration Conflict Resolution**

When multiple branches add migrations with overlapping indices, resolve by renumbering:

1. Keep HEAD's migrations in place (they may already be applied)
2. Renumber incoming migrations to fill subsequent indices
3. **Critical:** Update each snapshot's `prevId` to form a proper chain

```json
// Each snapshot's prevId must reference the PREVIOUS snapshot's id
// 0020_snapshot.json: { "id": "abc123", "prevId": "xyz789" }
// 0021_snapshot.json: { "id": "def456", "prevId": "abc123" }  ← Must chain!
```

Drizzle migrations form a linked list via `prevId`. If two snapshots share the same `prevId`, migrations will fail.

**Custom Type Normalization**

Use custom types for automatic data normalization at the database boundary:

```typescript
// Define custom type that normalizes on write
export const evmAddress = customType<{ data: string }>({
  dataType() {
    return "text";
  },
  toDriver(value) {
    return value.toLowerCase();
  }, // Auto-normalize
});

// Use in schema - no manual toLowerCase() needed
export const contracts = pgTable("contracts", {
  address: evmAddress("address").notNull(),
});
```

This eliminates manual normalization throughout the codebase and ensures consistency.
</gotchas>

<research>
**Find patterns on GitHub when stuck:**

```typescript
mcp__plugin_devtools_octocode__githubSearchCode({
  queries: [
    {
      mainResearchGoal: "Find production Drizzle ORM patterns",
      researchGoal: "Search for schema design and query patterns",
      reasoning: "Need real-world examples of Drizzle usage",
      keywordsToSearch: ["pgTable", "drizzle-orm", "relations"],
      extension: "ts",
      limit: 10,
    },
  ],
});
```

**Common searches:**

- Schema patterns: `keywordsToSearch: ["pgTable", "$inferInsert", "$inferSelect"]`
- Relations: `keywordsToSearch: ["relations", "one", "many", "drizzle"]`
- Migrations: `keywordsToSearch: ["drizzle-kit", "migrate", "generate"]`
  </research>

<related_skills>

**Schema validation:** Load via `Skill({ skill: "devtools:zod" })` when:

- Generating Zod schemas from Drizzle tables
- Validating input before database operations
- Creating type-safe API contracts

**Testing:** Load via `Skill({ skill: "devtools:vitest" })` when:

- Writing unit tests for database queries
- Mocking database connections
- Testing migrations
  </related_skills>

<success_criteria>

1. [ ] Context7 docs fetched for current API
2. [ ] Table has `$inferInsert` and `$inferSelect` type exports
3. [ ] All timestamps use `{ withTimezone: true }`
4. [ ] Foreign keys have `onDelete` action
5. [ ] Indexes defined for foreign keys
6. [ ] Migration generated and tested
</success_criteria>

<evolution>
**Extension Points:**
- Add custom column types for domain-specific normalization
- Create shared schema utilities for common patterns
- Build type-safe query builders for complex operations

**Timelessness:** Type-safe ORMs with near-zero overhead represent the future of database access in TypeScript applications.
</evolution>
