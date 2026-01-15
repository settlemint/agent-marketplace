# Hook Conventions

Guidelines for implementing and maintaining hook scripts in the flow plugin.

## Error Handling

**All hooks must use `set +e`** (permissive error handling). Hooks must never crash Claude Code or interrupt user workflows.

```bash
#!/usr/bin/env bash
# Hooks must never fail
set +e
```

## Output Conventions

| Stream   | Purpose                           | Example                                    |
| -------- | --------------------------------- | ------------------------------------------ |
| `stdout` | Data output (parsed by Claude)    | `echo "Flow: Active workflow 'feature-x'"` |
| `stderr` | Feedback/warnings (shown to user) | `echo '{"feedback": "Warning..."}' >&2`    |

## Exit Codes

Always return `exit 0`. Non-zero exit codes can disrupt Claude Code's hook processing.

## jq Error Handling

When using jq, always include error handling:

```bash
# Bad - can fail silently
VALUE=$(echo "$INPUT" | jq -r '.field')

# Good - handles parse errors
VALUE=$(echo "$INPUT" | jq -r '.field // ""' 2>/dev/null || echo "")
```

## Environment Variables

Available environment variables:

| Variable             | Description                   | Default              |
| -------------------- | ----------------------------- | -------------------- |
| `CLAUDE_PROJECT_DIR` | Project root directory        | `$(pwd)`             |
| `CLAUDE_SESSION_ID`  | Current session identifier    | Process ID           |
| `CLAUDE_PLUGIN_ROOT` | Plugin installation directory | Detected from script |

## Logging

Hooks can write logs to `.claude/flow/logs/hooks/<hook-name>/`:

```bash
LOG_DIR="$PROJECT_DIR/.claude/flow/logs/hooks/my-hook"
LOG_FILE="$LOG_DIR/$(date -u +%Y-%m-%d).log"
mkdir -p "$LOG_DIR" 2>/dev/null
echo "[$(date -u +%Y-%m-%dT%H:%M:%SZ)] Event logged" >> "$LOG_FILE"
```

## Hook Registration

Hooks are registered in `hooks/hooks.json`:

```json
{
  "hooks": [
    {
      "hook": "HookType",
      "command": "bash scripts/hooks/path/to/script.sh",
      "matcher": {
        "tool_name": "ToolName"
      }
    }
  ]
}
```

## Session Deduplication

To show hints only once per session:

```bash
SESSION_ID="${CLAUDE_SESSION_ID:-$$}"
MARKER="$PROJECT_DIR/.claude/flow/hooks/.my-hint-${SESSION_ID}"

if [[ -f "$MARKER" ]]; then
    exit 0  # Already shown this session
fi

# Show hint...
mkdir -p "$(dirname "$MARKER")" 2>/dev/null
touch "$MARKER" 2>/dev/null
```

## Shared Libraries

Common functionality is in `scripts/hooks/lib/`:

```bash
SCRIPT_DIR=$(dirname "$0")
LIB_DIR="$SCRIPT_DIR/../lib"

# shellcheck source=../lib/skill-matcher.sh
source "$LIB_DIR/skill-matcher.sh"
```
