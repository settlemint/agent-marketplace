---
description: CRITICAL import rules - NO RE-EXPORTS EVER
globs: "**/*.ts,**/*.tsx,**/*.js,**/*.jsx,**/index.ts,**/index.js"
alwaysApply: false
---

# Import Rules

## ⛔ ABSOLUTE RULE - NO EXCEPTIONS ⛔

# NEVER RE-EXPORT. EVER. NO EXCEPTIONS.

**This is NON-NEGOTIABLE. Zero tolerance.**

## BANNED PATTERNS - INSTANT REJECTION

```typescript
// ❌ BANNED - Barrel file re-exports
// utils/index.ts
export * from "./validation";
export * from "./formatting";
export { helper } from "./helpers";

// ❌ BANNED - Alias re-exports
export { User as UserModel } from "./user";
export { default as Config } from "./config";

// ❌ BANNED - Convenience re-exports
// Don't create @app/shared that re-exports from @app/core
export { schema } from "@indexer/core/db/base-schema";

// ❌ BANNED - Index files that just re-export
// index.ts
export * from "./types";
export * from "./utils";
export * from "./components";

// ❌ BANNED - "Compatibility" re-exports after moving code
// OLD: Was in utils.ts, moved to helpers.ts
// DON'T DO: export { helper } from "./helpers"; // "for compatibility"
```

## THE ONLY CORRECT PATTERN

```typescript
// ✅ CORRECT - Direct import from canonical source
import { User } from "@app/core/models/user";
import { validateEmail } from "@app/utils/validation";
import { schema } from "@indexer/core/db/base-schema";

// ✅ CORRECT - Import from the actual file, not an index
import { Button } from "@app/components/Button";
// NOT: import { Button } from "@app/components";
```

## WHY THIS IS ABSOLUTE

1. **Circular dependencies** - Re-exports create hidden cycles
2. **Bundle size** - Tree-shaking fails with barrel files
3. **Build performance** - Each re-export doubles resolution work
4. **Debugging hell** - Stack traces point to wrong files
5. **Refactoring nightmare** - Can't safely move code
6. **Type inference** - TypeScript struggles with re-export chains

## WHEN MOVING CODE

When relocating code between modules:

1. **Update ALL consumers** to the new location
2. **Delete the old file completely**
3. **NEVER leave a re-export "for compatibility"**
4. **NEVER create a forwarding module**

```typescript
// ❌ NEVER DO THIS when moving code
// old-location.ts
export { thing } from "./new-location"; // "temporary compatibility"

// ✅ ALWAYS DO THIS
// 1. Move the code
// 2. Find all imports: grep -r "from.*old-location"
// 3. Update every single one
// 4. Delete old-location.ts entirely
```

## INDEX FILES

Index files (`index.ts`) should ONLY contain:

- **Original code** that belongs in that module
- **Type definitions** specific to that module
- **NOTHING ELSE**

```typescript
// ✅ ACCEPTABLE index.ts
export interface ModuleConfig {
  // actual type definition
}

export function moduleFunction() {
  // actual implementation
}

// ❌ UNACCEPTABLE index.ts
export * from "./types";
export * from "./utils";
export { Component } from "./Component";
```

## ONE SOURCE OF TRUTH

Every piece of code has ONE canonical location. Import from that location.

- If it's in `@indexer/core`, import from `@indexer/core`
- If it's in `@app/utils/validation`, import from `@app/utils/validation`
- **No intermediate layers**
- **No convenience wrappers**
- **No "local copies"**

## ENFORCEMENT

This rule is enforced by:

- ESLint `no-restricted-exports` rule
- Import cycle detection in CI
- Code review requirements
- Bundle analysis checks

**Violations will cause CI failures and blocked PRs.**
