# Agent UX Design

How to build tools, skills, and interfaces that agents naturally use with minimal prompting.

## Core Principle

Agent UX matters as much as Human UX. If agents don't choose to use your tool of their own volition, go back to the drawing board.

## The Lightning-in-a-Bottle Test

A tool has good agent UX when:

- Agents use it eagerly and enthusiastically with minimal prompting
- Agents make smart decisions about when to use it
- Usage patterns match intended design without explicit instructions
- Agents reach for it naturally in relevant contexts

If your tool requires heavy prompting to use correctly, the UX needs work.

## Watch and Adapt

The most effective way to improve agent UX:

1. **Observe usage patterns**: Watch how agents try to use your tool
2. **Note friction points**: Where do they give wrong arguments? What errors occur?
3. **Adapt to expectations**: Add aliases for familiar patterns

### Example: Command Flag Aliases

Agents trained on GitHub Issues use `--body` for issue descriptions. If your tool uses `--description`:

```bash
# Agents will try:
beads create --body "Fix the login bug"

# But your tool expects:
beads create --description "Fix the login bug"

# Solution: Add --body as an alias for --description
# Now both work, and agents succeed on first try
```

### Example: Familiar Naming

| Agent Expectation | Your Original   | Better Choice |
| ----------------- | --------------- | ------------- |
| `--body`          | `--description` | Support both  |
| `--title`         | `--name`        | Support both  |
| `--repo`          | `--repository`  | Support both  |
| `list`            | `ls`            | Support both  |
| `create`          | `new`           | Support both  |

## Interface Generation Strategy

When agents struggle with an interface, use optionality:

1. Generate 3-5 different interface designs
2. Test each with agents in realistic scenarios
3. Measure which one agents use most successfully
4. Iterate on the winner

```javascript
// Example: Testing CLI interfaces
const interfaces = [
  "beads create --title X --body Y",
  "beads new X --description Y",
  "beads add 'X: Y'",
  "beads issue X Y",
];

// Test each, measure success rate
// Pick the one agents naturally prefer
```

## Design Principles

### 1. Match Mental Models

Agents have mental models from training data. Design interfaces that match common patterns:

- Git-like commands (`add`, `commit`, `push`, `status`)
- Unix conventions (`-f` for force, `-v` for verbose)
- REST semantics (`create`, `read`, `update`, `delete`)

### 2. Fail Gracefully with Helpful Messages

When agents use wrong arguments, provide actionable error messages:

```
# Bad error:
Error: Invalid argument

# Good error:
Error: Unknown flag '--body'. Did you mean '--description'?
Usage: beads create --description <text>
```

### 3. Provide Sensible Defaults

Reduce required arguments. Let agents succeed with minimal input:

```bash
# Many required args = friction
beads create --title X --body Y --status open --priority medium

# Sensible defaults = smooth UX
beads create "Fix login bug"  # Defaults: status=open, priority=medium
```

### 4. Return Structured Output

Agents parse output better when structured:

```json
// Better than plain text for agent consumption
{
  "id": "BEAD-123",
  "status": "created",
  "title": "Fix login bug",
  "url": "beads://BEAD-123"
}
```

## Anti-Patterns

| Anti-Pattern           | Problem              | Solution                |
| ---------------------- | -------------------- | ----------------------- |
| Novel vocabulary       | Agents guess wrong   | Use familiar terms      |
| Too many required args | Agents omit some     | Use sensible defaults   |
| Cryptic errors         | Agents can't recover | Provide suggestions     |
| Inconsistent naming    | Agents confused      | Follow conventions      |
| No aliases             | First attempt fails  | Support common variants |

## Testing Agent UX

Before releasing a tool:

1. **Zero-shot test**: Give agent the tool with minimal instructions. Does it succeed?
2. **Error recovery test**: What happens when agent makes mistakes? Can it recover?
3. **Context test**: Does agent choose this tool appropriately vs alternatives?
4. **Fluency test**: After initial use, does agent use it smoothly in follow-up tasks?

## Iteration Checklist

When agents struggle with your tool:

- [ ] What arguments did they try that failed?
- [ ] What familiar tool were they reaching for?
- [ ] Can you add aliases for their expectations?
- [ ] Are error messages actionable?
- [ ] Does default behavior match common usage?
- [ ] Is output easy for agents to parse?

## Key Insight

Agents were trained on millions of existing tools. They have muscle memory for common patterns. Don't fight this - embrace it. Make your tool feel familiar, and agents will use it fluently.
