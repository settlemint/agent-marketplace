# Database schema consistency

> **Repository:** ClickHouse/ClickHouse
> **Dependencies:** @core/database, @dalp/database

Ensure database operations maintain consistent behavior and ordering, especially in distributed systems. When working with data structures that affect schema representation or query results, prioritize deterministic ordering over performance optimizations to prevent schema mismatches and ensure reliable distributed operations.

Key considerations:
- Use ordered containers (like `std::map`) instead of unordered ones (`absl::flat_hash_map`) when column ordering affects schema equality or distributed consistency
- Avoid ignoring important write modes or operations that could affect data integrity
- Ensure virtual columns and metadata operations have consistent, well-defined semantics
- Validate that query optimizations don't change correctness of results

Example from the codebase:
```cpp
// Before: Unordered map causing schema mismatches
absl::flat_hash_map<std::string_view, std::string_view> & map;

// After: Ordered map ensuring consistent schema representation
std::map<std::string_view, std::string_view> & map;
```

This prevents distributed systems from encountering schema mismatch exceptions due to inconsistent column ordering in operations like `ColumnsDescription::toString()` equality checks.