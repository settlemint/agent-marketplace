#!/usr/bin/env bash
# Warn when running CI commands (test, lint, format, typecheck) in main thread
# These should run in background haiku agents via /crew:ci

set +e

INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty' 2>/dev/null)

# Only check Bash tool
if [[ $TOOL_NAME != "Bash" ]]; then
	exit 0
fi

# Check for CI-related commands
CI_PATTERNS=(
	"bun run test"
	"bun test"
	"npm run test"
	"npm test"
	"pnpm run test"
	"pnpm test"
	"yarn test"
	"bun run lint"
	"npm run lint"
	"pnpm run lint"
	"yarn lint"
	"bun run format"
	"npm run format"
	"pnpm run format"
	"yarn format"
	"bun run typecheck"
	"npm run typecheck"
	"pnpm run typecheck"
	"yarn typecheck"
	"bun run ci"
	"npm run ci"
	"pnpm run ci"
	"yarn ci"
	"tsc --noEmit"
	"eslint "
	"prettier --check"
	"vitest run"
	"vitest --run"
	"bunx vitest"
	"npx vitest"
	"pnpm exec vitest"
	"jest "
	"npx jest"
	"bunx jest"
	"biome check"
	"biome lint"
	"biome format"
	"bunx biome"
	"npx biome"
	"pnpm exec biome"
	"ultracite"
	"bunx ultracite"
	"npx ultracite"
	"pnpm exec ultracite"
)

for pattern in "${CI_PATTERNS[@]}"; do
	if [[ $COMMAND == *"$pattern"* ]]; then
		echo ""
		echo "SUGGESTION: Use /crew:ci instead of running CI commands in main thread"
		echo ""
		echo "  Current:  $COMMAND"
		echo "  Better:   /crew:ci test    (or lint, format, typecheck, all)"
		echo ""
		echo "Benefits:"
		echo "  - Runs in background haiku agent (cheaper, keeps main thread free)"
		echo "  - Reports only failures (less noise)"
		echo "  - Main thread can continue working"
		echo ""
		exit 0
	fi
done

exit 0
