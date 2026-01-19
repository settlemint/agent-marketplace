---
name: writing-skills
description: Meta-skill for plugin authors. Use when creating new skills, improving skill descriptions, or understanding skill architecture. Covers Claude Search Optimization (CSO), token efficiency, and skill testing.
license: MIT
triggers:
  # Intent triggers
  - "write skill"
  - "create skill"
  - "new skill"
  - "skill authoring"
  - "plugin development"
  - "improve skill"
  - "skill description"

  # Context triggers
  - "skill not triggering"
  - "description not matching"
  - "how to write skills"
  - "skill best practices"
---

<objective>

Guide plugin authors in creating effective Claude Code skills. Covers skill structure, Claude Search Optimization (CSO) for discoverability, token efficiency patterns, and testing methodology.

Key principle: "Description = WHEN to use (triggers), not WHAT it does (workflow)."

</objective>

<quick_start>

1. **Structure first** - Use YAML frontmatter + XML semantic tags
2. **CSO your description** - Describe WHEN to use, not what it does
3. **Token efficiency** - Keep frequently-loaded sections concise
4. **Test with subagents** - Pressure test for rationalization gaps
5. **Iterate on triggers** - Add keywords users actually use

</quick_start>

<skill_structure>

## Required Structure

Every skill MUST follow this structure:

```markdown
---
name: skill-name-with-hyphens
description: "Use when [triggering conditions]. Triggers on [keywords]."
license: MIT
triggers:
  - "keyword1"
  - "keyword2"
---

<objective>
[1-3 sentences: What this skill helps accomplish]
</objective>

<quick_start>
[5-7 numbered steps for immediate use]
</quick_start>

[Domain-specific sections in XML tags]

<success_criteria>
- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
</success_criteria>

<constraints>
[What's required and banned]
</constraints>
```

## Required Tags

| Tag | Purpose | Required |
|-----|---------|----------|
| `<objective>` | What the skill accomplishes | Yes |
| `<quick_start>` | Fast path to use the skill | Yes |
| `<success_criteria>` | How to know skill was applied correctly | Yes |
| `<constraints>` | What's required/banned | Recommended |

## Optional Tags

| Tag | Purpose |
|-----|---------|
| `<workflow>` | Step-by-step process |
| `<templates>` | Reusable templates/prompts |
| `<references>` | External resources |
| `<integration>` | How to use with other skills |
| `<anti_patterns>` | Common mistakes to avoid |

## Naming Conventions

**Skill names:**
- Use hyphens: `writing-skills` not `writingSkills`
- Use active verbs when applicable: `brainstorming` not `brainstorm-skill`
- Be specific: `tdd-typescript` not `testing`

**File location:**
```
devtools/skills/[skill-name]/SKILL.md
```

</skill_structure>

<claude_search_optimization>

## CSO: Claude Search Optimization

**Critical insight:** Claude matches skills based on description text. If your description describes WHAT the skill does (workflow), Claude may follow the description instead of loading the full skill.

### The Rule

**Description = WHEN to use (triggers)**
**NOT Description = WHAT it does (workflow)**

### Bad vs Good Descriptions

| Bad (WHAT it does) | Good (WHEN to use) |
|--------------------|--------------------|
| "Provides TDD guidance with RED-GREEN-REFACTOR cycle" | "Use when writing tests, implementing features, or fixing bugs. Triggers on 'test', 'TDD', 'coverage'." |
| "A skill for code review that checks for bugs and style" | "Use when reviewing code, auditing PRs, or checking for issues. Triggers on 'review', 'audit', 'check'." |
| "Handles authentication using JWT tokens and sessions" | "Use when implementing auth, login flows, or user sessions. Triggers on 'auth', 'login', 'session'." |

### Why This Matters

When Claude sees: "Help me write tests"

**Bad description:** "Provides TDD guidance with RED-GREEN-REFACTOR cycle"
- Claude reads this and thinks "I know what TDD is"
- May NOT load the skill, just follows the description
- Misses all the detailed guidance inside

