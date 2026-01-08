---
description: Import patterns and module organization
globs: "**/*.ts,**/*.tsx"
alwaysApply: false
---

# Import Rules

## No Re-exports

**NEVER RE-EXPORT. EVER. NO EXCEPTIONS.**

- **NEVER** create barrel files that re-export from other packages
- **NEVER** create `index.ts` files that just re-export other modules
- **NEVER** create wrapper modules that re-export with aliases
- **ALWAYS** import directly from the canonical source

## Why

- Re-exports create circular dependency risks
- Re-exports hide the true source of code
- Re-exports make tree-shaking less effective
- Re-exports complicate refactoring

## Correct Pattern

```typescript
// GOOD - Direct imports from source
import { User } from "@app/core/models/user";
import { validateEmail } from "@app/utils/validation";
```

## Wrong Patterns

```typescript
// BAD - Barrel file re-export
// utils/index.ts
export * from "./validation";
export * from "./formatting";
export * from "./helpers";

// BAD - Alias re-export
// models/index.ts
export { User as UserModel } from "./user";

// BAD - Convenience re-export
// Don't create @app/shared that re-exports from @app/core
```

## Monorepo Imports

In monorepos, always use the package path:

```typescript
// GOOD
import { schema } from "@indexer/core/db/base-schema";

// BAD - local re-export of external package
import { schema } from "./re-exports/core";
```

## Moving Code

When moving code between modules:

1. Update ALL consumers to new location
2. Delete old file completely
3. **NEVER** leave re-export for "compatibility"
