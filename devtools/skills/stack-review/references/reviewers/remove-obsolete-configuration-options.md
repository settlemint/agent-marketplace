# Remove obsolete configuration options

> **Repository:** remix-run/react-router
> **Dependencies:** @tanstack/react-router

Proactively remove configuration options that are no longer functional or relevant to prevent developer confusion and potential bugs. When configuration options become obsolete due to architectural changes or package migrations, removing them from type definitions and interfaces is preferable to keeping them as non-functional placeholders.

This approach provides several benefits:
- Prevents developers from using non-functional configuration
- Surfaces potential bugs through compile-time errors rather than silent failures
- Maintains clean, accurate configuration interfaces
- Guides developers toward correct alternatives

For example, when a timeout configuration becomes non-functional:
```typescript
// Before: Keeping obsolete option
export interface ServerRouterProps {
  context: EntryContext;
  url: string | URL;
  abortDelay?: number; // Non-functional but still present
}

// After: Remove and force migration
export interface ServerRouterProps {
  context: EntryContext;
  url: string | URL;
  // Use streamTimeout instead of abortDelay
}
```

Similarly, when packages become obsolete due to tooling changes, update imports and remove references:
```typescript
// Before: Obsolete package import
import { cssBundleHref } from "@remix-run/css-bundle";

// After: Updated or removed based on new tooling
// Package removed as it's obsolete in vite-only environments
```

The resulting TypeScript errors serve as helpful migration guides, alerting developers to update their configuration and fix potential functional issues.