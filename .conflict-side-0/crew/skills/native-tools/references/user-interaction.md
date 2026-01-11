# User Interaction Tools

## AskUserQuestion — Structured Input Gathering

**The most important tool for user interaction.** Presents visual buttons with descriptions instead of text-based menus.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `questions` | array | Yes | 1-4 questions to ask |

### Question Structure

```javascript
{
  question: "Clear question ending with ?",
  header: "ShortTag",    // Max 12 chars, displayed as chip
  options: [             // 2-4 options
    {
      label: "Option Name",
      description: "What this option does"
    }
  ],
  multiSelect: false     // true allows multiple selections
}
```

### Best Practices

```javascript
// GOOD: Clear question with helpful descriptions
AskUserQuestion({
  questions: [{
    question: "Which authentication method should we use?",
    header: "Auth",
    options: [
      {label: "JWT (Recommended)", description: "Stateless, scalable, industry standard"},
      {label: "Session cookies", description: "Simple, works with SSR"},
      {label: "OAuth only", description: "Delegate to third-party providers"}
    ],
    multiSelect: false
  }]
})

// GOOD: Multiple questions at once (gather context upfront)
AskUserQuestion({
  questions: [
    {
      question: "What's the target environment?",
      header: "Environment",
      options: [
        {label: "Production", description: "Full optimization, security hardening"},
        {label: "Staging", description: "Production-like testing"},
        {label: "Development", description: "Fast iteration, debug tools"}
      ],
      multiSelect: false
    },
    {
      question: "Which features should we include?",
      header: "Features",
      options: [
        {label: "Authentication", description: "User login/signup"},
        {label: "API routes", description: "REST endpoints"},
        {label: "Database", description: "PostgreSQL setup"},
        {label: "Caching", description: "Redis integration"}
      ],
      multiSelect: true  // Allow multiple selections
    }
  ]
})

// GOOD: Recommended option first with marker
AskUserQuestion({
  questions: [{
    question: "How should we handle the migration?",
    header: "Migration",
    options: [
      {label: "Incremental (Recommended)", description: "Safe, reversible, deploy anytime"},
      {label: "Big bang", description: "Faster but riskier"},
      {label: "Feature flag", description: "Gradual rollout with kill switch"}
    ],
    multiSelect: false
  }]
})
```

### Anti-Patterns

```javascript
// BAD: Text-based menu (never do this)
"Please choose:
1. Option A
2. Option B
3. Option C
Enter 1, 2, or 3:"

// BAD: Too many options (max 4)
AskUserQuestion({
  questions: [{
    options: [{...}, {...}, {...}, {...}, {...}, {...}]  // 6 options
  }]
})

// BAD: Vague descriptions
options: [
  {label: "Option A", description: "Does things"},
  {label: "Option B", description: "Different things"}
]

// BAD: Missing question mark
question: "Which approach"  // Should end with ?

// BAD: Header too long
header: "Authentication Method"  // Max 12 chars
```

### Common Use Cases

```javascript
// Decision point in workflow
AskUserQuestion({
  questions: [{
    question: "Tests passed. Ready to proceed?",
    header: "Next Step",
    options: [
      {label: "Create PR (Recommended)", description: "Push and open pull request"},
      {label: "Commit only", description: "Create commit without PR"},
      {label: "Review diff", description: "Show changes before committing"}
    ],
    multiSelect: false
  }]
})

// Clarify ambiguous request
AskUserQuestion({
  questions: [{
    question: "What type of component should I create?",
    header: "Component",
    options: [
      {label: "React functional", description: "Modern hooks-based component"},
      {label: "React class", description: "Legacy class component"},
      {label: "Vue SFC", description: "Single file component"}
    ],
    multiSelect: false
  }]
})

// Multi-select for features
AskUserQuestion({
  questions: [{
    question: "Which reviewers should analyze this code?",
    header: "Reviewers",
    options: [
      {label: "TypeScript", description: "Type safety and patterns"},
      {label: "Security", description: "Vulnerability scanning"},
      {label: "Performance", description: "Optimization opportunities"},
      {label: "Architecture", description: "Design patterns"}
    ],
    multiSelect: true
  }]
})
```

---

## TodoWrite — Task Tracking

Creates and manages structured task lists for progress tracking.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `todos` | array | Yes | Array of todo items |

### Todo Item Structure

