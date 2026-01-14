#!/usr/bin/env bash
# Inject router skill on session start
# Outputs context that tells Claude to load the crew:router skill
#
# This enables intelligent request routing:
# - STEERING: Continue/adjust current work
# - TRIVIAL: Execute immediately
# - SUBSTANTIAL: Plan first, then execute

# Hooks must never fail
set +e

is_truthy() {
	case "${1:-}" in
	1 | true | yes | on) return 0 ;;
	*) return 1 ;;
	esac
}

QUIET="${CLAUDE_QUIET:-${CREW_QUIET:-}}"
TOKEN_SAVER="${CLAUDE_TOKEN_SAVER:-${CREW_TOKEN_SAVER:-}}"

# Read stdin for event info
INPUT=$(cat)
AGENT_TYPE=$(echo "$INPUT" | jq -r '.agent_type // ""' 2>/dev/null)

# Skip for subagents - they don't need router
if [[ -n "$AGENT_TYPE" && "$AGENT_TYPE" != "null" ]]; then
	exit 0
fi

# Quiet mode: suppress output entirely
if is_truthy "$QUIET"; then
	exit 0
fi

# Token-saver mode: minimal output
if is_truthy "$TOKEN_SAVER"; then
	echo ""
	echo "<router-skill>Skill({ skill: \"crew:router\" })</router-skill>"
	echo ""
	exit 0
fi

# Output router loading instruction
echo ""
echo "<router-skill>"
echo "INTELLIGENT ROUTING ACTIVE"
echo ""
echo "Load: Skill({ skill: \"crew:router\" })"
echo ""
echo "Request classification:"
echo "- STEERING: Feedback/adjustments to current work"
echo "- TRIVIAL: Simple, single-target changes"
echo "- SUBSTANTIAL: Features requiring planning"
echo ""
echo "Classification happens automatically. No commands needed."
echo ""
echo "To classify the user's request, analyze:"
echo "1. Message length and keywords"
echo "2. Current session state (active plan, pending todos)"
echo "3. Context references (\"it\", \"that\" = steering)"
echo ""
echo "Then route to appropriate workflow:"
echo "- Skill({ skill: \"crew:router\" }) with workflows/steering.md"
echo "- Skill({ skill: \"crew:router\" }) with workflows/trivial.md"
echo "- Skill({ skill: \"crew:router\" }) with workflows/substantial.md"
echo "</router-skill>"
echo ""
