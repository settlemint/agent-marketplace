---
name: crew:router
description: Intelligent request routing. Classifies user requests and routes to appropriate workflow.
context: auto-load
---

<objective>

Classify user requests as STEERING, TRIVIAL, or SUBSTANTIAL, then route to the appropriate workflow. Zero commands to remember - just describe what you want.

</objective>

<classification_heuristics>

## Request Classification

Analyze the user's message using these signals:

| Signal        | STEERING                                   | TRIVIAL                                           | SUBSTANTIAL                                       |
| ------------- | ------------------------------------------ | ------------------------------------------------- | ------------------------------------------------- |
| Length        | <50 chars                                  | 50-200 chars                                      | >200 chars                                        |
| Keywords      | "yes", "try", "instead", "actually", "but" | "fix", "rename", "typo", "update" (single target) | "add", "implement", "create", "refactor", "build" |
| Context refs  | "it", "that", "the function", "this"       | line numbers, single file                         | directories, "across", "all", multiple files      |
| Session state | has active work/plan                       | no active work                                    | any                                               |
| Question?     | N/A                                        | N/A                                               | Clarifying question only                          |

### Confidence Scoring

**HIGH confidence** (route automatically):

- 3+ signals point to same classification
- Message clearly matches classification keywords
- Session state strongly supports classification

**LOW confidence** (ask user):

- Signals conflict (e.g., short message but "implement" keyword)
- Ambiguous scope ("update the user model" - is it trivial or substantial?)
- First message in session with no prior context

</classification_heuristics>

<classification_algorithm>

## Decision Process

```
1. Read session state from .claude/branches/{branch}/state.json
2. Check: Is there active work? (plan exists, todos pending, workflow active)
3. Analyze message: length, keywords, context references
4. Score confidence based on signal alignment
5. Route based on classification:

IF confidence HIGH:
  → Route to appropriate workflow automatically

IF confidence LOW:
  → Use AskUserQuestion to clarify
```

### State Context

Read from `.claude/branches/{branch}/state.json`:

```json
{
  "routing": {
    "current_mode": "idle|planning|working|complete",
    "entered_at": "ISO-timestamp",
    "confidence": "high|low"
  },
  "plan": { "exists": true/false, "file": "path" },
  "execution": { "pending_count": N },
  "workflow": { "active": "skill-name" }
}
```

### Keyword Detection

**STEERING indicators** (continuing current work):

- Affirmative: "yes", "ok", "sure", "go ahead", "do it"
- Adjustment: "try", "instead", "actually", "but", "rather"
- Reference: "it", "that", "this", "the same"

**TRIVIAL indicators** (single targeted action):

- Scope words: "just", "only", "quick", "simple"
- Actions: "fix", "rename", "typo", "update", "change", "move"
- Targets: line numbers, single file path, specific function name

**SUBSTANTIAL indicators** (needs planning):

- Creation: "add", "create", "implement", "build", "new"
- Scale: "refactor", "redesign", "overhaul", "migrate"
- Scope: "across", "all", "throughout", multiple components
- Complexity: "authentication", "database", "API", "integration"

</classification_algorithm>

<intake>

## Request Classification

When a user message arrives, classify it:

```javascript
// 1. Get session state
const branchDir = ".claude/branches/" + getBranchName();
const stateFile = branchDir + "/state.json";
// Read state if exists

// 2. Analyze message
const message = userMessage;
const length = message.length;
const hasActiveWork =
  state?.plan?.exists || state?.execution?.pending_count > 0;

// 3. Check for explicit commands (bypass classification)
if (message.startsWith("/")) {
  // User explicitly invoked a command - let it run
  return;
}

// 4. Classify based on heuristics
let classification = classify(message, hasActiveWork);
let confidence = scoreConfidence(classification, signals);

// 5. Route or ask
if (confidence === "high") {
  // Route automatically
  routeToWorkflow(classification);
} else {
  // Ask user to clarify
  AskUserQuestion({
    questions: [
      {
        question: "How should I handle this request?",
        header: "Request Type",
        options: [
          { label: "Quick fix", description: "Execute directly (TRIVIAL)" },
          {
            label: "Needs planning",
            description: "Create a plan first (SUBSTANTIAL)",
          },
          {
            label: "Continue work",
            description: "Adjust current task (STEERING)",
          },
        ],
        multiSelect: false,
      },
    ],
  });
}
```

</intake>

<routing>

| Classification | Confidence | Action                     |
| -------------- | ---------- | -------------------------- |
| STEERING       | HIGH       | `workflows/steering.md`    |
| STEERING       | LOW        | Ask user → route           |
| TRIVIAL        | HIGH       | `workflows/trivial.md`     |
| TRIVIAL        | LOW        | Ask user → route           |
| SUBSTANTIAL    | HIGH       | `workflows/substantial.md` |
| SUBSTANTIAL    | LOW        | Ask user → route           |

**After classifying, read and follow the appropriate workflow exactly.**

</routing>

<state_transitions>

## Mode State Machine

```
IDLE ──┬── STEERING ──► continue (stays in current mode)
       │
       ├── TRIVIAL ───► execute immediately → IDLE
       │
       └── SUBSTANTIAL ► PLANNING ──► WORKING ──► COMPLETE ──► IDLE
```

### State Persistence

Update `.claude/branches/{branch}/state.json` on mode changes:

```json
{
  "routing": {
    "current_mode": "working",
    "entered_at": "2026-01-14T10:30:00Z",
    "confidence": "high",
    "classification": "substantial"
  }
}
```

</state_transitions>

<workflows_index>

## Workflows

All in `workflows/`:

| Workflow         | Purpose                                       |
| ---------------- | --------------------------------------------- |
| steering.md      | Continue/adjust current work in progress      |
| trivial.md       | Execute simple requests immediately           |
| substantial.md   | Plan and execute complex features             |
| work-adaptive.md | Dynamic execution with probe-based adaptation |

</workflows_index>

<success_criteria>

A well-executed routing:

- [ ] Classification matches user intent
- [ ] High-confidence routes automatically (no unnecessary questions)
- [ ] Low-confidence asks user (prevents wrong mode)
- [ ] State updated to reflect current mode
- [ ] Appropriate workflow invoked
- [ ] Zero commands required from user

</success_criteria>
