---
name: flow:init-enhanced
description: Deep codebase analysis with progressive disclosure docs in .claude/docs/
license: MIT
triggers:
  - "(?i)init.*enhanced"
  - "(?i)bootstrap.*docs"
  - "(?i)generate.*codebase.*docs"
---

<objective>

Generate modular, discoverable documentation in `.claude/docs/` using parallel exploration agents. Creates focused docs (300-600 tokens each) with progressive disclosure patterns. Supports monorepos with per-package documentation.

</objective>

<quick_start>

```javascript
// Full codebase analysis (first run or major refresh)
Skill({ skill: "flow:init-enhanced" });

// Incremental update (only changed areas)
Skill({ skill: "flow:init-enhanced", args: "--incremental" });
```

</quick_start>

<routing>

| Pattern                                     | Workflow           |
| ------------------------------------------- | ------------------ |
| `--incremental` OR `.meta.json` is recent   | incremental-update |
| `turbo.json` OR `pnpm-workspace.yaml` found | init-monorepo      |
| Default                                     | init-standard      |

</routing>

<output_structure>

Generated docs in `.claude/docs/`:

```
.claude/docs/
├── _index.md           # Quick reference (~200 tokens)
├── architecture.md     # Structure + core logic
├── getting-started.md  # Setup + configuration
├── data-layer.md       # Database, models, schemas
├── api-reference.md    # Routes, endpoints, interfaces
├── testing.md          # Test patterns, coverage
├── deployment.md       # CI/CD, docker, infra
├── dependencies.md     # Key packages explained
├── glossary.md         # Domain terminology
├── .meta.json          # Staleness tracking
└── packages/           # Per-package docs (monorepo)
    ├── api/
    └── web/
```

</output_structure>

<agent_strategy>

Launch 5-6 Explore agents in parallel for comprehensive analysis:

| Agent | Focus                        | Output Doc                  |
| ----- | ---------------------------- | --------------------------- |
| 1     | Dirs, entry points, patterns | architecture.md             |
| 2     | Env, build, package manager  | getting-started.md          |
| 3     | Models, services, domain     | data-layer.md + glossary.md |
| 4     | APIs, routes, auth           | api-reference.md            |
| 5     | Tests, CI, deploy            | testing.md + deployment.md  |
| 6     | Key packages, internal deps  | dependencies.md             |

</agent_strategy>

<merge_markers>

Preserve manual edits via markers:

```markdown
<!-- AUTO-GENERATED: architecture -->

[Generated content]

<!-- END AUTO-GENERATED -->

## Manual Notes

[User additions preserved here]
```

</merge_markers>

<meta_json_schema>

```json
{
  "generated": "2026-01-15T12:00:00Z",
  "gitSha": "abc123",
  "docs": {
    "architecture.md": {
      "updated": "2026-01-15T12:00:00Z",
      "watchPatterns": ["**/package.json", "turbo.json", "src/**/index.ts"]
    }
  }
}
```

</meta_json_schema>

<success_criteria>

- [ ] `.claude/docs/` created with modular files
- [ ] Each doc is 300-600 tokens (focused, scannable)
- [ ] `_index.md` provides quick reference
- [ ] `.meta.json` tracks git SHA and watch patterns
- [ ] Manual edits preserved between runs
- [ ] Files are git-tracked (not ignored)

</success_criteria>

<constraints>

- Maximum 6 parallel Explore agents - prevent context overflow
- Each doc must be 300-600 tokens - focused and scannable
- Preserve manual edits between merge markers - never overwrite user content
- `.meta.json` required - enables incremental updates
- Monorepo packages get separate doc trees - no monolithic docs

</constraints>

<anti_patterns>

- **Monolithic docs**: Single large file defeats progressive disclosure purpose.
- **Missing meta.json**: Without staleness tracking, every run is full regeneration.
- **Overwriting manual edits**: Ignoring merge markers destroys user additions.
- **Too many agents**: More than 6 fragments context and slows synthesis.
- **Ignoring monorepo structure**: Flat docs for workspaces miss package boundaries.

</anti_patterns>

<related_skills>

| Skill                                      | Relationship                    |
| ------------------------------------------ | ------------------------------- |
| `Skill({ skill: "flow:enhance:explore" })` | Powers the parallel exploration |
| `Skill({ skill: "devtools:turbo" })`       | Monorepo detection patterns     |
| `Skill({ skill: "devtools:drizzle" })`     | Data layer documentation        |

</related_skills>

<evolution>

**Extension points:**

- Custom doc templates via `templates/` directory
- Additional exploration agents for domain-specific docs
- Integration with external doc platforms (Notion, Confluence)
- Custom staleness detection rules in `.meta.json`

</evolution>
