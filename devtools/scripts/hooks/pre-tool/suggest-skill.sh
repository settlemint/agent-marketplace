#!/usr/bin/env bash
# Suggest relevant devtools skills based on command being run
# Non-blocking - provides tips without preventing the action

set +e

# --- Logging setup ---
SCRIPT_DIR=$(dirname "$0")
SCRIPT_NAME="suggest-skill"
# shellcheck source=../lib/common.sh
source "$SCRIPT_DIR/../lib/common.sh"
log_init

is_truthy() {
  case "${1:-}" in
    1 | true | yes | on) return 0 ;;
    *) return 1 ;;
  esac
}

QUIET="${CLAUDE_QUIET:-${DEVTOOLS_QUIET:-}}"
TOKEN_SAVER="${CLAUDE_TOKEN_SAVER:-${DEVTOOLS_TOKEN_SAVER:-}}"
TIPS_MODE="${DEVTOOLS_TIPS:-}"

# Allow opt-out for tips
if is_truthy "$QUIET" || [[ "$TIPS_MODE" =~ ^(0|off|false)$ ]]; then
  exit 0
fi

INPUT=$(cat)

# Single jq call to extract both fields (performance optimization)
read -r TOOL_NAME COMMAND < <(echo "$INPUT" | jq -r '[.tool_name // "", .tool_input.command // ""] | @tsv' 2>/dev/null)

# Extract file_path for Edit/Write tools
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // ""' 2>/dev/null)

# Suggestion messages based on command or file patterns
SUGGESTION=""
SKILL_KEY=""

# Session deduplication - use /tmp to avoid cluttering project
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
PROJECT_HASH=$(echo -n "$PROJECT_DIR" | md5 -q 2>/dev/null || echo -n "$PROJECT_DIR" | md5sum 2>/dev/null | cut -d' ' -f1)
SESSION_ID="${CLAUDE_SESSION_ID:-$$}"
MARKER_DIR="/tmp/claude-skill-tips/${PROJECT_HASH}"

# Helper to check if skill tip already shown
skill_shown() {
  local key="$1"
  [[ -f "$MARKER_DIR/${SESSION_ID}-${key}" ]]
}

# Helper to mark skill as shown
mark_skill_shown() {
  local key="$1"
  mkdir -p "$MARKER_DIR" 2>/dev/null
  touch "$MARKER_DIR/${SESSION_ID}-${key}" 2>/dev/null
}

