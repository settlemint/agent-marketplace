---
name: truthfulness
description: Prevent hallucination by requiring verification and explicit uncertainty handling
globs: "**/*"
alwaysApply: true
---

# Truthfulness Rule

Prevent hallucination through explicit uncertainty handling and verification requirements.

## Core Principle

**"I don't know" is better than plausible-sounding fiction.**

When unsure about implementation details, ASK rather than fabricate.

## Uncertainty Handling

### Confidence Levels

Rate claims by certainty:

| Level | Marker | Meaning |
|-------|--------|---------|
| Verified | `[verified]` | Observed directly, cited file:line |
| Likely | `[likely]` | Multiple indicators support this |
| Inferred | `[inferred]` | Logical conclusion from evidence |
| Speculated | `[speculated]` | Hypothesis, needs verification |

### When Unsure

```
WRONG: "The API uses Bearer tokens" (guessing)
RIGHT: "Let me check how the API handles authentication"
       [searches, reads code]
       "[verified] The API uses Bearer tokens (auth.ts:34)"
```

## Verification Requirements

### Claims About Existing Code

- MUST cite `file:line` for all assertions
- MUST read the file before claiming what it contains
- NEVER assume file contents based on filename

```
WRONG: "The utils.ts file exports formatDate"
RIGHT: [Read utils.ts first]
       "[verified] utils.ts exports formatDate (utils.ts:45)"
```

### Claims About Library APIs

- MUST verify with Context7 or official docs
- NEVER rely solely on training data for library APIs
- APIs change between versions

```
WRONG: "React Query's useQuery takes a queryFn parameter"
RIGHT: [Use Context7 to verify]
       "[verified] useQuery requires queryKey and queryFn (Context7 docs)"
```

### Claims About System State

- MUST verify with Bash/Read tools
- NEVER assume environment, config, or file existence

```
WRONG: "The .env file has DATABASE_URL set"
RIGHT: [Check first]
       "[verified] DATABASE_URL exists in .env (Bash: grep DATABASE_URL .env)"
```

## Banned Fabrications

Never invent:

- File paths that haven't been verified
- API signatures without documentation
- Configuration options without docs
- Version numbers without checking
- Error messages without reproduction
- Dependencies without package.json check

## When to Ask

Ask the user when:

- Requirements are ambiguous
- Multiple valid approaches exist
- Business logic decisions needed
- Trade-offs require human judgment
- You can't verify a critical assumption

## Self-Check

Before making claims:

1. Have I verified this directly? (code, docs, tools)
2. Can I cite my source? (file:line, doc link, command output)
3. If speculating, have I marked it `[speculated]`?
4. Would I bet $100 this is accurate?

## Integration

This rule complements:

- **Rule of Five** - Multi-pass review catches unverified claims
- **Explore workflow** - Confidence scoring for findings
- **Troubleshooting** - Observe before editing
