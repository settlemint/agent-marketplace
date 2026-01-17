# Implement recursive safeguards

> **Repository:** remix-run/react-router
> **Dependencies:** @tanstack/react-router

When implementing recursive algorithms, always include cycle detection and early termination conditions to prevent infinite recursion and improve performance. This is especially critical in graph traversal, AST processing, and dependency analysis where circular references can occur.

Key safeguards to implement:
1. **Visited set tracking**: Maintain a set of already-processed nodes/paths
2. **Early returns**: Skip processing if an item has already been handled
3. **Cycle detection**: Check for circular dependencies before recursing

Example from AST traversal:
```ts
function getDependentIdentifiersForPath(path, { visited, identifiers }) {
  // Ensure we don't recurse indefinitely
  if (visited.has(path)) {
    return identifiers;
  }
  
  visited.add(path);
  
  // We can skip all of this work if we've already processed this identifier
  if (identifiers.has(path)) {
    return;
  }
  
  // Continue with recursive processing...
}
```

Consider the algorithmic complexity and don't assume data structures are in any particular order. Design algorithms that can handle arbitrary arrangements and potential cycles, as this adds minimal cost while significantly improving robustness.