#!/usr/bin/env bash
# Inject available crew skills and commands at session start
# Helps Claude know what tools are available
#
# AGENT_TYPE DETECTION (Claude Code 2.1.2+):
# Subagents (task, background, etc.) get no output to reduce context noise

set +e

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

cat <<'EOF'
## Crew Plugin

**Commands**: `/crew:plan` (planning) | `/crew:work` (execute) | `/crew:git:commit` | `/crew:git:pr:create`

**TDD Required**: Write failing test FIRST → minimal code → refactor. Coverage: 80%+ lines.

**Skills**: Auto-loaded by triggers (react, drizzle, vitest, playwright, solidity, viem, etc.)

**Best Practices**: Use TodoWrite for progress, `crew:work:ci` for background CI, `crew:ast-grep` for refactoring.
EOF

exit 0