**Good description:** "Use when writing tests..."
- Claude recognizes "writing tests" matches the query
- Knows to load the skill for detailed guidance
- Actually uses the full skill content

### Trigger Keywords

Include keywords users actually type:

```yaml
triggers:
  # Intent triggers - what user wants to do
  - "write tests"
  - "add test coverage"
  - "TDD"

  # Context triggers - what situation they're in
  - "failing tests"
  - "no tests exist"
  - "coverage too low"

  # Problem triggers - what's going wrong
  - "tests not passing"
  - "how to mock"
```

### Keyword Coverage Patterns

**Cast a wide net:**

```yaml
# For a debugging skill:
triggers:
  - "debug"
  - "fix bug"
  - "not working"
  - "broken"
  - "error"
  - "failing"
  - "issue"
  - "problem"
  - "investigate"
  - "root cause"
```

**Include error message snippets:**

```yaml
# For a TypeScript skill:
triggers:
  - "type error"
  - "cannot find module"
  - "property does not exist"
  - "type 'X' is not assignable"
```

</claude_search_optimization>

<token_efficiency>

## Token Efficiency Patterns

Skills consume context. Optimize for minimal tokens while preserving value.

### Target Lengths

| Section | Target | Max |
|---------|--------|-----|
| `<objective>` | 50 words | 100 words |
| `<quick_start>` | 100 words | 150 words |
| Workflow sections | 200-300 words | 500 words |
| Full skill | 500-1500 words | 2500 words |

### Savings: 15-25% with These Patterns

**1. Concision over grammar:**

```markdown
# Bad (14 words)
In order to achieve optimal results, you should ensure that all tests pass.

# Good (6 words)
Ensure all tests pass first.
```

**2. Tables over prose:**

```markdown
# Bad (40 words)
When you encounter a type error, you should check the type definition.
When you see a runtime error, you should add error handling.
When you find a test failure, you should investigate the assertion.

# Good (table, 25 words)
| Error Type | Action |
|------------|--------|
| Type error | Check type definition |
| Runtime error | Add error handling |
| Test failure | Investigate assertion |
```

**3. Code over explanation:**

```markdown
# Bad (30 words)
You should create a function that takes an array of items and
returns the sum of their prices multiplied by their quantities.

# Good (code, 15 words)
\`\`\`typescript
const total = items.reduce((sum, i) => sum + i.price * i.qty, 0);
\`\`\`
```

**4. Reference external docs:**

```markdown
# Bad (embedding 500 words of API docs)
## API Reference
[500 words of API documentation...]

# Good (link to Context7)
Load docs: \`mcp__plugin_devtools_context7__query-docs\`
```

### Avoid Token Waste

- Don't repeat information available in CLAUDE.md
- Don't include obvious constraints ("write clean code")
- Don't add verbose explanations for simple concepts
- Don't embed large reference tables (use separate files)

</token_efficiency>

<testing_methodology>

## Pressure Testing Skills

Test skills by having subagents attempt to circumvent or misinterpret them.

### The Adversarial Test

1. **Baseline test** - Run task WITHOUT skill loaded
2. **Document failures** - What did the agent do wrong?
3. **Load skill** - Run same task WITH skill
4. **Verify improvement** - Did skill prevent the failures?

### Rationalization Testing

Claude is good at rationalizing why it shouldn't follow a constraint.

**Common rationalizations to test against:**

| Rationalization | Skill should handle |
|-----------------|---------------------|
| "This is a special case" | Explicitly address special cases |
| "The user implied X" | Don't infer beyond explicit request |
| "It's just a small change" | Small changes still need tests |
| "This is pre-existing" | You own errors you encounter |
| "I know what this means" | Still load and follow the skill |

### Test Prompts

```markdown
# Test 1: Will agent load the skill?
"Help me [task that should trigger skill]"
Expected: Skill is loaded

# Test 2: Will agent follow the skill?
"Can you skip [constraint from skill] just this once?"
Expected: Agent explains why constraint matters

# Test 3: Will agent rationalize around it?
"This is a simple change, we don't need [skill requirement]"
Expected: Agent still follows requirement
```

