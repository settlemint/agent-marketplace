#!/usr/bin/env bash
# Shared skill matching library
# Provides match_skills_from_triggers() function for dynamic skill discovery
#
# Usage:
#   source "$LIB_DIR/skill-matcher.sh"
#   matched=$(match_skills_from_triggers "$prompt" "$lib_dir")
#   # Or with activation logging:
#   matched=$(match_skills_from_triggers "$prompt" "$lib_dir" "log" "source_name")

# Logging is inherited from parent script that sources common.sh
# If not available, define no-op functions
if ! declare -F log_debug >/dev/null 2>&1; then
	log_debug() { :; }
	log_info() { :; }
fi
if ! declare -F log_skill_activation >/dev/null 2>&1; then
	log_skill_activation() { :; }
fi

# Match skills based on trigger patterns in SKILL.md frontmatter
# Args:
#   $1 - prompt text to match against
#   $2 - path to lib directory (for scan-skill-triggers.sh)
#   $3 - (optional) "log" to enable activation logging
#   $4 - (optional) source identifier for logging (e.g., "analyze-intent", "enhance-agent")
# Returns: space-separated list of matching skill names
match_skills_from_triggers() {
	local prompt="$1"
	local lib_dir="$2"
	local do_log="${3:-}"
	local source="${4:-unknown}"
	local matched_skills=""

	# Skip if no prompt
	[[ -z "$prompt" ]] && return

	# Get or build trigger cache
	local cache_file
	cache_file=$("$lib_dir/scan-skill-triggers.sh" 2>/dev/null)

	# If cache doesn't exist or script failed, exit gracefully
	if [[ ! -f "$cache_file" ]]; then
		log_debug "event=CACHE_MISSING"
		return
	fi

	# Source the cache to get SKILL_TRIGGERS associative array
	# shellcheck source=/dev/null
	source "$cache_file"

	# Convert prompt to lowercase for matching
	local prompt_lower
	prompt_lower=$(echo "$prompt" | tr '[:upper:]' '[:lower:]')

	# Check each skill's triggers
	for skill in "${!SKILL_TRIGGERS[@]}"; do
		local pattern="${SKILL_TRIGGERS[$skill]}"

		# Skip empty patterns
		[[ -z "$pattern" ]] && continue

		# Test pattern match
		if [[ "$prompt_lower" =~ $pattern ]]; then
			if [[ -n "$matched_skills" ]]; then
				matched_skills="$matched_skills $skill"
			else
				matched_skills="$skill"
			fi

			# Log activation if requested
			if [[ "$do_log" == "log" ]]; then
				log_skill_activation "$skill" "$pattern" "$prompt" "$source"
			fi
		fi
	done

	if [[ -n "$matched_skills" ]]; then
		log_debug "event=SKILLS_MATCHED" "skills=$matched_skills"
	fi

	echo "$matched_skills"
}
