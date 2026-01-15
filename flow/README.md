# Flow Plugin

Hook-based agent enhancement and workflow automation for Claude Code.

## Architecture

Flow uses **native Claude agents + hook-injected enhancements** rather than custom slash commands:

1. **Native agents** (Explore, Plan, General-purpose) do the actual work
2. **Hooks** detect context and inject domain expertise via skill suggestions
3. **State persistence** tracks workflows across sessions

## Skills

### Agent Enhancement Skills

Meta-skills that enhance built-in Claude Code agents with Rule of Five convergence patterns.

| Skill                          | Usage                                              | Description                                        |
| ------------------------------ | -------------------------------------------------- | -------------------------------------------------- |
| `flow:enhance:explore`         | `Skill({ skill: "flow:enhance:explore" })`         | 5-angle exploration, progressive disclosure        |
| `flow:enhance:plan`            | `Skill({ skill: "flow:enhance:plan" })`            | 5-pass refinement, parallelization mapping         |
| `flow:enhance:general-purpose` | `Skill({ skill: "flow:enhance:general-purpose" })` | 30-second reality check, evidence-based completion |

### Workflow Skills

| Skill                 | Usage                                     | Description                |
| --------------------- | ----------------------------------------- | -------------------------- |
| `flow:fix-pr-reviews` | `Skill({ skill: "flow:fix-pr-reviews" })` | Resolve PR review comments |

## Hooks

The plugin implements Claude Code hook lifecycle events:

| Hook              | Purpose                                   |
| ----------------- | ----------------------------------------- |
| SessionStart      | Initialize flow state, check dependencies |
| PreToolUse (Task) | Enhance agents with matching skills       |
| PostToolUse       | Track progress, verify outputs            |
| PreCompact        | Save state before compaction              |
| Stop              | Cleanup and finalization                  |

## How Enhancement Works

When you launch an Explore, Plan, or General-purpose agent:

1. `enhance-agent.sh` hook detects the agent type
2. Hook outputs a skill suggestion directive
3. Claude loads the matching `flow:enhance:*` skill
4. Agent runs with enhanced patterns (Rule of Five, convergence signals, etc.)

## Installation

```bash
# Via marketplace
/plugin marketplace add settlemint/agent-marketplace
/plugin install flow@settlemint

# Local development
claude --plugin-dir ~/path/to/flow
```

## Structure

```
flow/
├── .claude-plugin/plugin.json    # Plugin metadata
├── hooks/hooks.json              # Hook definitions
├── skills/
│   ├── enhance/                  # Agent enhancement skills
│   │   ├── explore/              # Explore agent enhancement
│   │   ├── plan/                 # Plan agent enhancement
│   │   └── general-purpose/      # General-purpose enhancement
│   └── fix-pr-reviews/           # PR review resolution
└── scripts/
    └── hooks/                    # Hook implementations
```

## License

MIT
