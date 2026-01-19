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

# Track execution mode (direct vs hook)
IS_DIRECT_EXECUTION=true

info() { echo -e "${ARROW} $1"; }
success() { echo -e "${CHECK} $1"; }
warn() { echo -e "${WARN} $1"; }
error() {
    echo -e "${CROSS} $1" >&2
    ERRORS+=("$1")
}

# Check if running as hook - skip on compact/resume events
if [[ -n "${CLAUDE_HOOK:-}" ]] && [[ ! -t 0 ]]; then
    IS_DIRECT_EXECUTION=false
    INPUT=$(cat)
    EVENT_TYPE=$(echo "$INPUT" | jq -r '.type // "unknown"' 2>/dev/null || echo "direct")

    if [[ $EVENT_TYPE == "compact" || $EVENT_TYPE == "resume" ]]; then
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
echo "  Plugin Setup"
echo "================================"
echo ""

# Allowed marketplaces and plugins (anything else will be removed)
ALLOWED_MARKETPLACES=(
    "claude-plugins-official"
    "settlemint"
)

ALLOWED_PLUGINS=(
    "plugin-dev@claude-plugins-official"
    "typescript-lsp@claude-plugins-official"
    "plan-mode@settlemint"
    "build-mode@settlemint"
    "git@settlemint"
)

# Function to check if item is in array
in_array() {
    local needle="$1"
    shift
    for item in "$@"; do
        [[ "$item" == "$needle" ]] && return 0
    done
    return 1
}

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
        if echo "$output" | grep -qi "error\|fail\|not found\|invalid"; then
            error "Failed to add $name marketplace: $output"
            return 1
        else
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
            return 0
        else
            success "$name checked"
            return 0
        fi
    fi
}

# Function to force update plugin (uninstall + reinstall)
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

# Function to clean up unwanted marketplaces
cleanup_marketplaces() {
    local known_file="$HOME/.claude/plugins/known_marketplaces.json"
    [[ -f "$known_file" ]] || return 0

    local marketplaces
    marketplaces=$(jq -r 'keys[]' "$known_file" 2>/dev/null) || return 0

    for marketplace in $marketplaces; do
        if ! in_array "$marketplace" "${ALLOWED_MARKETPLACES[@]}"; then
            info "Removing unauthorized marketplace: $marketplace"
            claude plugin marketplace remove "$marketplace" &>/dev/null || true
            success "Removed $marketplace"
        fi
    done
}

# Function to clean up unwanted plugins
cleanup_plugins() {
    local installed_file="$HOME/.claude/plugins/installed_plugins.json"
    [[ -f "$installed_file" ]] || return 0

    local plugins
    plugins=$(jq -r '.plugins | keys[]' "$installed_file" 2>/dev/null) || return 0

    for plugin in $plugins; do
        if ! in_array "$plugin" "${ALLOWED_PLUGINS[@]}"; then
            info "Removing unauthorized plugin: $plugin"
            claude plugin uninstall "$plugin" &>/dev/null || true
            success "Removed $plugin"
        fi
    done
}

echo "Step 1: Cleanup"
echo "---------------"
cleanup_plugins
cleanup_marketplaces
echo ""

echo "Step 2: Adding Marketplaces"
echo "----------------------------"
# Claude Official marketplace is often preinstalled
if ! claude plugin marketplace add "anthropics/claude-plugins-official" &>/dev/null; then
    success "Claude Official marketplace already configured"
else
    success "Claude Official marketplace added"
fi
add_marketplace "settlemint/agent-marketplace" "SettleMint"
echo ""

echo "Step 3: Updating Marketplaces"
echo "-----------------------------"
update_marketplace "claude-plugins-official"
update_marketplace "settlemint"
echo ""

echo "Step 4: Updating Plugins"
echo "------------------------"
echo ""

echo "Official plugins (Anthropic):"
force_update_plugin "plugin-dev@claude-plugins-official" "plugin-dev (plugin development)"
force_update_plugin "typescript-lsp@claude-plugins-official" "typescript-lsp (TS/JS language server)"
echo ""

echo "Core plugins (SettleMint):"
force_update_plugin "plan-mode@settlemint" "plan-mode (structured planning)"
force_update_plugin "build-mode@settlemint" "build-mode (TDD implementation)"
force_update_plugin "git@settlemint" "git (git workflow automation)"
echo ""

# Summary
echo "================================"
if [[ ${#ERRORS[@]} -eq 0 ]]; then
    echo -e "${GREEN}Setup complete!${NC}"
    echo ""
    echo "Installed plugins:"
    echo "  Official (Anthropic):"
    echo "    • plugin-dev - Plugin development tools"
    echo "    • typescript-lsp - TypeScript/JavaScript LSP"
    echo "  Core (SettleMint):"
    echo "    • plan-mode - 7-phase structured planning"
    echo "    • build-mode - TDD-driven implementation"
    echo "    • git - Git workflow automation"
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
