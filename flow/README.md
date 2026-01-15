# Flow Plugin

Workflow orchestration, state management, and productivity automation for Claude Code.

## Features

- **Workflow Management**: Start, pause, and complete structured workflows
- **State Persistence**: Automatic state saving across sessions
- **Intent Analysis**: Smart skill suggestions based on user input
- **Progress Tracking**: Automatic tracking of file modifications

## Skills

### Core Workflow Skills

| Skill          | Usage                              | Description                                    |
| -------------- | ---------------------------------- | ---------------------------------------------- |
| `flow:init`    | `Skill({ skill: "flow:init" })`    | Initialize flow in the current project         |
| `flow:status`  | `Skill({ skill: "flow:status" })`  | Show current workflow status                   |
| `flow:analyze` | `Skill({ skill: "flow:analyze" })` | Analyze codebase for patterns and improvements |
| `flow:suggest` | `Skill({ skill: "flow:suggest" })` | Suggest improvements based on analysis         |

### Workflow Lifecycle Skills

| Skill                    | Usage                                        | Description                   |
| ------------------------ | -------------------------------------------- | ----------------------------- |
| `flow:workflow:start`    | `Skill({ skill: "flow:workflow:start" })`    | Start a new workflow          |
| `flow:workflow:pause`    | `Skill({ skill: "flow:workflow:pause" })`    | Pause the current workflow    |
| `flow:workflow:complete` | `Skill({ skill: "flow:workflow:complete" })` | Complete the current workflow |

### Pattern & Knowledge Skills

| Skill                      | Usage                                          | Description                          |
| -------------------------- | ---------------------------------------------- | ------------------------------------ |
| `flow:guides:patterns`     | `Skill({ skill: "flow:guides:patterns" })`     | Core workflow patterns and templates |
| `flow:guides:analysis`     | `Skill({ skill: "flow:guides:analysis" })`     | Codebase analysis patterns           |
| `flow:guides:optimization` | `Skill({ skill: "flow:guides:optimization" })` | Optimization strategies              |

## Quick Start

```javascript
// Initialize flow in your project
Skill({ skill: "flow:init" });

// Start a new workflow
Skill({ skill: "flow:workflow:start" });

// Check current status
Skill({ skill: "flow:status" });

// Analyze codebase
Skill({ skill: "flow:analyze" });

// Get improvement suggestions
Skill({ skill: "flow:suggest" });

// Complete workflow
Skill({ skill: "flow:workflow:complete" });
```

## Hooks

The plugin implements all Claude Code hook lifecycle events:

- **SessionStart**: Initialize flow state, check dependencies
- **PreToolUse**: Suggest skills, validate actions
- **PostToolUse**: Track progress, verify outputs
- **PreCompact**: Save state before compaction
- **UserPromptSubmit**: Analyze user intent
- **Stop**: Cleanup and finalization

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
├── .mcp.json                     # MCP server configuration
├── skills/                       # All skills
│   ├── init/                     # Initialize flow
│   ├── status/                   # Show status
│   ├── analyze/                  # Analyze codebase
│   ├── suggest/                  # Suggest improvements
│   ├── workflow/                 # Workflow lifecycle (namespaced)
│   │   ├── start/                # Start workflow
│   │   ├── pause/                # Pause workflow
│   │   └── complete/             # Complete workflow
│   ├── guides/                   # Knowledge & pattern skills (namespaced)
│   │   ├── patterns/             # Workflow patterns
│   │   ├── analysis/             # Analysis patterns
│   │   └── optimization/         # Optimization patterns
├── scripts/                      # Hook and utility scripts
├── agents/                       # Agent definitions
└── rules/                        # Pattern matching rules
```

## License

MIT
