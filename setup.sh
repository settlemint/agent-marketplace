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
# Only attempt to read stdin if CLAUDE_HOOK environment variable is set
# This avoids consuming stdin when run via "curl ... | bash"
if [[ -n "${CLAUDE_HOOK:-}" ]] && [[ ! -t 0 ]]; then
  # Running as Claude hook with piped input
  IS_DIRECT_EXECUTION=false
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
  "typescript-lsp@claude-plugins-official"
  "frontend-design@claude-plugins-official"
  "code-simplifier@claude-plugins-official"
  "code-review@claude-plugins-official"
  "feature-dev@claude-plugins-official"
  "pr-review-toolkit@claude-plugins-official"
  "ralph-loop@claude-plugins-official"
  "superpowers@claude-plugins-official"
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

# ============================================
# Codex Sync Functions
# ============================================

# Check if Codex is available
check_codex_available() {
  [[ -d "$HOME/.codex" ]]
}

# Get the install path for a plugin from installed_plugins.json
get_plugin_install_path() {
  local plugin_id="$1"
  local installed_file="$HOME/.claude/plugins/installed_plugins.json"

  [[ -f "$installed_file" ]] || return 1

  # Get the install path (handle both array and object formats)
  jq -r --arg pid "$plugin_id" \
    '.plugins[$pid] | if type == "array" then .[0].installPath else .installPath end // empty' \
    "$installed_file" 2>/dev/null
}

# Sync a single skill directory to Codex
sync_skill_to_codex() {
  local source_dir="$1"
  local skill_name="$2"
  local target_dir="$HOME/.codex/skills/$skill_name"

  mkdir -p "$target_dir"
  rsync -a --delete "$source_dir/" "$target_dir/" 2>/dev/null
}

# Sync a single command file to Codex
sync_command_to_codex() {
  local source_file="$1"
  local target_dir="$HOME/.codex/commands"

  mkdir -p "$target_dir"
  cp "$source_file" "$target_dir/" 2>/dev/null
}

# Check if a word is in a space-separated string (Bash 3.2 compatible)
string_contains() {
  local needle="$1"
  local haystack="$2"
  [[ " $haystack " == *" $needle "* ]]
}

# Clean up orphaned skills and commands in Codex (Bash 3.2 compatible)
cleanup_codex_orphans_compat() {
  local expected_skills="$1"
  local expected_commands="$2"

  local codex_skills="$HOME/.codex/skills"
  local codex_commands="$HOME/.codex/commands"

  # Cleanup orphaned skills directories
  if [[ -d "$codex_skills" ]]; then
    for dir in "$codex_skills"/*/; do
      [[ -d "$dir" ]] || continue
      local dirname
      dirname=$(basename "$dir")

      # Skip .system directory (Codex system skills)
      [[ "$dirname" == ".system" ]] && continue

      if ! string_contains "$dirname" "$expected_skills"; then
        info "Removing orphaned Codex skill: $dirname"
        rm -rf "$dir"
      fi
    done
  fi

  # Cleanup orphaned command files
  if [[ -d "$codex_commands" ]]; then
    for file in "$codex_commands"/*; do
      [[ -f "$file" ]] || continue
      local filename
      filename=$(basename "$file")

      if ! string_contains "$filename" "$expected_commands"; then
        info "Removing orphaned Codex command: $filename"
        rm -f "$file"
      fi
    done
  fi
}

# Main function to sync all plugins to Codex
sync_all_to_codex() {
  if ! check_codex_available; then
    info "Codex not installed (~/.codex not found), skipping sync"
    return 0
  fi

  # Create base directories
  mkdir -p "$HOME/.codex/skills"
  mkdir -p "$HOME/.codex/commands"

  # Build lists of expected skills and commands (Bash 3.2 compatible)
  local expected_skills=""
  local expected_commands=""
  local skill_count=0
  local cmd_count=0

  # First pass: sync all skills and commands, building expected lists
  for plugin_id in "${ALLOWED_PLUGINS[@]}"; do
    local install_path
    install_path=$(get_plugin_install_path "$plugin_id")

    if [[ -z "$install_path" || ! -d "$install_path" ]]; then
      continue
    fi

    # Sync skills from this plugin
    if [[ -d "$install_path/skills" ]]; then
      for skill_dir in "$install_path/skills"/*/; do
        [[ -d "$skill_dir" ]] || continue
        local skill_name
        skill_name=$(basename "$skill_dir")
        expected_skills="$expected_skills $skill_name"
        if sync_skill_to_codex "$skill_dir" "$skill_name"; then
          ((skill_count++)) || true
        fi
      done
    fi

    # Sync commands from this plugin
    if [[ -d "$install_path/commands" ]]; then
      for cmd_file in "$install_path/commands"/*.md; do
        [[ -f "$cmd_file" ]] || continue
        local cmd_name
        cmd_name=$(basename "$cmd_file")
        expected_commands="$expected_commands $cmd_name"
        if sync_command_to_codex "$cmd_file"; then
          ((cmd_count++)) || true
        fi
      done
    fi
  done

  # Second pass: cleanup orphaned items
  cleanup_codex_orphans_compat "$expected_skills" "$expected_commands"

  if [[ $skill_count -gt 0 || $cmd_count -gt 0 ]]; then
    success "Synced $skill_count skills and $cmd_count commands to Codex"
  else
    info "No skills or commands to sync"
  fi
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
force_update_plugin "code-review@claude-plugins-official" "code-review (code review)"
force_update_plugin "feature-dev@claude-plugins-official" "feature-dev (feature development)"
force_update_plugin "pr-review-toolkit@claude-plugins-official" "pr-review-toolkit (pull request review toolkit)"
force_update_plugin "ralph-loop@claude-plugins-official" "ralph-loop (Ralph Loops)"
force_update_plugin "superpowers@claude-plugins-official" "superpowers (enhanced coding abilities)"
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

# Step 5: Sync to Codex (only on direct execution, not on SessionStart hook)
if [[ "$IS_DIRECT_EXECUTION" == "true" ]]; then
  echo "Step 5: Sync to Codex"
  echo "---------------------"
  sync_all_to_codex
  echo ""
fi

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
