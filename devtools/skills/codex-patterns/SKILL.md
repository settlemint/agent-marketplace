---
name: codex-patterns
description: Patterns for using Codex MCP for deep code reasoning, security analysis, and architecture review
license: MIT
triggers:
  - codex
  - deep analysis
  - security review
  - architecture review
  - owasp
  - vulnerability
  - threat model
  - code reasoning
  - explain.*code
  - analyze.*code
  - review.*security
---

<objective>
Provide patterns for using the Codex MCP server for deep code analysis, security review, and architectural reasoning. Codex excels at complex analysis that requires multi-step reasoning.
</objective>

<essential_principles>

- Codex is for reasoning, not lookup (use Context7 for docs, OctoCode for examples)
- Provide sufficient context in prompts (code, error messages, constraints)
- Ask for multiple dimensions of analysis (not just yes/no)
- Request actionable recommendations with severity levels
  </essential_principles>

<constraints>
**Banned:**
- Using Codex for simple lookups (use Context7)
- Vague prompts without specific context
- Single-dimension analysis (always multi-faceted)
- Security findings without severity levels

**Required:**

- Provide sufficient code context in prompts
- Ask for actionable recommendations
- Include constraints and requirements in queries
- Request multiple analysis dimensions
  </constraints>

<anti_patterns>

- Asking "is this code secure?" without providing the code
- Using Codex when grep/glob would suffice
- Expecting Codex to find code examples (use OctoCode)
- Ignoring severity levels in security findings
- Single yes/no questions instead of multi-dimensional analysis
  </anti_patterns>

<quick_start>

**Load Codex MCP:**

```javascript
MCPSearch({ query: "select:mcp__plugin_devtools_codex__codex" });
```

**Basic query:**

```javascript
mcp__plugin_devtools_codex__codex({
  prompt: `[Your analysis request here]`,
});
```

</quick_start>

<when_to_use_codex>

| Use Case              | Why Codex                                 |
| --------------------- | ----------------------------------------- |
| Security review       | Multi-step attack vector analysis         |
| Architecture decision | Trade-off evaluation across dimensions    |
| Complex debugging     | Root cause analysis with reasoning chains |
| Code explanation      | Deep understanding of unfamiliar patterns |
| Edge case discovery   | Systematic exploration of boundary cases  |
| Refactoring planning  | Impact analysis across codebase           |

**Don't use Codex for:**

- Simple lookups (use Context7)
- Finding code examples (use OctoCode)
- Pattern matching (use Grep/Glob)

</when_to_use_codex>

<reference_index>
| Reference | Content |
|-----------|---------|
| security-prompts.md | OWASP Top 10, authentication review, input validation prompts |
| architecture-prompts.md | Trade-off analysis, pattern fit, coupling analysis prompts |
| debugging-prompts.md | Root cause, race conditions, complexity, edge case discovery prompts |
| mcp-combinations.md | Context7 + Codex, OctoCode + Codex workflow patterns |
</reference_index>

<related_skills>

**Security testing:** Load via `Skill({ skill: "devtools:playwright" })` when:

- Need to test security findings in browser
- Automate penetration testing scenarios

**Code health:** Load via `Skill({ skill: "devtools:code-health" })` when:

- Running systematic codebase audit
- Finding YAGNI, dead code, duplication

**Iterative review:** Load via `Skill({ skill: "devtools:rule-of-five" })` when:

- Multi-pass analysis needed
- Complex refactoring decisions

**Security analysis (Trail of Bits):** Load these for deep security auditing:

- `Skill({ skill: "trailofbits:audit-context-building" })` — Architectural context analysis
- `Skill({ skill: "trailofbits:differential-review" })` — Security-focused git diff review
- `Skill({ skill: "trailofbits:sharp-edges" })` — Dangerous APIs and configs
- `Skill({ skill: "trailofbits:static-analysis" })` — CodeQL, Semgrep, SARIF toolkit

</related_skills>

<success_criteria>

- [ ] Codex query is specific and focused
- [ ] Context provided is sufficient for analysis
- [ ] Multiple dimensions evaluated (not just one)
- [ ] Findings include actionable recommendations
- [ ] Severity assigned to security findings
      </success_criteria>

<evolution>
**Extension Points:**
- Create domain-specific prompt templates for recurring analysis
- Add reference files for OWASP, architecture patterns
- Build custom prompt chains for complex workflows

**Timelessness:** Deep reasoning for security and architecture decisions will remain valuable as codebases grow in complexity.
</evolution>
