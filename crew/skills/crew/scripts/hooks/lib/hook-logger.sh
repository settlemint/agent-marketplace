#!/bin/bash
# Hook logging helper - source this in hook scripts
#
# USAGE PATTERNS:
#
# Pattern 1: Simple hooks (manual result tracking)
#   source "$(dirname "$0")/../lib/hook-logger.sh"
#   result="success"
#   if [[ some_condition ]]; then
#       echo "ACTION REQUIRED: ..."
#       result="action-required"
#   fi
#   log_hook "PostToolUse" "script-name" "$result"
#
# Pattern 2: Hooks running external commands (automatic error capture)
#   source "$(dirname "$0")/../lib/hook-logger.sh"
#   main() {
#       # ... your logic ...
#       some_command_that_might_fail || return 1
#   }
#   run_and_log_hook "PostToolUse" "script-name" main
#
# Pattern 3: Explicit error logging
#   if ! some_operation; then
#       log_hook_error "PostToolUse" "script-name" "Operation failed: reason"
#   fi

HOOK_LOG_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/state"
HOOK_LOG_FILE="$HOOK_LOG_DIR/hook-log.txt"

log_hook() {
	local hook_type="$1"
	local script_name="$2"
	local result="${3:-success}"
	local details="${4:-}"

	# Ensure log directory exists
	mkdir -p "$HOOK_LOG_DIR"

	# Format: timestamp | hook_type | script | result | details
	local timestamp
	timestamp=$(date +"%Y-%m-%d %H:%M:%S")

	# Prefix failed entries with ❌ for easy scanning
	local prefix=""
	if [[ "$result" == ERROR* ]] || [[ "$result" == FAILED* ]]; then
		prefix="❌ "
	fi
	local log_entry="$prefix$timestamp | $hook_type | $script_name | $result"

	if [ -n "$details" ]; then
		log_entry="$log_entry | $details"
	fi

	echo "$log_entry" >>"$HOOK_LOG_FILE"

	# Keep only last 500 entries
	if [ "$(wc -l <"$HOOK_LOG_FILE" 2>/dev/null || echo 0)" -gt 500 ]; then
		tail -500 "$HOOK_LOG_FILE" >"$HOOK_LOG_FILE.tmp"
		mv "$HOOK_LOG_FILE.tmp" "$HOOK_LOG_FILE"
	fi
}

# Auto-detect hook type from script path
detect_hook_type() {
	local script_path="$1"
	case "$script_path" in
	*session-start*) echo "SessionStart" ;;
	*user-prompt*) echo "UserPromptSubmit" ;;
	*pre-tool*) echo "PreToolUse" ;;
	*post-tool*) echo "PostToolUse" ;;
	*pre-compact*) echo "PreCompact" ;;
	*) echo "Unknown" ;;
	esac
}

# Wrapper to run a hook command and automatically log success/failure with error details
# Usage: run_and_log_hook "hook_type" "script_name" command args...
run_and_log_hook() {
	local hook_type="$1"
	local script_name="$2"
	shift 2

	local output
	local exit_code

	# Capture both stdout and stderr, and the exit code
	output=$("$@" 2>&1)
	exit_code=$?

	# Log full output for both success and failure
	if [ $exit_code -eq 0 ]; then
		log_hook "$hook_type" "$script_name" "success" "$output"
	else
		log_hook "$hook_type" "$script_name" "FAILED:$exit_code" "$output"
	fi

	# Still output to stdout for Claude to see
	if [ -n "$output" ]; then
		echo "$output"
	fi

	return $exit_code
}

# Log a failure with error message (for scripts that catch their own errors)
# Usage: log_hook_error "hook_type" "script_name" "error message"
log_hook_error() {
	local hook_type="$1"
	local script_name="$2"
	local error_msg="$3"

	log_hook "$hook_type" "$script_name" "ERROR" "$error_msg"
}
