#!/usr/bin/env bash
# Validate file edit actions with TDD enforcement
# Runs on: PreToolUse (Edit|MultiEdit|Write)

# Hooks must never fail
set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="validate-action"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

# Read tool input from stdin
TOOL_INPUT=$(cat)

# Extract file path
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.tool_input.file_path // .tool_input.path // ""' 2>/dev/null || echo "")

# Skip if no file path
if [[ -z "$FILE_PATH" ]]; then
	exit 0
fi

# Check for protected paths - log and warn user (security-critical)
case "$FILE_PATH" in
*.env | *.env.* | *credentials* | *secret* | *.pem | *.key)
	log_warn "event=SENSITIVE_FILE_EDIT" "file=$FILE_PATH"
	echo '{"feedback": "Warning: Editing sensitive file. Ensure no secrets are committed."}' >&2
	;;
esac

# TDD Validation: Check if editing implementation without test
# Only check for TypeScript/JavaScript source files
case "$FILE_PATH" in
*.ts | *.tsx | *.js | *.jsx)
	# Skip if this is already a test file
	case "$FILE_PATH" in
	*.test.* | *.spec.* | *__tests__* | *__mocks__*)
		exit 0
		;;
	esac

	# Skip if in node_modules or build output
	case "$FILE_PATH" in
	*node_modules* | *dist/* | *build/* | *.next/*)
		exit 0
		;;
	esac

	# Derive potential test file paths
	DIR=$(dirname "$FILE_PATH")
	BASENAME=$(basename "$FILE_PATH")
	EXT="${BASENAME##*.}"
	NAME="${BASENAME%.*}"

	# Check for co-located test file
	TEST_FILE_1="${DIR}/${NAME}.test.${EXT}"
	TEST_FILE_2="${DIR}/${NAME}.spec.${EXT}"
	TEST_FILE_3="${DIR}/__tests__/${NAME}.test.${EXT}"

	if [[ ! -f "$TEST_FILE_1" ]] && [[ ! -f "$TEST_FILE_2" ]] && [[ ! -f "$TEST_FILE_3" ]]; then
		# Log only - don't show TDD reminders on every edit (too noisy)
		log_info "event=TDD_REMINDER" "file=$FILE_PATH" "missing_test=$TEST_FILE_1"
	fi
	;;
esac

exit 0
