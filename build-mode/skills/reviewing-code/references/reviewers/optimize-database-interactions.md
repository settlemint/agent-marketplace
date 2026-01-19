# Optimize database interactions

> **Repository:** oven-sh/bun
> **Dependencies:** @types/bun

When working with database operations, prioritize efficiency by avoiding redundant query executions. Instead of executing statements multiple times to gather different pieces of information (like metadata or column types), cache or collect all necessary data during the initial execution.

For example, when working with SQLite prepared statements and needing column types:

```cpp
// Instead of this:
sqlite3_reset(stmt);
sqlite3_step(stmt);
// Now get column types...

// Do this:
// During initial execution:
if (sqlite3_step(stmt) == SQLITE_ROW) {
  // Store column types while processing the result
  for (int i = 0; i < columnCount; i++) {
    columnTypes[i] = sqlite3_column_type(stmt, i);
  }
  // Continue with normal row processing...
}
```

This approach is especially important for potentially expensive queries, as redundant executions can significantly impact performance. Additionally, when working with database APIs, be mindful of version-specific constants and methods (like `SQLITE_TEXT` vs. `SQLITE3_TEXT`), particularly in codebases that might interact with multiple versions of the same database system.