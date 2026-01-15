#!/usr/bin/env bash
# Check for required dependencies on fresh startup
# Runs on: startup (once)

set -euo pipefail

# Read event data from stdin
EVENT_DATA=$(cat)

# Skip for subagents
AGENT_TYPE=$(echo "$EVENT_DATA" | jq -r '.agent_type // "main"')
if [[ "$AGENT_TYPE" != "main" ]]; then
	exit 0
fi

# Check for jq (required for JSON processing)
if ! command -v jq &>/dev/null; then
	echo "Flow: Warning - 'jq' not found. Some flow features may not work correctly."
	echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
fi

exit 0
