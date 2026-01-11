# Drizzle Query Patterns Template

```typescript
import { eq, and, or, desc, asc, like, inArray } from "drizzle-orm";
import { db } from "@/lib/db";
import { {{tableName}} } from "@/db/schema/{{table-name}}";

// SELECT with filter
export async function get{{TableName}}ById(id: string) {
  const [result] = await db
    .select()
    .from({{tableName}})
    .where(eq({{tableName}}.id, id));
  return result;
}

// SELECT with multiple conditions
export async function get{{TableName}}s(userId: string, enabled = true) {
  return db
    .select()
    .from({{tableName}})
    .where(and(
      eq({{tableName}}.userId, userId),
      eq({{tableName}}.enabled, enabled)
    ))
    .orderBy(desc({{tableName}}.createdAt));
}

// INSERT
export async function create{{TableName}}(data: Insert{{TableName}}) {
  const [result] = await db
    .insert({{tableName}})
    .values({ ...data, id: crypto.randomUUID() })
    .returning();
  return result;
}

// UPDATE
export async function update{{TableName}}(
  id: string,
  data: Partial<Insert{{TableName}}>
) {
  const [result] = await db
    .update({{tableName}})
    .set({ ...data, updatedAt: new Date() })
    .where(eq({{tableName}}.id, id))
    .returning();
  return result;
}

// DELETE
export async function delete{{TableName}}(id: string) {
  await db
    .delete({{tableName}})
    .where(eq({{tableName}}.id, id));
}
```

## Common Operators

```typescript
eq(column, value); // =
and(cond1, cond2); // AND
or(cond1, cond2); // OR
like(column, "%search%"); // LIKE
inArray(column, [1, 2, 3]); // IN
desc(column); // ORDER BY DESC
asc(column); // ORDER BY ASC
```
