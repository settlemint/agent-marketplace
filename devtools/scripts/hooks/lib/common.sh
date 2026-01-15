#!/usr/bin/env bash
# Common utilities for devtools hooks
# Source this file in hook scripts for consistent logging

# --- Log Levels ---
LOG_DEBUG=0
LOG_INFO=1
LOG_WARN=2
LOG_ERROR=3

# Current log level (default: INFO)
DEVTOOLS_LOG_LEVEL=${DEVTOOLS_LOG_LEVEL:-$LOG_INFO}

# --- Paths ---
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
DEVTOOLS_LOG_DIR="$PROJECT_DIR/.claude/devtools/logs"
DEVTOOLS_LOG_FILE="${DEVTOOLS_LOG_FILE:-$DEVTOOLS_LOG_DIR/devtools.log}"

# Script identification (set by sourcing script)
SCRIPT_NAME="${SCRIPT_NAME:-unknown}"

# --- Logging Functions ---

# Initialize logging
log_init() {
	mkdir -p "$DEVTOOLS_LOG_DIR" 2>/dev/null || true
	if [[ -n "$SCRIPT_NAME" && "$SCRIPT_NAME" != "unknown" ]]; then
		mkdir -p "$DEVTOOLS_LOG_DIR/hooks/$SCRIPT_NAME" 2>/dev/null || true
	fi
}

# Get current ISO 8601 timestamp
_timestamp() {
	date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# Get today's date for log file rotation
_today() {
	date -u +"%Y-%m-%d"
}

# Core log function
_log() {
	local level=$1
	shift
	local message=$1
	shift

	local prefix=""

	case $level in
	DEBUG)
		[[ $DEVTOOLS_LOG_LEVEL -gt $LOG_DEBUG ]] && return
		prefix="DEBUG"
		;;
	INFO)
		[[ $DEVTOOLS_LOG_LEVEL -gt $LOG_INFO ]] && return
		prefix="INFO"
		;;
	WARN)
		[[ $DEVTOOLS_LOG_LEVEL -gt $LOG_WARN ]] && return
		prefix="WARN"
		;;
	ERROR)
		prefix="ERROR"
		;;
	*)
		prefix="INFO"
		;;
	esac

	local timestamp
	timestamp=$(_timestamp)

	# Build log entry
	local log_entry="[$timestamp] $prefix script=$SCRIPT_NAME"
	if [[ -n "$message" ]]; then
		log_entry="$log_entry $message"
	fi
	while [[ $# -gt 0 ]]; do
		log_entry="$log_entry $1"
		shift
	done

	# Write to combined log file
	echo "$log_entry" >>"$DEVTOOLS_LOG_FILE" 2>/dev/null || true

	# Write to per-hook daily log file
	if [[ -n "$SCRIPT_NAME" && "$SCRIPT_NAME" != "unknown" ]]; then
		local hook_log
		hook_log="$DEVTOOLS_LOG_DIR/hooks/$SCRIPT_NAME/$(_today).log"
		echo "$log_entry" >>"$hook_log" 2>/dev/null || true
	fi
}

# Convenience functions
log_debug() { _log DEBUG "$@"; }
log_info() { _log INFO "$@"; }
log_warn() { _log WARN "$@"; }
log_error() { _log ERROR "$@"; }

# Structured event logging
log_event() {
	local status=$1
	shift
	_log INFO "event=$status" "$@"
}
