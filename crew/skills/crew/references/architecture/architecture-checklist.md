# Architecture Review Checklist

Use this for early-stage design validation of agent-native systems.

## Tool Design

- [ ] Dynamic vs. static capability mapping (prefer dynamic)
- [ ] CRUD completeness for all entities
- [ ] String parameters over hardcoded enums
- [ ] Discovery tools (`list_*`) for external APIs

## Action Parity

- [ ] Every user action has agent equivalent
- [ ] No UI-only workflows
- [ ] Shared data locations (not platform-locked)

## Context Injection

- [ ] Agents receive relevant context automatically
- [ ] No hidden state requiring human navigation
- [ ] Real-time data accessible to both

## Validation Questions

1. Can agent do everything user can do?
2. Can agent see everything user sees?
3. If API changes tomorrow, does agent adapt without code changes?

## Dynamic Capability Discovery Pattern

For external APIs (HealthKit, GraphQL, third-party services), use discovery tools + generic access tools:

```typescript
// Discovery tool - returns available capabilities
tool("list_data_types", {}, async () => {
  return await api.getAvailableTypes(); // Returns ["steps", "heart_rate", ...]
});

// Generic access tool - accepts strings, not enums
tool(
  "read_data",
  {
    dataType: z.string(), // NOT z.enum(["steps", "heart_rate"])
    dateRange: z.object({ start: z.date(), end: z.date() }),
  },
  async ({ dataType, dateRange }) => {
    return await api.query(dataType, dateRange);
  },
);
```

**Why This Matters:**

- When API adds new data types, agent can use them immediately
- No code changes required for new capabilities
- Validation happens server-side where it belongs
- Agent leverages full API surface without artificial limits

**Anti-pattern:**

```typescript
// WRONG - hardcoded enum limits agent
tool("read_health_data", {
  dataType: z.enum(["steps", "heart_rate"]), // Agent can't use "sleep"!
});
```

## CRUD Completeness Requirement

**Rule:** Every entity an agent can CREATE must also be READABLE, UPDATABLE, and DELETABLE.

**Checklist for new entities:**

- [ ] `create_entity` tool exists
- [ ] `read_entity` / `list_entities` tool exists
- [ ] `update_entity` tool exists
- [ ] `delete_entity` tool exists

## Action Parity Mapping

Before implementing any user-facing feature, map it:

| User Action     | Agent Equivalent   | Status     |
| --------------- | ------------------ | ---------- |
| Tap "Add Item"  | `create_item` tool | ✅         |
| Swipe to delete | `delete_item` tool | ❌ MISSING |
| Edit in modal   | `update_item` tool | ✅         |

**Discovery Questions:**

1. What can users do that agents cannot?
2. What can users see that agents cannot access?
3. What workflows require human navigation?

**Resolution:** For every gap, either:

- Add the missing tool/API
- Document why the limitation is intentional (security, legal)
