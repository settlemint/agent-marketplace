# Drizzle Table Schema Template

```typescript
import {
  pgTable,
  text,
  boolean,
  timestamp,
  index,
  integer,
} from "drizzle-orm/pg-core";

export const {{tableName}} = pgTable(
  "{{table_name}}",
  {
    id: text("id").primaryKey(),
    {{field}}: {{fieldType}}("{{column_name}}").{{constraints}},
    userId: text("user_id")
      .notNull()
      .references(() => user.id, { onDelete: "cascade" }),
    createdAt: timestamp("created_at", { withTimezone: true })
      .defaultNow()
      .notNull(),
    updatedAt: timestamp("updated_at", { withTimezone: true })
      .defaultNow()
      .notNull(),
  },
  (table) => [
    index("idx_{{table_name}}_user_id").on(table.userId),
  ]
);

// Always export inferred types
export type Insert{{TableName}} = typeof {{tableName}}.$inferInsert;
export type Select{{TableName}} = typeof {{tableName}}.$inferSelect;
```

## Placeholders

| Placeholder       | Example                      | Description              |
| ----------------- | ---------------------------- | ------------------------ |
| `{{tableName}}`   | `contacts`                   | camelCase table variable |
| `{{table_name}}`  | `contact`                    | snake_case SQL table     |
| `{{TableName}}`   | `Contact`                    | PascalCase for types     |
| `{{field}}`       | `email`                      | Field name               |
| `{{fieldType}}`   | `text`, `boolean`, `integer` | Drizzle type             |
| `{{column_name}}` | `email`                      | SQL column name          |
| `{{constraints}}` | `.notNull().unique()`        | Field constraints        |

## Common Field Types

```typescript
text("name").notNull();
boolean("enabled").default(true);
integer("count").default(0);
timestamp("created_at", { withTimezone: true }).defaultNow();
```