# --- File-type based suggestions (Edit/Write tools) ---
if [[ $TOOL_NAME == "Edit" || $TOOL_NAME == "Write" ]] && [[ -n $FILE_PATH ]]; then
  # Frontend design for ALL tsx files (official Anthropic plugin)
  if [[ $FILE_PATH =~ \.(tsx)$ ]] && ! skill_shown "frontend-design"; then
    SUGGESTION="Tip: Load Skill({ skill: \"frontend-design:frontend-design\" }) for distinctive, production-grade UI aesthetics."
    SKILL_KEY="frontend-design"
  fi

  # Viem/blockchain code
  if [[ $FILE_PATH =~ (viem|web3|ethers|wagmi|blockchain|wallet|transaction) ]] && ! skill_shown "viem"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:viem\" }) for blockchain/wallet patterns."
    SKILL_KEY="viem"
  fi

  # React components
  if [[ $FILE_PATH =~ \.(tsx)$ ]] && [[ $FILE_PATH =~ (component|page|layout) ]] && ! skill_shown "react"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:react\" }) for React component patterns."
    SKILL_KEY="react"
  fi

  # Drizzle schemas
  if [[ $FILE_PATH =~ (schema|drizzle|migration) ]] && [[ $FILE_PATH =~ \.ts$ ]] && ! skill_shown "drizzle"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:drizzle\" }) for database schema patterns."
    SKILL_KEY="drizzle"
  fi

  # Test files
  if [[ $FILE_PATH =~ \.(test|spec)\.(ts|tsx)$ ]] && ! skill_shown "vitest"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:vitest\" }) for test patterns."
    SKILL_KEY="vitest"
  fi

  # Solidity contracts
  if [[ $FILE_PATH =~ \.sol$ ]] && ! skill_shown "solidity"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:solidity\" }) for smart contract patterns."
    SKILL_KEY="solidity"
  fi

  # Zod schemas
  if [[ $FILE_PATH =~ (schema|validation|zod) ]] && ! skill_shown "zod"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:zod\" }) for validation patterns."
    SKILL_KEY="zod"
  fi

  # API routes
  if [[ $FILE_PATH =~ (api|route|endpoint|orpc) ]] && ! skill_shown "api"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:api\" }) for API route patterns."
    SKILL_KEY="api"
  fi

  # Authentication (better-auth)
  if [[ $FILE_PATH =~ (auth|session|login|logout|password|credential) ]] && [[ $FILE_PATH =~ \.ts$ ]] && ! skill_shown "better-auth"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:better-auth\" }) for authentication patterns."
    SKILL_KEY="better-auth"
  fi

  # i18n/translations
  if [[ $FILE_PATH =~ (locales|translations|i18n|intl|lang) ]] && ! skill_shown "i18n"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:i18n\" }) for internationalization patterns."
    SKILL_KEY="i18n"
  fi

  # Motion/animations
  if [[ $FILE_PATH =~ (animation|motion|framer|transition) ]] && ! skill_shown "motion"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:motion\" }) for animation patterns."
    SKILL_KEY="motion"
  fi

  # Pino logging
  if [[ $FILE_PATH =~ (logger|logging|pino) ]] && ! skill_shown "pino"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:pino\" }) for structured logging patterns."
    SKILL_KEY="pino"
  fi

  # Radix UI primitives
  if [[ $FILE_PATH =~ (dialog|dropdown|popover|tooltip|modal|menu|select) ]] && [[ $FILE_PATH =~ \.(tsx)$ ]] && ! skill_shown "radix"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:radix\" }) for accessible UI primitive patterns."
    SKILL_KEY="radix"
  fi

  # Recharts/visualization
  if [[ $FILE_PATH =~ (chart|dashboard|graph|visualization|metric) ]] && [[ $FILE_PATH =~ \.(tsx)$ ]] && ! skill_shown "recharts"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:recharts\" }) for data visualization patterns."
    SKILL_KEY="recharts"
  fi

  # Restate durable workflows
  if [[ $FILE_PATH =~ (workflow|saga|durable|restate|handler) ]] && ! skill_shown "restate"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:restate\" }) for durable workflow patterns."
    SKILL_KEY="restate"
  fi

  # Shadcn UI components
  if [[ $FILE_PATH =~ (components/ui|shadcn|ui/) ]] && [[ $FILE_PATH =~ \.(tsx)$ ]] && ! skill_shown "shadcn"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:shadcn\" }) for shadcn/ui component patterns."
    SKILL_KEY="shadcn"
  fi

  # TanStack Start
  if [[ $FILE_PATH =~ (routes/|tanstack|router) ]] && [[ $FILE_PATH =~ \.(tsx?)$ ]] && ! skill_shown "tanstack-start"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:tanstack-start\" }) for TanStack routing patterns."
    SKILL_KEY="tanstack-start"
  fi

  # TheGraph subgraphs
  if [[ $FILE_PATH =~ (subgraph|graphql|indexer|mapping) ]] && ! skill_shown "thegraph"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:thegraph\" }) for subgraph/indexing patterns."
    SKILL_KEY="thegraph"
  fi

  # Turborepo
  if [[ $FILE_PATH =~ (turbo\.json|packages/|apps/) ]] && ! skill_shown "turbo"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:turbo\" }) for monorepo patterns."
    SKILL_KEY="turbo"
  fi

  # Design patterns (dashboard/admin UI)
  if [[ $FILE_PATH =~ (dashboard|admin|panel|settings) ]] && [[ $FILE_PATH =~ \.(tsx)$ ]] && ! skill_shown "design-principles"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:design-principles\" }) for dashboard/admin UI patterns."
    SKILL_KEY="design-principles"
  fi

  # Terraform/IaC
  if [[ $FILE_PATH =~ \.(tf|tfvars)$ ]] && ! skill_shown "terraform"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:terraform\" }) for IaC patterns (read-only)."
    SKILL_KEY="terraform"
  fi

  # Code simplifier for implementation files (official Anthropic plugin)
  # Suggest after implementing non-test .ts/.tsx files for post-implementation refinement
  if [[ $FILE_PATH =~ \.(ts|tsx)$ ]] && [[ ! $FILE_PATH =~ \.(test|spec)\.(ts|tsx)$ ]] && ! skill_shown "code-simplifier"; then
    SUGGESTION="Tip: After implementation, use Skill({ skill: \"code-simplifier:code-simplifier\" }) for code refinement."
    SKILL_KEY="code-simplifier"
  fi
