# Evolve APIs with compatibility

> **Repository:** vitejs/vite
> **Dependencies:** @tailwindcss/vite, vite

When evolving APIs, maintain backwards compatibility while introducing new features by following a staged deprecation approach:

1. Introduce new APIs alongside existing ones without deprecation warnings
2. Enable opt-in deprecation warnings in minor versions
3. Add breaking changes behind feature flags
4. Remove deprecated features in major versions

Example:
```typescript
// Stage 1: Add new API alongside existing
interface Config {
  // Existing API
  ssrLoadModule(url: string): Promise<Module>
  
  // New API
  environments: {
    ssr: {
      moduleGraph: ModuleGraph
      loadModule(url: string): Promise<Module>
    }
  }
}

// Stage 2: Add deprecation warning system
interface FutureOptions {
  deprecationWarnings?: boolean | {
    ssrLoadModule?: boolean
  }
}

// Stage 3: Feature flags for breaking changes
interface Config {
  future?: {
    // Opt-in to new behavior
    useEnvironmentAPI?: boolean
  }
}
```

This approach allows users to migrate at their own pace while maintaining a clear upgrade path. Document both old and new APIs until deprecation is complete, and provide migration guides that explain the benefits of new approaches.