# Complete deployment commands

> **Repository:** vitejs/vite
> **Dependencies:** @tailwindcss/vite, vite

Always ensure build commands in CI/CD configurations include all necessary steps for successful deployment, particularly dependency installation. Incomplete commands are a common source of deployment failures.

For platform-specific deployments (like Render), use the complete sequence of commands:

```
npm install && npm run build
```

Rather than incomplete commands:

```
npm run build
```

This ensures dependencies are installed before the build process begins, preventing failures due to missing packages in clean CI environments.