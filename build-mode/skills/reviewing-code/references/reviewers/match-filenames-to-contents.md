# Match filenames to contents

> **Repository:** oven-sh/bun
> **Dependencies:** @types/bun

Files should be named to clearly reflect their primary contents:

1. When a file contains a single primary type:
   - Name the file exactly after the type
   - Use PascalCase for both the file and type names
   - Make the type the top-level struct

2. For utility/process files:
   - Use descriptive names that indicate the file's purpose
   - Avoid generic terms that could mean multiple things

Example:
```zig
// Good: HTTPThread.zig
const HTTPThread = @This();

// Bad: http_thread.zig
pub const HTTPThread = struct {

// Good: processDependencyList.zig
// Bad: process.zig (too generic)
```

This convention improves code navigation, maintains consistency, and makes the codebase more intuitive to work with. It also helps prevent confusion when multiple files could potentially have similar generic names.