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

# Check if Homebrew is available
if ! command -v brew &>/dev/null; then
  error "Homebrew not found. Please install Homebrew first."
  echo "  Visit: https://brew.sh"
  exit 1
fi

# Check if npm is available
if ! command -v npm &>/dev/null; then
  error "npm not found. Please install Node.js first."
  echo "  Visit: https://nodejs.org"
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

# Allowed marketplaces and plugins (anything else will be removed)
ALLOWED_MARKETPLACES=(
  "claude-plugins-official"
  "settlemint"
  "trailofbits"
)

ALLOWED_PLUGINS=(
  "frontend-design@claude-plugins-official"
  "typescript-lsp@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "flow@settlemint"
  "devtools@settlemint"
  # Trail of Bits security plugins (all except culture-index)
  "audit-context-building@trailofbits"
  "building-secure-contracts@trailofbits"
  "constant-time-analysis@trailofbits"
  "differential-review@trailofbits"
  "entry-point-analyzer@trailofbits"
  "property-based-testing@trailofbits"
  "sharp-edges@trailofbits"
  "spec-to-code-compliance@trailofbits"
  "static-analysis@trailofbits"
  "testing-handbook-skills@trailofbits"
  "variant-analysis@trailofbits"
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

# Function to install or update a Homebrew package
install_or_update_brew_tool() {
  local tool="$1"
  local formula="${2:-$tool}"

  if brew list "$formula" &>/dev/null; then
    info "Updating $tool..."
    brew upgrade "$formula" 2>/dev/null || success "$tool already up to date"
  else
    info "Installing $tool..."
    if brew install "$formula"; then
      success "$tool installed"
    else
      error "Failed to install $tool"
      return 1
    fi
  fi
}

# Function to install or update an npm global package
install_or_update_npm_package() {
  local package="$1"
  local cmd="${2:-$package}"

  if command -v "$cmd" &>/dev/null; then
    info "Updating $package..."
    if npm update -g "$package" &>/dev/null; then
      success "$package updated"
    else
      success "$package already up to date"
    fi
  else
    info "Installing $package..."
    if npm install -g "$package"; then
      success "$package installed"
    else
      error "Failed to install $package"
      return 1
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

echo "Step 0: Installing Dependencies"
echo "--------------------------------"
echo ""
echo "Homebrew packages:"
BREW_TOOLS=("jq" "gh" "shfmt" "shellcheck" "python@3")
for tool in "${BREW_TOOLS[@]}"; do
  install_or_update_brew_tool "$tool"
done
echo ""

echo "npm packages:"
install_or_update_npm_package "@ast-grep/cli" "sg"
install_or_update_npm_package "agent-browser" "agent-browser"
echo ""

echo "Python packages:"
info "Installing PyYAML..."
if pip3 install --user --quiet PyYAML 2>/dev/null || pip3 install --quiet PyYAML 2>/dev/null; then
  success "PyYAML installed"
else
  warn "PyYAML install failed (try: pip3 install --user PyYAML)"
fi
echo ""

echo "Step 1: Cleanup"
echo "---------------"
cleanup_plugins
cleanup_marketplaces
echo ""

echo "Step 2: Adding Marketplaces"
echo "----------------------------"
# Claude Official marketplace is often preinstalled - silently skip errors
if ! claude plugin marketplace add "anthropics/claude-plugins-official" &>/dev/null; then
  success "Claude Official marketplace already configured"
else
  success "Claude Official marketplace added"
fi
add_marketplace "settlemint/agent-marketplace" "SettleMint"
add_marketplace "trailofbits/skills" "Trail of Bits"
echo ""

echo "Step 3: Updating Marketplaces"
echo "-----------------------------"
update_marketplace "claude-plugins-official"
update_marketplace "settlemint"
update_marketplace "trailofbits"
echo ""

echo "Step 4: Updating Plugins"
echo "------------------------"
echo ""

echo "Official plugins (Anthropic):"
force_update_plugin "frontend-design@claude-plugins-official" "frontend-design (UI generation)"
force_update_plugin "typescript-lsp@claude-plugins-official" "typescript-lsp (TS/JS language server)"
force_update_plugin "code-simplifier@claude-plugins-official" "code-simplifier (code refinement)"
echo ""

echo "Core plugins (SettleMint):"
force_update_plugin "devtools@settlemint" "devtools (development skills)"
force_update_plugin "flow@settlemint" "flow (workflow automation)"
echo ""

echo "Security plugins (Trail of Bits):"
force_update_plugin "building-secure-contracts@trailofbits" "building-secure-contracts (smart contract security)"
force_update_plugin "entry-point-analyzer@trailofbits" "entry-point-analyzer (contract entry points)"
force_update_plugin "audit-context-building@trailofbits" "audit-context-building (code analysis)"
force_update_plugin "differential-review@trailofbits" "differential-review (security-focused diff)"
force_update_plugin "static-analysis@trailofbits" "static-analysis (CodeQL, Semgrep, SARIF)"
force_update_plugin "sharp-edges@trailofbits" "sharp-edges (dangerous APIs)"
force_update_plugin "testing-handbook-skills@trailofbits" "testing-handbook-skills (fuzz, sanitizers)"
force_update_plugin "property-based-testing@trailofbits" "property-based-testing (PBT guidance)"
force_update_plugin "constant-time-analysis@trailofbits" "constant-time-analysis (timing channels)"
force_update_plugin "spec-to-code-compliance@trailofbits" "spec-to-code-compliance (verification)"
force_update_plugin "variant-analysis@trailofbits" "variant-analysis (similar vulnerabilities)"
echo ""

# Summary
echo "================================"
if [[ ${#ERRORS[@]} -eq 0 ]]; then
  echo -e "${GREEN}Setup complete!${NC}"
  echo ""
  echo "Installed plugins:"
  echo "  Official (Anthropic):"
  echo "    • frontend-design - High-quality UI generation"
  echo "    • typescript-lsp - TypeScript/JavaScript LSP"
  echo "    • code-simplifier - Code refinement agent"
  echo "  Core (SettleMint):"
  echo "    • flow - Workflow orchestration and analysis"
  echo "    • devtools - Development skills (React, Solidity, etc.)"
  echo "  Security (Trail of Bits):"
  echo "    • building-secure-contracts - Smart contract security (Slither, Mythril)"
  echo "    • entry-point-analyzer - Attack surface identification"
  echo "    • static-analysis - CodeQL, Semgrep, SARIF toolkit"
  echo "    • + 13 more security skills"
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