```javascript
{
  content: "Task description (imperative)",      // "Run tests"
  activeForm: "Task in progress (continuous)",   // "Running tests"
  status: "pending" | "in_progress" | "completed"
}
```

### Best Practices

```javascript
// GOOD: Create task list for multi-step work
TodoWrite({
  todos: [
    {content: "Read and analyze requirements", status: "completed", activeForm: "Analyzing requirements"},
    {content: "Implement authentication", status: "in_progress", activeForm: "Implementing authentication"},
    {content: "Write tests", status: "pending", activeForm: "Writing tests"},
    {content: "Update documentation", status: "pending", activeForm: "Updating documentation"}
  ]
})

// GOOD: Mark task complete and start next
TodoWrite({
  todos: [
    {content: "Implement authentication", status: "completed", activeForm: "Implementing authentication"},
    {content: "Write tests", status: "in_progress", activeForm: "Writing tests"},
    {content: "Update documentation", status: "pending", activeForm: "Updating documentation"}
  ]
})

// GOOD: Add discovered tasks
TodoWrite({
  todos: [
    {content: "Implement authentication", status: "completed", activeForm: "Implementing authentication"},
    {content: "Fix type error in auth module", status: "in_progress", activeForm: "Fixing type error"},
    {content: "Write tests", status: "pending", activeForm: "Writing tests"},
    {content: "Update documentation", status: "pending", activeForm: "Updating documentation"}
  ]
})
```

### When to Use TodoWrite

| Scenario | Use TodoWrite? |
|----------|---------------|
| 3+ step task | Yes |
| Complex implementation | Yes |
| User provided list of tasks | Yes |
| Single, simple task | No |
| Quick question answer | No |
| Trivial change | No |

### Anti-Patterns

```javascript
// BAD: Not updating status immediately
// Complete task, wait, then batch update
// GOOD: Mark complete right after finishing

// BAD: Multiple in_progress tasks
todos: [
  {content: "Task A", status: "in_progress", ...},
  {content: "Task B", status: "in_progress", ...}  // Only ONE in_progress
]

// BAD: Marking incomplete task as completed
// If tests fail, keep in_progress and add fix task

// BAD: Missing activeForm
todos: [
  {content: "Run tests", status: "in_progress"}  // Missing activeForm
]
```

### Common Patterns

```javascript
// Break down feature implementation
TodoWrite({
  todos: [
    {content: "Create database schema", status: "in_progress", activeForm: "Creating database schema"},
    {content: "Implement API endpoints", status: "pending", activeForm: "Implementing API endpoints"},
    {content: "Add frontend components", status: "pending", activeForm: "Adding frontend components"},
    {content: "Write integration tests", status: "pending", activeForm: "Writing integration tests"},
    {content: "Run CI pipeline", status: "pending", activeForm: "Running CI pipeline"}
  ]
})

// Track bug fixes from review
TodoWrite({
  todos: [
    {content: "Fix type error in auth.ts:42", status: "in_progress", activeForm: "Fixing type error"},
    {content: "Add null check in user.ts:88", status: "pending", activeForm: "Adding null check"},
    {content: "Remove unused import in api.ts", status: "pending", activeForm: "Removing unused import"}
  ]
})
```

---

## Combining Tools

### Decision → Action Flow

```javascript
// 1. Ask for direction
AskUserQuestion({
  questions: [{
    question: "How should we proceed with the refactoring?",
    header: "Approach",
    options: [
      {label: "Incremental (Recommended)", description: "One file at a time"},
      {label: "Complete rewrite", description: "All at once"}
    ],
    multiSelect: false
  }]
})

// 2. Based on response, create task list
TodoWrite({
  todos: [
    {content: "Refactor auth module", status: "in_progress", activeForm: "Refactoring auth module"},
    {content: "Refactor user module", status: "pending", activeForm: "Refactoring user module"},
    {content: "Run test suite", status: "pending", activeForm: "Running test suite"}
  ]
})

// 3. Work through tasks, updating as you go
```

### Validation Before Proceeding

```javascript
// After completing work
AskUserQuestion({
  questions: [{
    question: "All changes are ready. What's next?",
    header: "Ship",
    options: [
      {label: "Create PR (Recommended)", description: "Commit, push, open PR"},
      {label: "Commit only", description: "Save without PR"},
      {label: "Review changes", description: "Show diff first"},
      {label: "More work needed", description: "Continue editing"}
    ],
    multiSelect: false
  }]
})
```
