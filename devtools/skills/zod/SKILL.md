---
name: zod
description: Zod v4 schema patterns with .meta() for OpenAPI, transforms, refinements, and custom serializers. Triggers on zod, z.object, z.string, schema, validator.
triggers: ["zod", "z\\.object", "z\\.string", "z\\.number", "z\\.enum", "schema", "validator"]
---

<objective>
Build type-safe validation schemas using Zod v4. Use `.meta()` for OpenAPI descriptions (not `.describe()`), export inferred types, and write tests for all schemas.
</objective>

<mcp_first>
**CRITICAL: Zod v4 has breaking changes from v3. Always fetch current docs.**

```
MCPSearch({ query: "select:mcp__plugin_devtools_context7__query-docs" })
```

```typescript
// Zod v4 schema patterns
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/colinhacks/zod",
  topic: "z.object z.string z.number"
})

// .meta() usage (v4 specific)
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/colinhacks/zod",
  topic: "meta description examples"
})

// Transforms and refinements
mcp__context7__query_docs({
  context7CompatibleLibraryID: "/colinhacks/zod",
  topic: "transform refine superRefine"
})
```
</mcp_first>

<quick_start>
**Use `.meta()` NOT `.describe()`:**

```typescript
// ✅ CORRECT - Zod v4
z.string().meta({
  description: "The recipient wallet address",
  examples: ["0x1234567890123456789012345678901234567890"],
});

// ❌ WRONG - Zod v3 legacy
z.string().describe("The recipient wallet address");
```

**Standard schema pattern:**

```typescript
import { z } from "zod";

export const mySchema = z
  .string()
  .min(1, "Must not be empty")
  .max(100, "Must be at most 100 characters")
  .transform((value) => value.toLowerCase())
  .meta({
    description: "Human-readable description for OpenAPI",
    examples: ["valid-input"],
  });

// Export inferred types
export type MySchema = z.infer<typeof mySchema>;
export type MySchemaInput = z.input<typeof mySchema>;
```
</quick_start>

<patterns>
**Refined schema composition (v4.3+):**

`.pick()`, `.omit()`, `.extend()` throw on refined schemas. Split base and refined:

```typescript
// ✅ Correct - Split base and refined schemas
export const UserBaseSchema = z.object({
  email: z.string().email(),
  password: z.string(),
  confirmPassword: z.string(),
});

export const UserSchema = UserBaseSchema.refine(
  (data) => data.password === data.confirmPassword,
  { message: "Passwords must match", path: ["confirmPassword"] }
);

// Use base schema for composition
export const UserCreateSchema = UserBaseSchema.omit({ confirmPassword: true });

// ❌ Wrong - Will throw at runtime
// UserSchema.omit({ confirmPassword: true }); // Error!
```

**Exclusive unions with z.xor() (v4.3+):**

```typescript
// z.xor() - fails if zero or more than one match
const PaymentMethod = z.xor([
  z.object({ type: z.literal("card"), cardNumber: z.string() }),
  z.object({ type: z.literal("bank"), accountNumber: z.string() }),
]);
```

**Exact optional (v4.3+):**

```typescript
const Schema = z.object({
  name: z.string(),
  nickname: z.string().optional(),         // accepts undefined
  middleName: z.string().exactOptional(),  // rejects undefined, allows omission
});

Schema.parse({ name: "Alice" });                       // ✅
Schema.parse({ name: "Alice", nickname: undefined });  // ✅
Schema.parse({ name: "Alice", middleName: undefined }); // ❌
```

**Composable transforms with .apply() (v4.3+):**

```typescript
const withPositiveConstraint = <T extends z.ZodNumber>(schema: T) => {
  return schema.min(0).max(1_000_000);
};

const AmountSchema = z.number().apply(withPositiveConstraint).nullable();

const withTrimAndLowercase = <T extends z.ZodString>(schema: T) => {
  return schema.trim().toLowerCase();
};

const EmailSchema = z.string().email().apply(withTrimAndLowercase);
```

**Type predicates in refinements (v4.3+):**

```typescript
const AdminUser = z.object({
  role: z.string(),
  permissions: z.array(z.string()),
}).refine((user): user is { role: "admin"; permissions: string[] } =>
  user.role === "admin"
);

type AdminOutput = z.output<typeof AdminUser>; // { role: "admin"; permissions: string[] }
```

**Loose records (v4.3+):**

```typescript
// Only validates keys matching the pattern, passes through others
const EnvVars = z.looseRecord(
  z.string().regex(/^APP_/),
  z.string()
);

EnvVars.parse({ APP_NAME: "myapp", OTHER: 123 });
// ✅ { APP_NAME: "myapp", OTHER: 123 }
```

**Enum with values:**

```typescript
export const AssetTypeValues = ["deposit", "bond", "equity"] as const;

export const AssetTypeEnum = z.enum(AssetTypeValues).meta({
  description: "Type of tokenized asset",
  examples: ["bond", "equity"],
});

export type AssetType = z.infer<typeof AssetTypeEnum>;
```
</patterns>

<constraints>
**Banned:**
- `.describe()` (use `.meta()` - Zod v4 pattern)
- `.pick()`, `.omit()`, `.extend()` on refined schemas (split base first)
- `any` without justification
- Duplicate schemas (import from shared location)
- Re-exports via barrel files (import from canonical source)

**Required:**
- Use `.meta({ description, examples })` on all schemas
- Export inferred types with `z.infer<>`
- Export input/output types for transforms: `z.input<>`, `z.output<>`
- Split base and refined schemas when using `.pick()`, `.omit()`, `.extend()`
- Use `z.xor()` for exclusive unions (exactly one match required)
- Use `.exactOptional()` for properties that can be omitted but not `undefined`
- Write tests for all schemas

**Naming:** Schema files=`lowercase-with-hyphens.ts`
</constraints>

<success_criteria>
- [ ] Context7 docs fetched for current v4 API
- [ ] Uses `.meta({ description, examples })` (not `.describe()`)
- [ ] Exports inferred types with `z.infer<>`
- [ ] Base and refined schemas split for composition
- [ ] Uses v4.3+ features: `z.xor()`, `.exactOptional()`, `.apply()`
- [ ] Has unit tests for valid/invalid cases
</success_criteria>
