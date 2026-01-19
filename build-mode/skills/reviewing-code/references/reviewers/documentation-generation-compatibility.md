# documentation generation compatibility

> **Repository:** remix-run/react-router
> **Dependencies:** @tanstack/react-router

When making code changes, ensure compatibility with documentation generation tools like JSDoc and TypeDoc. This includes: (1) Exporting types that should appear in generated documentation, (2) Avoiding duplicate exports across modules that can confuse documentation parsers, and (3) Formatting code examples appropriately for documentation rendering.

For exports, make sure types intended for public API documentation are properly exported:
```ts
export type {
  AwaitProps,
  IndexRouteProps,
  LayoutRouteProps,
  MemoryRouterOpts, // Export so typedoc picks it up
}
```

For code examples in JSDoc, handle existing markdown formatting to prevent double-wrapping:
```ts
markdown += example.includes("```")
  ? `${example}\n\n`
  : `\`\`\`tsx\n${example}\n\`\`\`\n\n`;
```

When creating nested modules, update documentation generation scripts to handle the new structure and prevent conflicts from duplicate component names across modules.