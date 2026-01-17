# Angular syntax parsing

> **Repository:** prettier/prettier
> **Dependencies:** prettier

When implementing Angular syntax parsing, ensure robust handling of Angular-specific constructs by properly distinguishing AST node types and normalizing flexible syntax patterns.

For AST visitor keys, only include actual Node objects, not primitive values:
```javascript
// Correct - empty array since name and value are strings, not nodes
angularLetDeclaration: [],

// Incorrect - includes non-node primitives
angularLetDeclaration: ["name", "value"],
```

For Angular control flow blocks, normalize whitespace in block names to handle flexible syntax:
```javascript
// Should handle both:
@else if () {}        // standard spacing
@else   if () {}      // flexible whitespace

// Implementation should normalize "else   if" → "else if"
```

This ensures the parser correctly processes Angular's flexible syntax while maintaining proper AST structure for tooling compatibility.