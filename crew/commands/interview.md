---
name: crew:interview
description: Interview to flesh out a plan or specification with detailed questions
argument-hint: "[plan-file-path]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - Skill
---

<input>

**Plan file path:** `$ARGUMENTS`

If no argument provided, find the most recent plan:

```javascript
const plans = Glob({ pattern: ".claude/plans/*.md" });
// Sort by modification time, use most recent
```

</input>

<process>

<phase name="load-plan">

Read the current plan:

```javascript
const plan = Read({ file_path: "$ARGUMENTS" });
```

Display a brief summary of the current state:

```
I've loaded: $ARGUMENTS

Current status: [Draft/In Review/Approved]
User stories: X defined (Y with acceptance criteria)
Open questions: Z remaining
```

</phase>

<phase name="interview-loop">

Interview the user using AskUserQuestion tool about:

1. **Technical Implementation** - Architecture choices, technology decisions, patterns
2. **UI & UX** - User flows, interaction design, accessibility
3. **Edge Cases** - Error handling, boundary conditions, failure modes
4. **Tradeoffs** - Performance vs simplicity, scope vs timeline
5. **Concerns** - Risks, unknowns, dependencies
6. **Priorities** - What's MVP, what can wait, what's out of scope

**Question Guidelines:**

- Ask NON-OBVIOUS questions that require domain knowledge
- Focus on gaps and ambiguities in the current plan
- Challenge assumptions that seem weak
- Explore edge cases not covered
- Clarify any NEEDS CLARIFICATION items

**Example Questions:**

```javascript
AskUserQuestion({
  questions: [
    {
      question: "How should the system handle rate limiting for API calls?",
      header: "Rate Limiting",
      options: [
        { label: "Global limit per user", description: "100 req/min across all endpoints" },
        { label: "Per-endpoint limits", description: "Different limits based on cost" },
        { label: "Tiered by plan", description: "Free: 10/min, Pro: 100/min" },
        { label: "No limiting initially", description: "Add later based on usage" }
      ],
      multiSelect: false
    },
    {
      question: "What authentication method for the API?",
      header: "Auth Strategy",
      options: [
        { label: "API Keys", description: "Simple, stateless" },
        { label: "JWT Tokens", description: "Self-contained, expiring" },
        { label: "OAuth 2.0", description: "Full authorization flow" },
        { label: "Session-based", description: "Server-side state" }
      ],
      multiSelect: false
    }
  ]
});
```

**Continue interviewing until:**

- All NEEDS CLARIFICATION items resolved
- User indicates they're satisfied
- All major technical decisions documented

</phase>

<phase name="update-plan">

After each round of questions, update the plan file with answers:

```javascript
// Add decisions to the plan
Edit({
  file_path: planPath,
  old_string: "## Technical Approach",
  new_string: `## Technical Approach

### Decisions Made
- **Rate Limiting**: ${answer1.selection} - ${answer1.reasoning}
- **Authentication**: ${answer2.selection}

## Technical Approach`
});

// Remove resolved questions from Open Questions
Edit({
  file_path: planPath,
  old_string: "- Q1: How should rate limiting work?",
  new_string: ""
});
```

</phase>

<phase name="completion-check">

After updates, check if interview is complete:

```javascript
AskUserQuestion({
  questions: [{
    question: "The plan has been updated. What next?",
    header: "Continue",
    options: [
      { label: "More questions", description: "Continue interviewing for more detail" },
      { label: "Review changes", description: "Show me the updated plan" },
      { label: "Done", description: "Interview complete, plan is ready" }
    ],
    multiSelect: false
  }]
});
```

- "More questions" → Continue interview loop
- "Review changes" → Read and display updated plan, then ask again
- "Done" → Finalize and exit

</phase>

<phase name="finalize">

When complete:

1. Update plan status to "Ready for Review" or "Approved"
2. Regenerate task files if acceptance criteria changed
3. Output summary of changes made

```
Interview complete. Plan updated:

Changes made:
- Added 5 technical decisions
- Resolved 3 open questions
- Expanded 2 user stories with edge cases
- Added rate limiting and auth specifications

Plan saved to: $ARGUMENTS

Next step: Run /crew:build to start implementation
```

</phase>

</process>

<integration>

## Integration with /crew:design

The design command offers interview as an option before building:

```javascript
// In design.md present-plan phase:
AskUserQuestion({
  questions: [{
    question: "Ready to start building this plan?",
    options: [
      { label: "Start building", description: "Run /crew:build" },
      { label: "Interview first", description: "Flesh out details with /crew:interview" },
      { label: "Edit manually", description: "Edit the plan file directly" },
      { label: "Just save", description: "Save for later" }
    ]
  }]
});

// If "Interview first" selected:
Skill({ skill: "crew:interview", args: planPath });
```

</integration>

<success_criteria>

- [ ] Plan file loaded and displayed
- [ ] Questions are non-obvious and require thought
- [ ] AskUserQuestion used for all interactions
- [ ] Plan updated after each answer round
- [ ] Open questions resolved and removed
- [ ] Interview continues until user says done
- [ ] Final summary shows all changes made

</success_criteria>
