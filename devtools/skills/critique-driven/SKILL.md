---
name: critique-driven
description: Convert code review feedback into actionable prompts. Transform PR comments, review suggestions, and critique into systematic improvements.
license: MIT
triggers:
  # Intent triggers
  - "address review"
  - "fix feedback"
  - "respond to comments"
  - "reviewer said"
  - "PR feedback"
  - "review suggestions"

  # Artifact triggers
  - "code review"
  - "PR comment"
  - "review thread"
  - "requested changes"
  - "needs work"
  - "LGTM with comments"
---

<objective>
Transform code review feedback into precise, actionable implementation prompts. Every piece of critique becomes a targeted improvement — no feedback is lost or vaguely addressed.
</objective>

<essential_principles>

- Extract specific, actionable issues from review comments
- Transform vague feedback into concrete prompts
- Verify each fix addresses the reviewer's intent
- Close feedback loops by documenting resolution
- Learn from patterns in recurring feedback
</essential_principles>

<constraints>
**Banned:**
- Dismissing feedback without addressing the underlying concern
- Making changes that don't match reviewer intent
- Marking feedback resolved without verification
- Batch-addressing feedback without individual tracking

**Required:**

- Quote original feedback when implementing fix
- Verify fix matches reviewer's intent
- Document how each comment was addressed
- Request clarification for ambiguous feedback
</constraints>

<anti_patterns>

- **Surface Fixes:** Changing what was pointed at, not the underlying issue
- **Interpretation Drift:** Assuming you know what reviewer meant without checking
- **Silent Resolution:** Marking threads resolved without explaining the fix
- **Defensive Dismissal:** Explaining why feedback is wrong instead of considering it
- **Batch Blur:** Addressing "all the feedback" without tracking individual items
</anti_patterns>

<quick_start>
**Critique-driven workflow:**

1. **Extract** — Pull each review comment into a structured list
2. **Categorize** — Type of feedback (bug, style, architecture, question)
3. **Translate** — Convert vague feedback to concrete prompt
4. **Implement** — Apply targeted fix for each item
5. **Verify** — Confirm fix matches reviewer's intent
6. **Document** — Reply with what was done
</quick_start>

<feedback_extraction>
**Structured extraction from PR reviews:**

```markdown
## Review Feedback Tracker

### Comment 1: [File:Line]
**Original:** "This function is getting too complex"
**Type:** Architecture
**Translated Prompt:** Refactor `processOrder()` to reduce cyclomatic complexity. Extract validation, calculation, and persistence into separate functions.
**Status:** [ ] Pending

### Comment 2: [File:Line]
**Original:** "Could this cause a race condition?"
**Type:** Bug/Concern
**Translated Prompt:** Analyze `updateCounter()` for race conditions. Add mutex or use atomic operations if concurrent access possible.
**Status:** [ ] Pending
```

**Extraction questions:**

- What specific code is being referenced?
- What is the reviewer's concern or suggestion?
- What would "addressed" look like?
- Is clarification needed before acting?
</feedback_extraction>

<translating_vague_feedback>
**Common vague feedback and concrete translations:**

| Vague Feedback | Concrete Prompt |
|----------------|-----------------|
| "This is confusing" | Rename variables for clarity, add explanatory comment, or simplify logic |
| "Can we simplify this?" | Reduce nesting, extract helper, remove redundant code |
| "Feels like a code smell" | Identify which smell (duplication, long method, etc.) and refactor accordingly |
| "Not sure about this approach" | Document trade-offs, suggest alternative, or request specific concern |
| "This could be cleaner" | Apply single responsibility, reduce dependencies, improve naming |
| "Performance concern" | Add benchmark, identify O(n) operations, suggest optimization |
| "Error handling?" | Add try/catch, handle edge cases, add validation |

**When feedback is truly unclear:**

```markdown
@reviewer I want to make sure I address your concern correctly.
When you say "[quote feedback]", are you suggesting:
A) [interpretation 1]
B) [interpretation 2]
C) Something else?
```

</translating_vague_feedback>

<implementation_pattern>
**For each feedback item:**

```typescript
// FEEDBACK: "This function does too much" - @reviewer
// TRANSLATION: Extract validation into separate function
// BEFORE: Single 50-line function
// AFTER: 3 focused functions

// Original monolithic function
function processOrder(order: Order) {
  // 50 lines of mixed concerns
}

// Refactored per feedback
function validateOrder(order: Order): ValidationResult { ... }
function calculateTotal(order: Order): number { ... }
function persistOrder(order: Order): Promise<void> { ... }

function processOrder(order: Order) {
  const validation = validateOrder(order);
  if (!validation.valid) return validation;
  const total = calculateTotal(order);
  return persistOrder({ ...order, total });
}
```

**Resolution comment:**

```markdown
Addressed in [commit]: Extracted `processOrder()` into three focused functions:
- `validateOrder()` - Input validation
- `calculateTotal()` - Price calculation
- `persistOrder()` - Database operations

Each function now has single responsibility. Cyclomatic complexity reduced from 12 to 3 per function.
```

</implementation_pattern>

