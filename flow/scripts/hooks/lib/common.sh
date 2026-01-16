#!/usr/bin/env bash
# Common utilities for flow hooks
# Source this file in hook scripts for consistent logging and utilities

# --- Log Levels ---
LOG_DEBUG=0
LOG_INFO=1
LOG_WARN=2
LOG_ERROR=3

# Current log level (default: INFO)
FLOW_LOG_LEVEL=${FLOW_LOG_LEVEL:-$LOG_INFO}

# --- Paths ---
# Project directory (where .claude/ lives)
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"

# Log directory structure
FLOW_LOG_DIR="$PROJECT_DIR/.claude/flow/logs"
FLOW_LOG_FILE="${FLOW_LOG_FILE:-$FLOW_LOG_DIR/flow.log}"

# Script identification (set by sourcing script)
SCRIPT_NAME="${SCRIPT_NAME:-unknown}"

# --- Color Codes (for stderr output) ---
COLOR_RESET="\033[0m"
COLOR_DEBUG="\033[36m" # Cyan
COLOR_INFO="\033[32m"  # Green
COLOR_WARN="\033[33m"  # Yellow
COLOR_ERROR="\033[31m" # Red

# --- Logging Functions ---

# Initialize logging (call after setting SCRIPT_NAME)
# Note: Per-hook directories are created lazily on first log write
log_init() {
  mkdir -p "$FLOW_LOG_DIR" 2>/dev/null || true
  # Per-hook directories now created lazily in _log() to avoid empty folders
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
# Usage: _log LEVEL "message" [key=value ...]
_log() {
  local level=$1
  shift
  local message=$1
  shift

  local color=""
  local prefix=""

  case $level in
    DEBUG)
      [[ $FLOW_LOG_LEVEL -gt $LOG_DEBUG ]] && return
      color=$COLOR_DEBUG
      prefix="DEBUG"
      ;;
    INFO)
      [[ $FLOW_LOG_LEVEL -gt $LOG_INFO ]] && return
      color=$COLOR_INFO
      prefix="INFO"
      ;;
    WARN)
      [[ $FLOW_LOG_LEVEL -gt $LOG_WARN ]] && return
      color=$COLOR_WARN
      prefix="WARN"
      ;;
    ERROR)
      color=$COLOR_ERROR
      prefix="ERROR"
      ;;
    *)
      prefix="INFO"
      color=$COLOR_INFO
      ;;
  esac

  local timestamp
  timestamp=$(_timestamp)

  # Build log entry with key=value pairs
  local log_entry="[$timestamp] $prefix script=$SCRIPT_NAME"
  if [[ -n "$message" ]]; then
    log_entry="$log_entry $message"
  fi
  # Append any additional key=value pairs
  while [[ $# -gt 0 ]]; do
    log_entry="$log_entry $1"
    shift
  done

  # Write to combined log file
  echo "$log_entry" >>"$FLOW_LOG_FILE" 2>/dev/null || true

  # Write to per-hook daily log file (lazy directory creation)
  if [[ -n "$SCRIPT_NAME" && "$SCRIPT_NAME" != "unknown" ]]; then
    local hook_dir="$FLOW_LOG_DIR/hooks/$SCRIPT_NAME"
    local hook_log
    hook_log="$hook_dir/$(_today).log"
    # Create directory only when we have something to write
    mkdir -p "$hook_dir" 2>/dev/null || true
    echo "$log_entry" >>"$hook_log" 2>/dev/null || true
  fi

  # Also output to stderr with colors (for terminal visibility during debugging)
  if [[ "${FLOW_LOG_STDERR:-}" == "1" ]]; then
    echo -e "${color}[Flow:${prefix}:${SCRIPT_NAME}]${COLOR_RESET} $message $*" >&2
  fi
}

# Convenience functions
log_debug() { _log DEBUG "$@"; }
log_info() { _log INFO "$@"; }
log_warn() { _log WARN "$@"; }
log_error() { _log ERROR "$@"; }

# Structured event logging (matches enhance-agent.sh pattern)
# Usage: log_event STATUS "key=value" ...
log_event() {
  local status=$1
  shift
  _log INFO "event=$status" "$@"
}

# --- Utility Functions ---

# Check if a command exists
has_command() {
  command -v "$1" &>/dev/null
}

# Safe JSON extraction with jq (returns empty string on failure)
json_get() {
  local input=$1
  local path=$2
  echo "$input" | jq -r "$path // \"\"" 2>/dev/null || echo ""
}

# Get session ID (for deduplication markers)
get_session_id() {
  echo "${CLAUDE_SESSION_ID:-$$}"
}

# Check if a session marker exists (for once-per-session hints)
session_marker_exists() {
  local marker_name=$1
  local session_id
  session_id=$(get_session_id)
  local marker_file="$PROJECT_DIR/.claude/flow/hooks/.${marker_name}-${session_id}"
  [[ -f "$marker_file" ]]
}

# Create a session marker
create_session_marker() {
  local marker_name=$1
  local session_id
  session_id=$(get_session_id)
  local marker_dir="$PROJECT_DIR/.claude/flow/hooks"
  local marker_file="$marker_dir/.${marker_name}-${session_id}"
  mkdir -p "$marker_dir" 2>/dev/null || true
  touch "$marker_file" 2>/dev/null || true
}

# --- Skill Activation Logging ---
# Logs skill activations for pattern evaluation
# Usage: log_skill_activation "skill_name" "trigger_pattern" "prompt_excerpt" "source" ["extra_key=value"]

SKILL_ACTIVATION_LOG="$PROJECT_DIR/.claude/flow/skill-activations.jsonl"

log_skill_activation() {
  local skill="$1"
  local trigger="$2"
  local prompt="$3"
  local source="$4"
  shift 4

  # Collect extra key=value args into JSON object
  local extra_json="{}"
  while [[ $# -gt 0 ]]; do
    local kv="$1"
    local key="${kv%%=*}"
    local value="${kv#*=}"
    extra_json=$(echo "$extra_json" | jq --arg k "$key" --arg v "$value" '. + {($k): $v}' 2>/dev/null || echo "$extra_json")
    shift
  done

  # Truncate prompt to 200 chars for storage efficiency
  local prompt_excerpt="${prompt:0:200}"
  [[ ${#prompt} -gt 200 ]] && prompt_excerpt="${prompt_excerpt}..."

  local timestamp
  timestamp=$(_timestamp)

  local session_id
  session_id=$(get_session_id)

  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

  # Build JSON entry with extra metadata
  local entry
  entry=$(jq -n \
    --arg ts "$timestamp" \
    --arg session "$session_id" \
    --arg branch "$branch" \
    --arg skill "$skill" \
    --arg trigger "$trigger" \
    --arg prompt "$prompt_excerpt" \
    --arg source "$source" \
    --argjson extra "$extra_json" \
    '{
			timestamp: $ts,
			session_id: $session,
			branch: $branch,
			skill: $skill,
			trigger_pattern: $trigger,
			prompt_excerpt: $prompt,
			source: $source,
			metadata: $extra
		}' 2>/dev/null)

  # Append to JSONL file
  mkdir -p "$(dirname "$SKILL_ACTIVATION_LOG")" 2>/dev/null || true
  echo "$entry" >>"$SKILL_ACTIVATION_LOG" 2>/dev/null || true

  # Also log to standard flow log for immediate visibility
  log_info "event=SKILL_ACTIVATED" "skill=$skill" "trigger=$trigger" "source=$source"
}

# --- Correction Logging ---
# Logs user corrections/direction changes for learning extraction
# Usage: log_correction "detected_pattern" "full_prompt"

CORRECTION_LOG="$PROJECT_DIR/.claude/flow/corrections.jsonl"

log_correction() {
  local pattern="$1"
  local prompt="$2"

  # Truncate prompt to 500 chars for storage efficiency
  local prompt_excerpt="${prompt:0:500}"
  [[ ${#prompt} -gt 500 ]] && prompt_excerpt="${prompt_excerpt}..."

  local timestamp
  timestamp=$(_timestamp)

  local session_id
  session_id=$(get_session_id)

  local branch
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "unknown")

  # Build JSON entry
  local entry
  entry=$(jq -n \
    --arg ts "$timestamp" \
    --arg session "$session_id" \
    --arg branch "$branch" \
    --arg pattern "$pattern" \
    --arg prompt "$prompt_excerpt" \
    '{
			timestamp: $ts,
			session_id: $session,
			branch: $branch,
			correction_pattern: $pattern,
			prompt_excerpt: $prompt
		}' 2>/dev/null)

  # Append to JSONL file
  mkdir -p "$(dirname "$CORRECTION_LOG")" 2>/dev/null || true
  echo "$entry" >>"$CORRECTION_LOG" 2>/dev/null || true

  # Also log to standard flow log for immediate visibility
  log_info "event=CORRECTION_DETECTED" "pattern=$pattern"
}
