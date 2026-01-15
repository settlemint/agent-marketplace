#!/usr/bin/env bash
# Flow logging utilities
# Sourced by other scripts

set -euo pipefail

# Log levels
LOG_DEBUG=0
LOG_INFO=1
LOG_WARN=2
LOG_ERROR=3

# Current log level (default: INFO)
FLOW_LOG_LEVEL=${FLOW_LOG_LEVEL:-$LOG_INFO}

# Color codes
COLOR_RESET="\033[0m"
COLOR_DEBUG="\033[36m" # Cyan
COLOR_INFO="\033[32m"  # Green
COLOR_WARN="\033[33m"  # Yellow
COLOR_ERROR="\033[31m" # Red

# Log function
log() {
	local level=$1
	local message=$2
	local color=""
	local prefix=""

	case $level in
	$LOG_DEBUG)
		[[ $FLOW_LOG_LEVEL -gt $LOG_DEBUG ]] && return
		color=$COLOR_DEBUG
		prefix="DEBUG"
		;;
	$LOG_INFO)
		[[ $FLOW_LOG_LEVEL -gt $LOG_INFO ]] && return
		color=$COLOR_INFO
		prefix="INFO"
		;;
	$LOG_WARN)
		[[ $FLOW_LOG_LEVEL -gt $LOG_WARN ]] && return
		color=$COLOR_WARN
		prefix="WARN"
		;;
	$LOG_ERROR)
		color=$COLOR_ERROR
		prefix="ERROR"
		;;
	esac

	echo -e "${color}[Flow:${prefix}]${COLOR_RESET} $message" >&2
}

# Convenience functions
log_debug() { log $LOG_DEBUG "$1"; }
log_info() { log $LOG_INFO "$1"; }
log_warn() { log $LOG_WARN "$1"; }
log_error() { log $LOG_ERROR "$1"; }

# Log to file (optional)
log_to_file() {
	local message=$1
	local log_file="${FLOW_LOG_FILE:-.claude/flow/flow.log}"

	if [[ -n "${FLOW_LOG_FILE:-}" ]]; then
		echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $message" >>"$log_file"
	fi
}
