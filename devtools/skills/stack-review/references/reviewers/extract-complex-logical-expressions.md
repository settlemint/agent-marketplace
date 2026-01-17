# Extract complex logical expressions

> **Repository:** microsoft/typescript
> **Dependencies:** typescript

Complex logical expressions should be extracted into well-named variables or functions to improve code readability and maintainability. This applies to:
- Boolean conditions with multiple parts
- Repeated logic across multiple locations
- Complex property access chains

Example - Before:
```typescript
const classOrInterfaceDeclaration = declaration.parent?.kind === SyntaxKind.Constructor && getSyntacticModifierFlags(declaration) & ModifierFlags.AccessibilityModifier ? declaration.parent.parent : declaration.parent;
```

Example - After:
```typescript
const isConstructorParamWithAccessModifier = declaration.parent?.kind === SyntaxKind.Constructor && 
    getSyntacticModifierFlags(declaration) & ModifierFlags.AccessibilityModifier;
const classOrInterfaceDeclaration = isConstructorParamWithAccessModifier ? declaration.parent.parent : declaration.parent;
```

The extracted variable name should clearly describe the condition's purpose. For frequently used conditions, consider extracting them into helper functions that can be reused across the codebase.