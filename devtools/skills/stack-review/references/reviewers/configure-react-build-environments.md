# Configure React build environments

> **Repository:** remix-run/react-router
> **Dependencies:** @tanstack/react-router

Ensure proper environment and module configuration for React applications to load the correct versions and entrypoints across different build contexts. This includes setting NODE_ENV appropriately and configuring import paths for optimal React loading.

For environment configuration, set NODE_ENV before React initialization to ensure the proper version loads:
```javascript
// Set NODE_ENV before calling CLI or initializing React
process.env.NODE_ENV = process.env.NODE_ENV ?? "production";
```

For build tooling, configure import paths to point to appropriate React entrypoints:
```javascript
// In build configuration (e.g., rollup.config.js)
paths: {
  "react-router": "./index.mjs",
}
```

This prevents issues where React loads incorrect versions or modules, which can cause runtime errors or suboptimal performance. Always verify that your build configuration explicitly handles React's environment-specific loading behavior.