fi

# --- Bash command based suggestions ---
if [[ $TOOL_NAME == "Bash" ]] && [[ -n $COMMAND ]]; then
  # Extract first line of command
  CMD_LINE="${COMMAND%%$'\n'*}"

  # Vitest - suggest vitest skill
  if [[ $CMD_LINE =~ vitest|bun\ run\ test|npm\ run\ test|pnpm\ run\ test ]] && ! skill_shown "vitest"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:vitest\" }) for test patterns and coverage."
    SKILL_KEY="vitest"
  fi

  # Playwright - suggest playwright skill
  if [[ $CMD_LINE =~ playwright|bun\ run\ e2e|npm\ run\ e2e ]] && ! skill_shown "playwright"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:playwright\" }) for E2E patterns."
    SKILL_KEY="playwright"
  fi

  # Drizzle migrations
  if [[ $CMD_LINE =~ drizzle|migration|db\ push|db\ pull ]] && ! skill_shown "drizzle"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:drizzle\" }) for schema and migrations."
    SKILL_KEY="drizzle"
  fi

  # Biome/ESLint
  if [[ $CMD_LINE =~ biome|eslint|lint ]] && ! skill_shown "lint"; then
    SUGGESTION="Tip: auto-lint runs post-edit; load Skill({ skill: \"devtools:troubleshooting\" }) for lint issues."
    SKILL_KEY="lint"
  fi

  # Helm
  if [[ $CMD_LINE =~ helm|kubectl ]] && ! skill_shown "helm"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:helm\" }) for chart and values.yaml conventions."
    SKILL_KEY="helm"
  fi

  # Next.js - suggest react-best-practices for performance patterns
  if [[ $CMD_LINE =~ next\ (build|dev|start)|npm\ run\ (build|dev)|bun\ run\ (build|dev) ]] && ! skill_shown "nextjs"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:react-best-practices\" }) for React/Next.js performance patterns."
    SKILL_KEY="nextjs"
  fi

  # React component creation - suggest react-best-practices
  if [[ $CMD_LINE =~ create.*component|generate.*component ]] && ! skill_shown "react"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:react-best-practices\" }) for optimal component patterns."
    SKILL_KEY="react"
  fi

  # Git operations
  if [[ $CMD_LINE =~ ^git\ (commit|rebase|merge|cherry-pick|stash) ]] && ! skill_shown "git"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:git\" }) for git workflow patterns."
    SKILL_KEY="git"
  fi

  # Turborepo commands
  if [[ $CMD_LINE =~ turbo\ (run|build|dev) ]] && ! skill_shown "turbo"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:turbo\" }) for monorepo task patterns."
    SKILL_KEY="turbo"
  fi

  # ast-grep for code refactoring
  if [[ $CMD_LINE =~ (sg|ast-grep) ]] && ! skill_shown "ast-grep"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:ast-grep\" }) for mass code refactoring patterns."
    SKILL_KEY="ast-grep"
  fi

  # Forge/Foundry for Solidity
  if [[ $CMD_LINE =~ (forge|foundry|anvil|cast) ]] && ! skill_shown "solidity"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:solidity\" }) for smart contract patterns."
    SKILL_KEY="solidity"
  fi

  # Graph CLI
  if [[ $CMD_LINE =~ graph\ (init|codegen|build|deploy) ]] && ! skill_shown "thegraph"; then
    SUGGESTION="Tip: Load Skill({ skill: \"devtools:thegraph\" }) for subgraph patterns."
    SKILL_KEY="thegraph"
  fi
fi

# Output suggestion if we have one
if [[ -n $SUGGESTION ]]; then
  log_info "event=SKILL_SUGGESTED" "skill_key=$SKILL_KEY" "suggestion=$SUGGESTION"
  # Mark skill as shown for this session
  if [[ -n $SKILL_KEY ]]; then
    mark_skill_shown "$SKILL_KEY"
  fi
  jq -n --arg msg "$SUGGESTION" '{
    "hookSpecificOutput": {
      "hookEventName": "PreToolUse",
      "message": $msg
    }
  }'
fi

exit 0
