# consistent spacing patterns

> **Repository:** prettier/prettier
> **Dependencies:** prettier

Maintain consistent spacing patterns around operators, keywords, and interpolation syntax throughout the codebase. This improves readability and reduces cognitive load when scanning code.

Key guidelines:
- Place binary operators at the beginning of new lines in multiline expressions for better visual alignment
- Add spaces after keywords like `new` to distinguish them from method calls: `new (x: number) => void`
- Maintain consistent spacing within interpolation syntax - either `#{$variable}` or `#{ $variable }` but not mixed usage
- Apply the same spacing rules consistently across similar language constructs

Example of good operator placement:
```javascript
const result = someCondition
  && anotherLongCondition
  || fallbackCondition;
```

Example of consistent interpolation spacing:
```scss
// Consistent - no spaces
.icon-#{$size} { }
.text-#{$name} { }

// Consistent - with spaces  
.icon-#{ $size } { }
.text-#{ $name } { }
```

This consistency helps establish clear visual patterns that make code easier to read and maintain, while reducing debates about formatting during code reviews.