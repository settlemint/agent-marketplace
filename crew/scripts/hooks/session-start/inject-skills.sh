#!/usr/bin/env bash
# Inject available crew skills and commands at session start
# Helps Claude know what tools are available
#
# AGENT_TYPE DETECTION (Claude Code 2.1.2+):
# Subagents (task, background, etc.) get no output to reduce context noise

set +e

is_truthy() {
  case "${1:-}" in
    1|true|yes|on) return 0 ;;
    *) return 1 ;;
  esac
}

QUIET="${CLAUDE_QUIET:-${CREW_QUIET:-}}"
TOKEN_SAVER="${CLAUDE_TOKEN_SAVER:-${CREW_TOKEN_SAVER:-}}"

# Read stdin to get hook input (includes agent_type since v2.1.2)
INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // ""' 2>/dev/null)
AGENT_TYPE="${AGENT_TYPE:-}"

# Skip output for subagents - they have specific missions and don't need the full banner
# Known subagent types: task, background, Bash, Explore, Plan, haiku, general-purpose
if [[ -n "$AGENT_TYPE" && "$AGENT_TYPE" != "null" ]]; then
  # Any non-empty agent_type means this is a subagent, skip output
  exit 0
fi

if is_truthy "$QUIET"; then
  exit 0
fi

if is_truthy "$TOKEN_SAVER"; then
  cat <<'EOF'
Crew: /crew:plan /crew:work /crew:git:commit /crew:git:pr:create
EOF
  exit 0
fi

cat <<'EOF'
Crew plugin active.
Commands: /crew:plan /crew:work /crew:git:commit /crew:git:pr:create
Tips: use TodoWrite, /crew:work:ci for background CI, /crew:ast-grep for refactors.
EOF

exit 0
