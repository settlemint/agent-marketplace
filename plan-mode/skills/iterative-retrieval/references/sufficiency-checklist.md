# Sufficiency Evaluation Checklist

Detailed criteria for evaluating whether subagent results are sufficient for different task types.

## General Sufficiency Questions

Always ask these questions when evaluating any subagent result:

### Completeness
- [ ] Does the result address ALL items in my initial query?
- [ ] Are there obvious gaps in the information provided?
- [ ] Did the subagent explicitly say it couldn't find something?

### Clarity
- [ ] Are file paths specific (not "somewhere in src/")?
- [ ] Are line numbers provided for key findings?
- [ ] Are ambiguous terms clarified in context?

### Relevance
- [ ] Does the information directly support my stated objective?
- [ ] Is there extraneous information that suggests misunderstanding?
- [ ] Did the subagent understand why I needed this?

### Adjacency
- [ ] Did the subagent mention related things it noticed but didn't detail?
- [ ] Are there obvious related areas that weren't explored?
- [ ] Would I naturally ask "what about X?" after reading this?

## Task-Specific Checklists

### Codebase Exploration

For exploring unfamiliar code areas:

| Criterion | Sufficient If | Insufficient If |
|-----------|---------------|-----------------|
| Entry points | Specific files and functions identified | Vague references to "the API" |
| Data flow | Can trace from input to output | Missing intermediate steps |
| Dependencies | Key imports/relationships mapped | Only surface-level connections |
| Patterns | Design patterns identified | Just lists of files |
| Edge cases | Error handling documented | Happy path only |

**Follow-up triggers:**
- "Handler" mentioned without showing the handler code
- "Uses X for Y" without explaining the mechanism
- References to config without showing config location

### Architecture Research

For understanding system design:

| Criterion | Sufficient If | Insufficient If |
|-----------|---------------|-----------------|
| Layers | Clear separation of concerns identified | Flat list of components |
| Boundaries | Module interfaces documented | Implementation details only |
| State | Where state lives is clear | State management unclear |
| Communication | How components interact | Components listed in isolation |
| Constraints | Performance/security considerations noted | Technical debt not mentioned |

**Follow-up triggers:**
- "Service communicates with..." without protocol details
- "Data is stored in..." without schema/structure
- "Auth is handled by..." without flow description

### External Documentation Research

For fetching library/framework docs:

| Criterion | Sufficient If | Insufficient If |
|-----------|---------------|-----------------|
| Version match | Docs match project's package.json version | Generic/latest docs |
| API coverage | Relevant APIs documented | Only getting started guide |
| Examples | Code examples for your use case | Conceptual explanations only |
| Migration | Breaking changes noted if upgrading | Version differences ignored |
| Alternatives | Trade-offs of different approaches | Single approach without context |

**Follow-up triggers:**
- Examples use different API version than project
- "See also X" without fetching X
- Configuration options mentioned but not detailed

### Debugging Investigation

For researching bugs and failures:

| Criterion | Sufficient If | Insufficient If |
|-----------|---------------|-----------------|
| Reproduction | Steps to reproduce are clear | "Sometimes fails" |
| Scope | Affected code paths identified | Single file focus |
| Related issues | Similar bugs/fixes found | No historical context |
| Root cause | Actual cause vs symptoms distinguished | Surface-level description |
| Tests | Related test coverage identified | Tests not checked |

**Follow-up triggers:**
- Error mentioned without showing error handling
- "Fails when..." without showing success case
- Fix suggested without explaining why it works

## Refinement Request Templates

### Gap-Filling Request

```
Your findings on [TOPIC] were helpful, specifically [USEFUL_PART].

GAPS TO FILL:
1. You mentioned [X] but didn't show [SPECIFIC_DETAIL]
2. [QUERY_ITEM] wasn't addressed - where is this handled?
3. The relationship between [A] and [B] is unclear

WHY NEEDED: [OBJECTIVE_CONNECTION]
```

### Clarification Request

```
I need clarification on your findings:

AMBIGUITIES:
1. When you said [PHRASE], did you mean [INTERPRETATION_A] or [INTERPRETATION_B]?
2. The file path [PATH] - is this relative to project root?
3. [TERM] appears multiple times - are these the same concept?

Please be specific in your clarification.
```

### Adjacency Request

```
Your findings covered the main query well.

ADJACENT AREAS:
1. You noticed [MENTIONED_BUT_NOT_DETAILED] - can you expand on this?
2. Given what you found, is there related code in [SUSPECTED_AREA]?
3. Were there any utilities/helpers that support this functionality?

These may be relevant to [OBJECTIVE].
```

## Cycle Budget Guidelines

| Situation | Recommended Max Cycles |
|-----------|----------------------|
| Simple exploration | 1-2 cycles |
| Architecture research | 2-3 cycles |
| Debugging investigation | 2-3 cycles |
| External docs research | 1-2 cycles |
| Cross-cutting concerns | 3 cycles |

**When to stop early:**
- Subagent explicitly says "no more relevant information found"
- Follow-up returns diminishing new information
- You're asking about the same area multiple times

**When to use all 3 cycles:**
- Large, unfamiliar codebase
- Critical architectural decisions
- Security-sensitive code paths
