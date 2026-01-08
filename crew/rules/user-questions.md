---
description: User interaction requirements for commands
globs: "**/commands/**/*.md"
alwaysApply: true
---

# User Question Requirements

## Critical Rule

**NEVER output plain text questions. Use AskUserQuestion tool for all user choices.**

## Why

- Plain text questions get lost in output
- AskUserQuestion provides structured UI with selectable options
- Ensures consistent user experience across all commands

## Correct Pattern

```javascript
AskUserQuestion({
  questions: [
    {
      question: "What would you like to do?",
      header: "Action",
      options: [
        { label: "Option A", description: "Does X" },
        { label: "Option B", description: "Does Y" },
      ],
      multiSelect: false,
    },
  ],
});
```

## Wrong Pattern

```
// DON'T DO THIS
console.log("What would you like to do?");
console.log("1. Option A");
console.log("2. Option B");
```
