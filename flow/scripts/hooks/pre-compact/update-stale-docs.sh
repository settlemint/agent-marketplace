#!/usr/bin/env bash
# Before compaction, check if modified files warrant doc updates
# Hook: PreCompact

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="update-stale-docs"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# State file with modified files from this session
STATE_FILE=".claude/flow/session-modified-files.json"
META_FILE=".claude/docs/.meta.json"

# Skip if no tracking data
if [[ ! -f "$STATE_FILE" ]]; then
	exit 0
fi

# Skip if no docs to update
if [[ ! -f "$META_FILE" ]]; then
	exit 0
fi

# Check if jq is available
if ! command -v jq &>/dev/null; then
	exit 0
fi

# Get modified files from session
MODIFIED_FILES=$(jq -r '.files[]?' "$STATE_FILE" 2>/dev/null)

if [[ -z "$MODIFIED_FILES" ]]; then
	exit 0
fi

# Get watch patterns from meta
DOC_PATTERNS=$(jq -r '.docs | to_entries[] | "\(.key):\(.value.watchPatterns | join(","))"' "$META_FILE" 2>/dev/null)

# Track which docs might be stale
STALE_DOCS=""

# Check each modified file against watch patterns
while IFS= read -r file; do
	[[ -z "$file" ]] && continue

	while IFS=: read -r doc patterns; do
		# Simple pattern matching (supports * wildcards)
		IFS=',' read -ra PATTERN_ARRAY <<<"$patterns"
		for pattern in "${PATTERN_ARRAY[@]}"; do
			# Convert glob to regex-ish matching
			pattern_regex=$(echo "$pattern" | sed 's/\*\*/.*/' | sed 's/\*/.*/g')
			if echo "$file" | grep -qE "$pattern_regex"; then
				if [[ ! "$STALE_DOCS" =~ $doc ]]; then
					STALE_DOCS="$STALE_DOCS $doc"
				fi
			fi
		done
	done <<<"$DOC_PATTERNS"
done <<<"$MODIFIED_FILES"

# Report stale docs for context preservation
if [[ -n "$STALE_DOCS" ]]; then
	STALE_COUNT=$(echo "$STALE_DOCS" | wc -w | tr -d ' ')
	log_info "event=STALE_DOCS_DETECTED" "count=$STALE_COUNT" "docs=$STALE_DOCS"
	echo "context: Files modified this session may affect these docs:$STALE_DOCS"
	echo "context: Consider running Skill({ skill: \"flow:init-enhanced\", args: \"--incremental\" }) after compaction"
else
	log_debug "event=NO_STALE_DOCS"
fi

# Clean up session tracking
rm -f "$STATE_FILE"
log_debug "event=SESSION_TRACKING_CLEANED"

exit 0
