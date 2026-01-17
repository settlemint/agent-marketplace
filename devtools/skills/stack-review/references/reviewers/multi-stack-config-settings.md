# Multi-stack config settings

> **Repository:** facebook/react
> **Dependencies:** @testing-library/react, @types/react, react

When creating configuration files for development environments that use multiple technology stacks, ensure settings are properly scoped to accommodate different file types and tools within the same project. This prevents validation errors and improves developer productivity.

For example, in a workspace with both Flow and TypeScript files, customize editor settings by file type:

```json
{
  "settings": {
    // General settings
    "editor.formatOnSave": true,
    
    // Tool-specific paths
    "flow.pathToFlow": "${workspaceFolder}/node_modules/.bin/flow",
    
    // Search optimization
    "search.exclude": {
      "**/dist/**": true,
      "**/build/**": true,
      "**/out/**": true
    },
    
    // File-type specific settings
    "prettier.configPath": "",
    "prettier.ignorePath": ""
  }
}
```

These scoped configurations ensure that the proper validation rules and formatting settings are applied to different parts of the codebase, making it easier for developers to work with mixed technology projects.