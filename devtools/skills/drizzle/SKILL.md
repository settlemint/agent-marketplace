---
name: drizzle
description: Drizzle ORM patterns for PostgreSQL schemas, queries, migrations, and Zod integration. Triggers on drizzle, pgTable, db.select, db.insert, migration.
triggers: ["drizzle", "pgTable", "db\\.select", "db\\.insert", "db\\.update", "db\\.delete", "db\\.query", "migration", "drizzle-zod"]
---

<objective>
Build database schemas and queries using Drizzle ORM with PostgreSQL. Drizzle generates efficient SQL with near-zero overhead and excellent TypeScript integration.
</objective>

<mcp_first>
**CRITICAL: Always fetch Drizzle documentation before implementing.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__resolve-library-id" })
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

```typescript
// Drizzle schema patterns
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/drizzle-team/drizzle-orm",
  topic: "pgTable text boolean timestamp"
})

// Query patterns
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/drizzle-team/drizzle-orm",
  topic: "db.select db.insert db.update db.delete"
})

// Relations
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/drizzle-team/drizzle-orm",
  topic: "relations one many db.query"
})

// Migrations
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/drizzle-team/drizzle-orm",
  topic: "drizzle-kit generate migrate push"
})
```
</mcp_first>

<quick_start>
**Define a table:**

```typescript
import { pgTable, text, boolean, timestamp, index } from "drizzle-orm/pg-core";

export const contacts = pgTable("contact", {
  id: text("id").primaryKey(),
  name: text("name").notNull(),
  email: text("email").notNull().unique(),
  enabled: boolean("enabled").default(true),
  userId: text("user_id").notNull().references(() => user.id, { onDelete: "cascade" }),
  createdAt: timestamp("created_at", { withTimezone: true }).defaultNow().notNull(),
}, (table) => [
  index("idx_contact_user_id").on(table.userId),
]);

// Always export inferred types
export type InsertContact = typeof contacts.$inferInsert;
export type SelectContact = typeof contacts.$inferSelect;
```

**Query patterns:**

```typescript
import { eq, and, desc } from "drizzle-orm";

// Select with filter
const results = await db.select()
  .from(contacts)
  .where(eq(contacts.userId, userId))
  .orderBy(desc(contacts.createdAt));

// Insert
await db.insert(contacts).values({ id: crypto.randomUUID(), name, email, userId });

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

<commands>
```bash
bun run db:generate    # Generate migration from schema changes
bun run db:migrate     # Run pending migrations
bun run db:push        # Push schema directly (dev only)
bun run db:studio      # Open Drizzle Studio
```
</commands>

<success_criteria>
- [ ] Context7 docs fetched for current API
- [ ] Table has `$inferInsert` and `$inferSelect` type exports
- [ ] All timestamps use `{ withTimezone: true }`
- [ ] Foreign keys have `onDelete` action
- [ ] Indexes defined for foreign keys
- [ ] Migration generated and tested
</success_criteria>
