# Write readable conditionals

> **Repository:** facebook/react
> **Dependencies:** @testing-library/react, @types/react, react

Structure conditionals for maximum clarity and comprehension. Avoid unnecessary negation in boolean expressions, use else clauses appropriately, and organize compound conditions to reduce cognitive load.

For JSX conditionals, prefer positive conditions with natural reading order:

```jsx
// Instead of:
<h1>{!show ? 'A' + counter : 'B' + counter}</h1>

// Prefer:
<h1>{show ? 'B' + counter : 'A' + counter}</h1>
```

For branching logic, use complete if/else structures rather than separate conditional blocks when checking for mutually exclusive conditions:

```javascript
// Instead of:
if (enableUnifiedSyncLane && (renderLane & SyncUpdateLanes) !== NoLane) {
  lane = SyncHydrationLane;
}
if (!lane) {
  // ...more code
}

// Prefer:
if (enableUnifiedSyncLane && (renderLane & SyncUpdateLanes) !== NoLane) {
  lane = SyncHydrationLane;
} else {
  // ...more code
}
```

These practices make code easier to scan, understand, and maintain, while reducing the potential for logical errors.