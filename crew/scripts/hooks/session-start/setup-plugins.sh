#!/usr/bin/env bash
#
# Setup and update plugins for Claude Code
# Can be run as:
#   1. SessionStart hook (stdin contains event JSON)
#   2. Direct execution via curl for initial setup
#
# All plugins are always force-updated (uninstall + reinstall) to ensure
# the latest version is installed, since Claude Code has no explicit
# "plugin update" command.
#
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Status symbols
CHECK="${GREEN}✓${NC}"
CROSS="${RED}✗${NC}"
ARROW="${BLUE}→${NC}"
WARN="${YELLOW}⚠${NC}"

# Track errors
ERRORS=()

info() { echo -e "${ARROW} $1"; }
success() { echo -e "${CHECK} $1"; }
warn() { echo -e "${WARN} $1"; }
error() {
	echo -e "${CROSS} $1" >&2
	ERRORS+=("$1")
}

# Check if running as hook - skip on compact/resume events
# Only attempt to read stdin if CLAUDE_HOOK environment variable is set
# This avoids consuming stdin when run via "curl ... | bash"
if [[ -n "${CLAUDE_HOOK:-}" ]] && [[ ! -t 0 ]]; then
	# Running as Claude hook with piped input
	INPUT=$(cat)
	EVENT_TYPE=$(echo "$INPUT" | jq -r '.type // "unknown"' 2>/dev/null || echo "direct")

	if [[ $EVENT_TYPE == "compact" || $EVENT_TYPE == "resume" ]]; then
		# Skip on compact/resume - only run on fresh startup or direct execution
		exit 0
	fi
fi

# Check if claude CLI is available
if ! command -v claude &>/dev/null; then
	error "Claude CLI not found. Please install Claude Code first."
	echo "  Visit: https://claude.ai/code"
	exit 1
fi

echo ""
echo "================================"
echo "  Claude Code Plugin Setup"
echo "================================"
echo ""

# Function to add marketplace
add_marketplace() {
	local repo="$1"
	local name="$2"

	info "Adding marketplace: $name"

	output=$(claude plugin marketplace add "$repo" 2>&1) || true

	if echo "$output" | grep -qi "already added\|already exists\|already registered\|already installed"; then
		success "$name marketplace already configured"
		return 0
	elif echo "$output" | grep -qi "added\|success"; then
		success "$name marketplace added"
		return 0
	elif [[ -z "$output" ]]; then
		success "$name marketplace configured"
		return 0
	else
		# Check if it's a real error
		if echo "$output" | grep -qi "error\|fail\|not found\|invalid"; then
			error "Failed to add $name marketplace: $output"
			return 1
		else
			# Unknown output, assume success
			success "$name marketplace configured"
			return 0
		fi
	fi
}

# Function to update marketplace
update_marketplace() {
	local name="$1"

	info "Updating marketplace: $name"

	output=$(claude plugin marketplace update "$name" 2>&1) || true

	if echo "$output" | grep -qi "up to date\|already up\|no updates"; then
		success "$name is up to date"
		return 0
	elif echo "$output" | grep -qi "updated\|success"; then
		success "$name updated"
		return 0
	elif [[ -z "$output" ]]; then
		success "$name checked"
		return 0
	else
		if echo "$output" | grep -qi "error\|fail\|not found"; then
			warn "Could not update $name: $output"
			return 0 # Non-fatal
		else
			success "$name checked"
			return 0
		fi
	fi
}

# Function to force update plugin (uninstall + reinstall)
# Use this for plugins that need to be at the latest version
force_update_plugin() {
	local plugin="$1"
	local display_name="${2:-$plugin}"

	info "Updating plugin: $display_name"

	# Uninstall first (ignore errors if not installed)
	claude plugin uninstall "$plugin" &>/dev/null || true

	# Clear plugin cache for this marketplace
	local marketplace="${plugin#*@}"
	if [[ -d "$HOME/.claude/plugins/cache/$marketplace" ]]; then
		rm -rf "$HOME/.claude/plugins/cache/$marketplace"
	fi

	# Install fresh
	output=$(claude plugin install "$plugin" 2>&1) || true

	if echo "$output" | grep -qi "installed\|enabled\|success"; then
		success "$display_name updated"
		return 0
	elif [[ -z "$output" ]]; then
		success "$display_name updated"
		return 0
	else
		if echo "$output" | grep -qi "error\|fail\|not found\|invalid"; then
			error "Failed to update $display_name: $output"
			return 1
		else
			success "$display_name updated"
			return 0
		fi
	fi
}

echo "Step 1: Adding Marketplaces"
echo "----------------------------"
add_marketplace "settlemint/agent-marketplace" "SettleMint"
add_marketplace "anthropics/claude-plugins-official" "Anthropic Official"
add_marketplace "sawyerhood/dev-browser" "Dev Browser"
echo ""

echo "Step 2: Updating Marketplaces"
echo "-----------------------------"
update_marketplace "settlemint"
update_marketplace "claude-plugins-official"
update_marketplace "dev-browser-marketplace"
echo ""

echo "Step 3: Updating Plugins"
echo "------------------------"
echo ""

echo "Core plugins (SettleMint):"
force_update_plugin "crew@settlemint" "crew (orchestration)"
force_update_plugin "devtools@settlemint" "devtools (development skills)"
echo ""

echo "Additional plugins:"
force_update_plugin "typescript-lsp@claude-plugins-official" "typescript-lsp"
force_update_plugin "frontend-design@claude-plugins-official" "frontend-design"
force_update_plugin "dev-browser@dev-browser-marketplace" "dev-browser"
echo ""

# Summary
echo "================================"
if [[ ${#ERRORS[@]} -eq 0 ]]; then
	echo -e "${GREEN}Setup complete!${NC}"
	echo ""
	echo "Installed plugins:"
	echo "  • crew@settlemint - Work orchestration (/design, /build, /check)"
	echo "  • devtools@settlemint - Development skills (React, API, etc.)"
	echo "  • typescript-lsp - TypeScript language server"
	echo "  • frontend-design - UI/UX assistance"
	echo "  • dev-browser - Browser automation"
	echo ""
	echo "Get started:"
	echo "  /crew:design <feature>  - Plan a feature"
	echo "  /crew:build             - Execute the plan"
	echo "  /crew:check             - Review code quality"
	echo "================================"
	exit 0
else
	echo -e "${RED}Setup completed with ${#ERRORS[@]} error(s):${NC}"
	for err in "${ERRORS[@]}"; do
		echo -e "  ${CROSS} $err"
	done
	echo "================================"
	exit 1
fi
