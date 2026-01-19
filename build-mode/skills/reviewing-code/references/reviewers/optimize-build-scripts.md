# Optimize build scripts

> **Repository:** vuejs/core
> **Dependencies:** @graphql-typed-document-node/core

Improve CI/CD pipeline efficiency by optimizing package.json scripts. Run compatible tasks in parallel using pattern matching capabilities of your package manager, and implement thorough cleanup scripts that remove all build artifacts and caches. This reduces build times and ensures consistent build environments.

```json
{
  "scripts": {
    // Run multiple lint tasks in parallel
    "lint": "pnpm run \"/^lint:eslint|^lint:ox/\"",
    
    // Comprehensive cleanup of all build artifacts and caches
    "clean": "rimraf packages/*/dist temp .eslintcache"
  }
}
```