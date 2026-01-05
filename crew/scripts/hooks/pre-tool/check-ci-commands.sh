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
    cat <<'EOF'
{
  "decision": "block",
  "reason": "CI commands (test/lint/format/typecheck) should not run in main thread.\n\nUse one of these instead:\n  - Task tool with haiku model for test-runner agent\n  - /crew:ci command for interactive CI runs\n\nThis saves context and keeps the main thread responsive."
}
EOF
    exit 0
  fi
done

exit 0
