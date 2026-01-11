#!/usr/bin/env bash
# Check phantom installation and configure optimal settings on session start
#
# PERFORMANCE: Fast check, only installs if missing
# IDEMPOTENT: Safe to run multiple times

# Hooks must never fail
set +e

# Read stdin to check agent_type (since v2.1.2)
INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // ""' 2>/dev/null)

# Skip for subagents - they don't need phantom setup
if [[ -n "$AGENT_TYPE" && "$AGENT_TYPE" != "null" ]]; then
  exit 0
fi

# Fast path: check if phantom is installed
if command -v phantom &>/dev/null; then
  # Ensure optimal configuration (fast, no output unless changed)
  configure_if_unset() {
    local key="$1"
    local value="$2"
    local current
    current=$(phantom preferences get "$key" 2>/dev/null || echo "")
    if [[ -z "$current" ]]; then
      phantom preferences set "$key" "$value" 2>/dev/null
      echo "Phantom: set $key=$value"
    fi
  }

  # Configure optimal defaults if not already set
  configure_if_unset "editor" "code --reuse-window"
  configure_if_unset "ai" "claude"

  exit 0
fi

# Phantom not installed - install via Homebrew (fast)
echo "Installing phantom CLI for worktree management..."

if command -v brew &>/dev/null; then
  brew install phantom 2>/dev/null
  if command -v phantom &>/dev/null; then
    echo "Phantom installed successfully"

    # Configure optimal settings
    phantom preferences set editor "code --reuse-window" 2>/dev/null
    phantom preferences set ai "claude" 2>/dev/null
    echo "Phantom configured with optimal settings"
  else
    echo "Warning: Failed to install phantom. Install manually: brew install phantom"
  fi
else
  echo "Warning: Homebrew not available. Install phantom manually: brew install phantom"
fi

exit 0
