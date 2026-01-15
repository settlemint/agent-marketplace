#!/usr/bin/env bash
# Check if .claude/docs are stale and suggest refresh
# Hook: SessionStart (startup)

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCRIPT_NAME="check-docs-freshness"
# shellcheck source=../lib/common.sh
source "${SCRIPT_DIR}/../lib/common.sh"
log_init

# Skip for subagents
if [[ "${CLAUDE_AGENT_TYPE:-}" == "subagent" ]]; then
	exit 0
fi

META_FILE=".claude/docs/.meta.json"

# If no docs exist, log only (no output to avoid hook error display)
if [[ ! -f "$META_FILE" ]]; then
	log_info "event=DOCS_MISSING"
	exit 0
fi

# Check if jq is available
if ! command -v jq &>/dev/null; then
	exit 0
fi

# Get last generation SHA
LAST_SHA=$(jq -r '.gitSha // empty' "$META_FILE" 2>/dev/null)
if [[ -z "$LAST_SHA" ]]; then
	log_info "event=DOCS_METADATA_INCOMPLETE"
	exit 0
fi

# Get current HEAD
CURRENT_SHA=$(git rev-parse HEAD 2>/dev/null) || exit 0

# If same SHA, docs are up to date
if [[ "$LAST_SHA" == "$CURRENT_SHA" ]]; then
	log_debug "event=DOCS_CURRENT"
	exit 0
fi

# Count changed files since last generation
CHANGED_COUNT=$(git diff --name-only "$LAST_SHA" HEAD 2>/dev/null | wc -l | tr -d ' ')

# Get generation timestamp
GENERATED=$(jq -r '.generated // empty' "$META_FILE" 2>/dev/null)

# Calculate age in days
if [[ -n "$GENERATED" ]]; then
	GENERATED_TS=$(date -j -f "%Y-%m-%dT%H:%M:%S" "${GENERATED%%.*}" +%s 2>/dev/null || echo 0)
	NOW_TS=$(date +%s)
	AGE_DAYS=$(((NOW_TS - GENERATED_TS) / 86400))
else
	AGE_DAYS="unknown"
fi

# Log docs status - no output to avoid hook error display
if [[ "$CHANGED_COUNT" -gt 100 ]]; then
	log_info "event=DOCS_VERY_STALE" "changed_files=$CHANGED_COUNT" "age_days=$AGE_DAYS"
elif [[ "$CHANGED_COUNT" -gt 20 ]]; then
	log_info "event=DOCS_STALE" "changed_files=$CHANGED_COUNT" "age_days=$AGE_DAYS"
else
	log_debug "event=DOCS_OK" "changed_files=$CHANGED_COUNT"
fi

exit 0
