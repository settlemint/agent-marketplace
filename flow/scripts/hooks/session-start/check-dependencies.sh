#!/usr/bin/env bash
# Check for required dependencies on fresh startup
# Runs on: startup (once)

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="check-dependencies"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read event data from stdin
EVENT_DATA=$(cat)

# Skip for subagents
AGENT_TYPE=$(echo "$EVENT_DATA" | jq -r '.agent_type // "main"' 2>/dev/null || echo "main")
if [[ "$AGENT_TYPE" != "main" ]]; then
	exit 0
fi

# Check for jq (required for JSON processing)
if ! command -v jq &>/dev/null; then
	log_warn "event=DEPENDENCY_MISSING" "dependency=jq"
	echo "Flow: Warning - 'jq' not found. Some flow features may not work correctly."
	echo "Install with: brew install jq (macOS) or apt-get install jq (Linux)"
else
	log_debug "event=DEPENDENCIES_OK"
fi

exit 0