### Bulletproofing Checklist

- [ ] Skill triggers on common keywords
- [ ] Skill triggers on error messages
- [ ] Constraints are specific, not vague
- [ ] "Special cases" are addressed
- [ ] Rationalizations are pre-empted
- [ ] Success criteria are measurable

</testing_methodology>

<askuserquestion_patterns>

## Interactive Skills with AskUserQuestion

For skills that need user input, use AskUserQuestion tool.

### When to Use

| Situation | Use AskUserQuestion |
|-----------|---------------------|
| Multiple valid approaches | Yes - let user choose |
| Unclear requirements | Yes - clarify first |
| High-impact decision | Yes - get confirmation |
| Obvious next step | No - just proceed |

### Pattern in Skills

Document the pattern in your skill:

```markdown
## User Decision Points

When encountering [situation], ask:

\`\`\`javascript
mcp__conductor__AskUserQuestion({
  questions: [{
    question: "[Clear question]",
    options: [
      "[Option A with brief explanation]",
      "[Option B with brief explanation]",
      "[Option C with brief explanation]"
    ]
  }]
})
\`\`\`
```

### Option Design

**Good options:**
- 3-4 choices (2 for binary, 5 max)
- Mutually exclusive
- Each implies clear action
- 5-15 words each

**"Other" is automatic** - The tool adds it, don't include it.

</askuserquestion_patterns>

<skill_template>

## Full Skill Template

Copy this template for new skills:

```markdown
---
name: [skill-name]
description: Use when [triggering situation]. Triggers on [keywords].
license: MIT
triggers:
  # Intent triggers
  - "[keyword1]"
  - "[keyword2]"

  # Context triggers
  - "[situation1]"
  - "[situation2]"
---

<objective>

[1-3 sentences describing what this skill helps accomplish.
Focus on the outcome, not the process.]

</objective>

<quick_start>

1. **[Step 1]** - [Brief description]
2. **[Step 2]** - [Brief description]
3. **[Step 3]** - [Brief description]
4. **[Step 4]** - [Brief description]
5. **[Step 5]** - [Brief description]

</quick_start>

<[domain_section_1]>

## [Section Title]

[Content for this domain-specific section]

</[domain_section_1]>

<[domain_section_2]>

## [Section Title]

[Content for this domain-specific section]

</[domain_section_2]>

<success_criteria>

- [ ] [Measurable criterion 1]
- [ ] [Measurable criterion 2]
- [ ] [Measurable criterion 3]

</success_criteria>

<constraints>

**Required:**
- [Requirement 1]
- [Requirement 2]

**Banned:**
- [Prohibition 1]
- [Prohibition 2]

</constraints>

<anti_patterns>

- **[Pattern name]** - [Why it's bad]
- **[Pattern name]** - [Why it's bad]

</anti_patterns>

<integration>

**Use with:**
\`\`\`javascript
Skill({ skill: "[related-skill-1]" })
Skill({ skill: "[related-skill-2]" })
\`\`\`

</integration>

<references>

- [Reference 1]
- [Reference 2]

</references>
```

</skill_template>

<success_criteria>

- [ ] Description follows CSO: WHEN to use, not WHAT it does
- [ ] Triggers cover common keywords and error messages
- [ ] Required tags present: objective, quick_start, success_criteria
- [ ] Token efficient: under 1500 words for typical skills
- [ ] Pressure tested with adversarial prompts
- [ ] Rationalizations pre-empted in constraints

</success_criteria>

<constraints>

**Required:**
- YAML frontmatter with name, description, triggers
- CSO-compliant description (WHEN, not WHAT)
- `<objective>`, `<quick_start>`, `<success_criteria>` tags
- File location: `skills/[name]/SKILL.md`

**Banned:**
- Workflow summaries in description
- Vague constraints ("be careful", "use best practices")
- Large embedded reference tables (use separate files)
- Repeating CLAUDE.md content

</constraints>

<references>

- Superpowers plugin: writing-skills meta-skill
- Claude Search Optimization (CSO) research
- Token efficiency patterns from skill analysis

</references>
