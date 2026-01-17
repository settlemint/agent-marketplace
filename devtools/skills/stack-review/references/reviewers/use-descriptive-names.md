# Use descriptive names

> **Repository:** prettier/prettier
> **Dependencies:** prettier

Choose names that clearly communicate purpose and meaning rather than implementation details or obscure abbreviations. Names should be easily understood by other developers and reflect what the identifier actually represents or does.

For function parameters, use names that describe the data's role in the function rather than its source or format. For documentation and labels, prefer commonly understood terminology that developers can easily search for and recognize.

```javascript
// Avoid: implementation-focused names
function getPreferredQuote(rawContent: string) { ... }

// Prefer: purpose-focused names  
function getPreferredQuote(text: string) { ... }

// Avoid: obscure abbreviations
JS(ESM):

// Prefer: clear, searchable terms
JS (ES Modules):
```

This approach improves code readability, makes documentation more discoverable, and helps other developers quickly understand the purpose of variables, functions, and parameters.