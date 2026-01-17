# Escape HTML content properly

> **Repository:** vitejs/vite
> **Dependencies:** @tailwindcss/vite, vite

Always use specialized HTML escaping functions when outputting dynamic content to prevent Cross-Site Scripting (XSS) vulnerabilities. Don't rely on general serialization methods like JSON.stringify which may not correctly escape all HTML-sensitive characters or may add unnecessary escapes.

When working with HTML attribute values:

```javascript
// Incorrect: Using JSON.stringify for HTML attributes
res += ` ${key}=${JSON.stringify(attrs[key])}`

// Correct: Using dedicated HTML escaping
res += ` ${key}="${escapeHtml(attrs[key])}"`
```

This approach ensures all potentially dangerous characters are properly escaped before being inserted into HTML, preventing script injection attacks while avoiding unnecessary character escaping that could affect functionality or readability.