---
name: crew:plan:refine
description: Resolve open questions in a plan through user interview
argument-hint: "<plan-path>"
hidden: true
allowed-tools:
  - Read
  - Write
  - AskUserQuestion
  - TodoWrite
skills:
  - crew:crew-patterns
---

<objective>

Read plan's open_questions. Ask user to resolve each. Update plan with answers, clear resolved questions. Return to caller.

</objective>

<workflow>

## Step 1: Load Plan

```javascript
const planPath = args; // e.g., .claude/plans/feature-x.yaml
const plan = Read({ file_path: planPath });
const questions = plan.open_questions || [];

if (questions.length === 0) {
  console.log("No open questions to resolve.");
  return; // Return to caller
}

TodoWrite([
  {
    content: `#1 ○ Resolve ${questions.length} questions`,
    status: "in_progress",
    activeForm: "Interviewing",
  },
  {
    content: "#2 ● Update plan ⚠ blocked by #1",
    status: "pending",
    activeForm: "Updating plan",
  },
]);
```

## Step 2: Interview User

Ask questions in batches (max 4 per AskUserQuestion). For each question, provide context-aware options.

```javascript
// Group questions by category for better UX
const blocking = questions.filter((q) => q.blocking);
const nonBlocking = questions.filter((q) => !q.blocking);

// Ask blocking questions first
for (const q of blocking) {
  AskUserQuestion({
    questions: [
      {
        question: q.text,
        header: q.id,
        options: generateOptionsForQuestion(q), // Context-aware options based on question type
        multiSelect: false,
      },
    ],
  });

  // Store answer
  answers[q.id] = userResponse;
}

// Then non-blocking
for (const q of nonBlocking) {
  AskUserQuestion({
    questions: [
      {
        question: q.text,
        header: q.id,
        options: generateOptionsForQuestion(q),
        multiSelect: false,
      },
    ],
  });

  answers[q.id] = userResponse;
}
```

## Step 3: Update Plan

```javascript
// Apply answers to relevant plan sections
for (const [qId, answer] of Object.entries(answers)) {
  const question = questions.find((q) => q.id === qId);

  // Update plan based on answer type:
  // - Requirements clarification → update stories/acceptance criteria
  // - Technical decision → update technical_approach
  // - Scope clarification → update stories (add/remove)
  // - Performance requirements → update success_criteria

  applyAnswerToPlan(plan, question, answer);
}

// Remove resolved questions
plan.open_questions = [];

Write({ file_path: planPath, content: updatedPlan });
// TodoWrite: #1-2 ✓
// Returns to caller (plan) which will call plan-review
```

</workflow>

<question_options>

Generate context-aware options based on question type:

**Scope questions:**

- "Include in MVP"
- "Defer to v2"
- "Out of scope"

**Technical decisions:**

- List specific approaches from question context
- "Let me decide during implementation"
- "Need more research"

**Requirements clarification:**

- "Required"
- "Nice to have"
- "Not needed"

**Performance/scale:**

- Specific numeric options if applicable
- "Use reasonable defaults"
- "Needs benchmarking"

</question_options>

<success_criteria>

- [ ] All blocking questions asked first
- [ ] User answers collected for each question
- [ ] Plan updated with answers
- [ ] open_questions cleared after resolution
- [ ] Returns to caller for next review cycle

</success_criteria>