<few_shot_examples>
<example name="complexity-feedback">
<input>
Review comment: "This nested if-else is hard to follow"
```javascript
if (user.isActive) {
  if (user.hasPermission) {
    if (order.isValid) {
      // process
    } else {
      throw new Error('Invalid order');
    }
  } else {
    throw new Error('No permission');
  }
} else {
  throw new Error('User inactive');
}
```
</input>
<output>
**Extracted feedback:**
- Type: Code clarity
- Concern: Nested conditionals reduce readability
- Translated prompt: Flatten nested if-else using early returns (guard clauses)

**Implementation:**
```javascript
// Guard clauses - fail fast
if (!user.isActive) {
  throw new Error('User inactive');
}
if (!user.hasPermission) {
  throw new Error('No permission');
}
if (!order.isValid) {
  throw new Error('Invalid order');
}

// Happy path - clear and flat
// process order
```

**Resolution:** Refactored to guard clause pattern. Nesting depth reduced from 4 to 1. Each validation condition is now explicit and early-exit.
</output>
<reasoning>Feedback translated from "hard to follow" to specific refactoring pattern. Resolution documents the structural change.</reasoning>
</example>

<example name="ambiguous-feedback">
<input>Review comment: "I'm not sure this is the right approach"</input>
<output>
**Extracted feedback:**
- Type: Architecture concern
- Concern: Unclear - needs clarification
- Translated prompt: Cannot translate without more context

**Clarification request:**
```markdown
@reviewer Thanks for flagging this. To address your concern properly, could you
clarify what aspect you're uncertain about?

1. The data flow pattern (fetching then transforming)?
2. The caching strategy (in-memory vs Redis)?
3. The error handling approach?
4. Something else?

Happy to discuss trade-offs or explore alternatives once I understand the
specific concern.
```
</output>
<reasoning>Ambiguous feedback requires clarification before implementation. Asking structured questions accelerates resolution.</reasoning>
</example>

<example name="security-feedback">
<input>Review comment: "SQL injection risk here"</input>
<output>
**Extracted feedback:**
- Type: Security bug
- Concern: User input concatenated into SQL query
- Translated prompt: Replace string concatenation with parameterized query

**Implementation:**
```typescript
// BEFORE (vulnerable)
const query = `SELECT * FROM users WHERE id = '${userId}'`;

// AFTER (parameterized)
const query = sql`SELECT * FROM users WHERE id = ${userId}`;
// Or with explicit parameter binding:
const result = await db.query(
  'SELECT * FROM users WHERE id = $1',
  [userId]
);
```

**Resolution:** Fixed SQL injection vulnerability by using parameterized queries. User input is now properly escaped by the database driver. Added test case for special characters in input.
</output>
<reasoning>Security feedback translated to specific fix. Resolution includes verification (test case).</reasoning>
</example>
</few_shot_examples>

<learning_from_patterns>
**Track recurring feedback to prevent future occurrences:**

```markdown
## Feedback Pattern Log

### Pattern: "Missing error handling"
- Occurrences: 3 times in last 5 PRs
- Root cause: No linter rule for try/catch in async functions
- Prevention: Add eslint rule `require-await` and error boundary pattern

### Pattern: "Function too long"
- Occurrences: 2 times
- Root cause: Not extracting helpers proactively
- Prevention: Self-review checklist item for function length
```

**Questions to ask after repeated feedback:**

- Is there a lint rule that could catch this?
- Should this be in our coding standards?
- Is there a structural change that prevents this class of issue?
</learning_from_patterns>

<github_integration>
**Fetching PR review comments:**

```typescript
// Get review comments for current PR
const comments = await gh.api(`repos/{owner}/{repo}/pulls/{pr}/comments`);

// Get review threads
const reviews = await gh.api(`repos/{owner}/{repo}/pulls/{pr}/reviews`);

// Structure for tracking
interface FeedbackItem {
  id: string;
  file: string;
  line: number;
  body: string;
  author: string;
  type: 'bug' | 'style' | 'architecture' | 'question' | 'nitpick';
  status: 'pending' | 'in_progress' | 'resolved' | 'wont_fix';
  resolution?: string;
}
```

</github_integration>

<related_skills>

**PR workflow:** Load via `Skill({ skill: "flow:fix-pr-reviews" })` when:

- Systematically addressing all PR review comments
- Need automated tracking of review resolution

**Code quality:** Load via `Skill({ skill: "devtools:code-health" })` when:

- Feedback points to broader code health issues
- Need to audit for similar issues across codebase

**Iterative improvement:** Load via `Skill({ skill: "devtools:rule-of-five" })` when:

- Significant refactoring required from feedback
- Need multiple review passes for complex changes

</related_skills>

<success_criteria>

1. [ ] All review comments extracted and tracked
2. [ ] Each feedback item categorized by type
3. [ ] Vague feedback translated to concrete prompts
4. [ ] Ambiguous feedback clarified with reviewer
5. [ ] Each fix verified to match reviewer's intent
6. [ ] Resolution documented for each comment
7. [ ] Patterns logged for future prevention
</success_criteria>

<evolution>
**Extension Points:**
- Add team-specific feedback translation rules
- Integrate with code review tools (GitHub, GitLab)
- Build feedback pattern database for learning

**Timelessness:** Code review is fundamental to software quality; translating feedback to action is a skill that transcends specific tools or languages.
</evolution>
