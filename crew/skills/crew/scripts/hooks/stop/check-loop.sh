#!/usr/bin/env bash
# Stop hook: Check if iteration loop should continue
# This intercepts session exits and re-feeds prompts if loop is active
# State is stored in unified branch state: .claude/branches/{branch}/state.json

set -euo pipefail

cd "$CLAUDE_PROJECT_DIR" || exit 0

# Get current branch for state file location
BRANCH=$(git branch --show-current 2>/dev/null || echo '')
if [[ -z $BRANCH ]]; then
	BRANCH=$(git rev-parse --short HEAD 2>/dev/null || echo 'unknown')
fi
SAFE_BRANCH=$(echo "$BRANCH" | tr '/' '-')
STATE_FILE=".claude/branches/$SAFE_BRANCH/state.json"

# No state file - allow normal exit
if [ ! -f "$STATE_FILE" ]; then
	exit 0
fi

# Read loop state from unified state file
STATE=$(cat "$STATE_FILE")
ACTIVE=$(echo "$STATE" | jq -r '.loop.active // false')
ITERATION=$(echo "$STATE" | jq -r '.loop.iteration // 1')
MAX_ITERATIONS=$(echo "$STATE" | jq -r '.loop.maxIterations // 10')
COMPLETION_PROMISE=$(echo "$STATE" | jq -r '.loop.completionPromise // "COMPLETE"')
PROMPT=$(echo "$STATE" | jq -r '.loop.prompt // ""')

# Loop not active - allow exit
if [ "$ACTIVE" != "true" ]; then
	exit 0
fi

# Check if we've hit max iterations
if [ "$ITERATION" -ge "$MAX_ITERATIONS" ]; then
	# Clear loop state (set inactive, preserve other state)
	jq '.loop.active = false' "$STATE_FILE" >"${STATE_FILE}.tmp"
	mv "${STATE_FILE}.tmp" "$STATE_FILE"

	echo ""
	echo "═══════════════════════════════════════════════════════════"
	echo "LOOP ENDED - Maximum iterations reached ($MAX_ITERATIONS)"
	echo "═══════════════════════════════════════════════════════════"
	echo ""
	echo "The loop has completed its maximum iterations."
	echo "Review progress and decide next steps:"
	echo "  - Continue manually from current state"
	echo "  - Start new loop: /workflows:loop \"...\""
	echo "  - Create handoff: /workflows:handoff session"
	echo ""
	exit 0
fi

# Check if completion promise was output (check recent conversation context)
# Note: In Claude Code, the Stop hook receives CLAUDE_STOP_TRANSCRIPT with recent output
if [ -n "${CLAUDE_STOP_TRANSCRIPT:-}" ]; then
	if echo "$CLAUDE_STOP_TRANSCRIPT" | grep -qF "<promise>$COMPLETION_PROMISE</promise>"; then
		# Completion detected - clear loop state (set inactive, preserve other state)
		jq '.loop.active = false' "$STATE_FILE" >"${STATE_FILE}.tmp"
		mv "${STATE_FILE}.tmp" "$STATE_FILE"

		echo ""
		echo "═══════════════════════════════════════════════════════════"
		echo "LOOP COMPLETE - Promise fulfilled!"
		echo "═══════════════════════════════════════════════════════════"
		echo ""
		echo "Completion promise detected: <promise>$COMPLETION_PROMISE</promise>"
		echo ""
		echo "Next steps:"
		echo "  - Create handoff: /workflows:handoff task \"Loop completed\""
		echo "  - Compound learnings: /workflows:compound"
		echo ""
		exit 0
	fi
fi

# Loop should continue - increment iteration
NEXT_ITERATION=$((ITERATION + 1))

# Update loop iteration in unified state file
jq --argjson iter "$NEXT_ITERATION" '.loop.iteration = $iter' "$STATE_FILE" >"${STATE_FILE}.tmp"
mv "${STATE_FILE}.tmp" "$STATE_FILE"

# Re-feed the prompt (BLOCK exit by outputting continuation)
echo ""
echo "═══════════════════════════════════════════════════════════"
echo "LOOP ITERATION $NEXT_ITERATION of $MAX_ITERATIONS"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "TASK:"
echo "$PROMPT"
echo ""
echo "COMPLETION CRITERIA:"
echo "  Output: <promise>$COMPLETION_PROMISE</promise>"
echo ""
echo "PROGRESS CHECK:"
echo "  - Review what was done in previous iteration"
echo "  - Check test results: bun run test"
echo "  - Check CI status: bun run ci"
echo "  - If complete, output the promise tag"
echo "  - If not, continue working"
echo ""
echo "To stop early: /workflows:cancel-loop"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Exit with special code to indicate continuation needed
# Claude Code interprets this as "don't exit, continue with the output"
exit 1
