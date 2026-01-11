#!/usr/bin/env bash
# Automatically wrap long-running commands to capture output in temp file
# This prevents context window pollution from verbose command output

set +e

INPUT=$(cat)

# Extract tool name and command
read -r TOOL_NAME COMMAND < <(echo "$INPUT" | jq -r '[.tool_name // "", .tool_input.command // ""] | @tsv' 2>/dev/null)

# Only process Bash tool
[[ $TOOL_NAME != "Bash" ]] && exit 0

# Skip if command is empty
[[ -z $COMMAND ]] && exit 0

# Skip if command already has output redirection to file/pipe (user knows what they're doing)
# Note: 2>&1 alone just merges stderr to stdout - it's NOT file redirection, so we still wrap
# Strip stderr-to-stdout merges before checking for real redirections
CMD_CHECK="${COMMAND//2>&1/}"
CMD_CHECK="${CMD_CHECK//>&1/}"

# Now check for actual file/pipe redirections: |, > file, >> file, &> file, 2> file, tee
if [[ $CMD_CHECK =~ \|[[:space:]] ]] ||
	[[ $CMD_CHECK =~ \>[[:space:]] ]] ||
	[[ $CMD_CHECK =~ \>\> ]] ||
	[[ $CMD_CHECK =~ 2\> ]] ||
	[[ $CMD_CHECK =~ \&\> ]] ||
	[[ $CMD_CHECK =~ tee[[:space:]] ]]; then
	exit 0
fi

# Skip simple/quick commands that don't need wrapping
# These are fast and produce minimal output
SKIP_PATTERNS=(
	"^ls[[:space:]]"
	"^cd[[:space:]]"
	"^pwd$"
	"^echo[[:space:]]"
	"^cat[[:space:]]"
	"^head[[:space:]]"
	"^tail[[:space:]]"
	"^grep[[:space:]]"
	"^find[[:space:]]"
	"^which[[:space:]]"
	"^whoami$"
	"^git[[:space:]]+(status|log|diff|branch|show|rev-parse)"
	"^git[[:space:]]+add"
	"^git[[:space:]]+checkout"
	"^git[[:space:]]+stash"
	"^git[[:space:]]+fetch"
	"^mkdir[[:space:]]"
	"^rm[[:space:]]"
	"^mv[[:space:]]"
	"^cp[[:space:]]"
	"^touch[[:space:]]"
	"^chmod[[:space:]]"
	"^export[[:space:]]"
	"^source[[:space:]]"
	"^\.[[:space:]]"
	"^read[[:space:]]"
	"^sleep[[:space:]]"
	"^kill[[:space:]]"
	"^pkill[[:space:]]"
	"^curl[[:space:]].*-s"
	"^wget[[:space:]].*-q"
	"^jq[[:space:]]"
	"^sed[[:space:]]"
	"^awk[[:space:]]"
	"^sort[[:space:]]"
	"^uniq[[:space:]]"
	"^wc[[:space:]]"
	"^date$"
	"^hostname$"
	"^uname"
	"^env$"
	"^printenv"
	"^shfmt[[:space:]]"
	"^shellcheck[[:space:]]"
)

for pattern in "${SKIP_PATTERNS[@]}"; do
	if [[ $COMMAND =~ $pattern ]]; then
		exit 0
	fi
done

# Patterns that indicate long-running or verbose commands
WRAP_PATTERNS=(
	# Dev servers (run indefinitely)
	"(npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?dev([[:space:]]|$)"
	"(npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?start([[:space:]]|$)"
	"(npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?serve([[:space:]]|$)"
	# Integration/E2E tests (slow, verbose)
	"(npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?test:(integration|e2e|smoke)"
	"(npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?test[[:space:]].*--run"
	"playwright[[:space:]]+test"
	"cypress[[:space:]]+run"
	# Build commands (can be verbose)
	"(npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?build([[:space:]]|$)"
	"turbo[[:space:]]+(run[[:space:]]+)?build"
	"turbo[[:space:]]+(run[[:space:]]+)?test"
	# Watch modes (run indefinitely)
	"--watch"
	"-w[[:space:]]"
	# Docker builds (verbose)
	"docker[[:space:]]+build"
	"docker[[:space:]]+compose[[:space:]]+up"
	"docker-compose[[:space:]]+up"
	# Package installs (can be verbose)
	"(npm|bun|pnpm|yarn)[[:space:]]+install([[:space:]]|$)"
	"(npm|bun|pnpm|yarn)[[:space:]]+i([[:space:]]|$)"
	"(npm|bun|pnpm|yarn)[[:space:]]+add[[:space:]]"
	# Turbo commands (generally verbose)
	"^turbo[[:space:]]"
	# Database operations
	"prisma[[:space:]]+(migrate|db[[:space:]]+push|generate)"
	"drizzle-kit[[:space:]]+(push|generate|migrate)"
	# Full test suites
	"(npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?test([[:space:]]|$)"
	"^vitest([[:space:]]|$)"
	"^jest([[:space:]]|$)"
	# Linting full projects
	"(npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?(lint|format|typecheck)([[:space:]]|$)"
	"^biome[[:space:]]+(check|lint|format)"
	"^eslint[[:space:]]"
	"^tsc([[:space:]]|$)"
	# CI/all commands
	"(npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?ci([[:space:]]|$)"
	# Reset/setup scripts
	"(npm|bun|pnpm|yarn)[[:space:]]+(run[[:space:]]+)?(reset|setup|dev:reset)"
)

SHOULD_WRAP=false
for pattern in "${WRAP_PATTERNS[@]}"; do
	if [[ $COMMAND =~ $pattern ]]; then
		SHOULD_WRAP=true
		break
	fi
done

# Exit if command doesn't match any wrap patterns
[[ $SHOULD_WRAP != true ]] && exit 0

# Generate descriptive temp file name
# Extract a meaningful slug from the command
SLUG=$(echo "$COMMAND" | head -c 50 | tr -cs '[:alnum:]' '-' | tr '[:upper:]' '[:lower:]' | sed 's/^-//;s/-$//')
[[ -z $SLUG ]] && SLUG="cmd"
TIMESTAMP=$(date +%H%M%S)
LOGFILE="/tmp/claude-${SLUG}-${TIMESTAMP}.log"

# Build the wrapped command
# Use script for better terminal handling, or simple tee if script unavailable
WRAPPED_CMD="{ ${COMMAND}; } 2>&1 | tee \"${LOGFILE}\"; echo \"\n📄 Full output saved: ${LOGFILE}\""

# Return modified tool input
jq -n \
	--arg cmd "$WRAPPED_CMD" \
	--arg msg "📝 Output will be saved to: ${LOGFILE}" \
	'{
    "hookResponse": {
      "decision": "ALLOW",
      "modifiedToolInput": {
        "command": $cmd
      }
    },
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "message": $msg
    }
  }'

exit 0
