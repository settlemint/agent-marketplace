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

# ============================================
# Codex Sync Functions
# ============================================

# Check if Codex is available
check_codex_available() {
    local codex_home="${CODEX_HOME:-$HOME/.codex}"
    [[ -d "$codex_home" ]]
}

# Get the install path for a plugin from installed_plugins.json
get_plugin_install_path() {
    local plugin_id="$1"
    local installed_file="$HOME/.claude/plugins/installed_plugins.json"

    [[ -f "$installed_file" ]] || return 1

    jq -r --arg pid "$plugin_id" '
        def path_of(p):
            (p.installPath // p.install_path // p.path // (p.installPaths[0] // empty));
        if .plugins? then
            if (.plugins | type) == "object" then
                path_of((.plugins[$pid] | if type == "array" then .[0] else . end) // empty)
            elif (.plugins | type) == "array" then
                path_of((.plugins | map(select(.id == $pid or .pluginId == $pid or .name == $pid)) | .[0]) // empty)
            else
                empty
            end
        else
            empty
        end
    ' "$installed_file" 2>/dev/null
}

# Check if a word is in a space-separated string (Bash 3.2 compatible)
string_contains() {
    local needle="$1"
    local haystack="$2"
    [[ " $haystack " == *" $needle "* ]]
}

# Copy a directory to target (rsync if available, else cp fallback)
sync_directory() {
    local source_dir="$1"
    local target_dir="$2"

    if command -v rsync &>/dev/null; then
        rsync -a --delete "$source_dir/" "$target_dir/" 2>/dev/null
        return $?
    fi

    rm -rf "$target_dir"
    mkdir -p "$target_dir"
    cp -R "$source_dir/." "$target_dir/" 2>/dev/null
}

# Update the name field in SKILL.md when namespacing
update_skill_name() {
    local skill_file="$1"
    local new_name="$2"

    [[ -f "$skill_file" ]] || return 0

    if ! head -n 1 "$skill_file" | grep -q "^---$"; then
        return 0
    fi

    awk -v new_name="$new_name" '
        BEGIN { in_front = 0; done = 0 }
        NR == 1 && $0 == "---" { in_front = 1; print; next }
        in_front && $0 == "---" { in_front = 0; print; next }
        in_front && !done && $0 ~ /^name:[[:space:]]*/ {
            print "name: " new_name
            done = 1
            next
        }
        { print }
    ' "$skill_file" > "${skill_file}.tmp" && mv "${skill_file}.tmp" "$skill_file"
}

# Sync a single skill directory to Codex
sync_skill_to_codex() {
    local source_dir="$1"
    local target_name="$2"
    local codex_home="$3"
    local original_name="$4"
    local target_dir="$codex_home/skills/$target_name"

    mkdir -p "$target_dir"
    if ! sync_directory "$source_dir" "$target_dir"; then
        return 1
    fi

    if [[ "$target_name" != "$original_name" ]]; then
        update_skill_name "$target_dir/SKILL.md" "$target_name"
    fi
}

# Sync a single command file to Codex
sync_command_to_codex() {
    local source_file="$1"
    local target_name="$2"
    local codex_home="$3"
    local target_dir="$codex_home/commands"

    mkdir -p "$target_dir"
    cp "$source_file" "$target_dir/$target_name" 2>/dev/null
}

# Clean up orphaned skills and commands in Codex (Bash 3.2 compatible)
cleanup_codex_orphans() {
    local expected_skills="$1"
    local expected_commands="$2"
    local codex_home="$3"

    local codex_skills="$codex_home/skills"
    local codex_commands="$codex_home/commands"

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

    local codex_home="${CODEX_HOME:-$HOME/.codex}"
    local installed_file="$HOME/.claude/plugins/installed_plugins.json"

    if [[ ! -f "$installed_file" ]]; then
        warn "Claude installed_plugins.json not found, skipping Codex sync"
        return 0
    fi

    local temp_dir
    temp_dir=$(mktemp -d)
    local skills_manifest="$temp_dir/skills.tsv"
    local commands_manifest="$temp_dir/commands.tsv"
    local default_skill_map="$temp_dir/skill-defaults.tsv"
    local default_command_map="$temp_dir/command-defaults.tsv"

    local plugin_id
    local plugin_name
    local install_path
    local found_plugins=0

    for plugin_id in "${ALLOWED_PLUGINS[@]}"; do
        plugin_name="${plugin_id%@*}"
        install_path=$(get_plugin_install_path "$plugin_id")

        if [[ -z "$install_path" || ! -d "$install_path" ]]; then
            continue
        fi

        found_plugins=$((found_plugins + 1))

        # Sync skills from this plugin
        if [[ -d "$install_path/skills" ]]; then
            for skill_dir in "$install_path/skills"/*/; do
                [[ -d "$skill_dir" ]] || continue
                local skill_name
                skill_name=$(basename "$skill_dir")
                printf "%s\t%s\t%s\n" "$skill_name" "$plugin_name" "$skill_dir" >> "$skills_manifest"
            done
        fi

        # Sync commands from this plugin
        if [[ -d "$install_path/commands" ]]; then
            for cmd_file in "$install_path/commands"/*.md; do
                [[ -f "$cmd_file" ]] || continue
                local cmd_name
                cmd_name=$(basename "$cmd_file")
                printf "%s\t%s\t%s\n" "$cmd_name" "$plugin_name" "$cmd_file" >> "$commands_manifest"
            done
        fi
    done

    if [[ $found_plugins -eq 0 ]]; then
        warn "No installed plugin paths found, skipping Codex sync"
        rm -rf "$temp_dir"
        return 0
    fi

    if [[ ! -s "$skills_manifest" && ! -s "$commands_manifest" ]]; then
        warn "No plugin skills or commands found to sync, leaving Codex unchanged"
        rm -rf "$temp_dir"
        return 0
    fi

    mkdir -p "$codex_home/skills"
    mkdir -p "$codex_home/commands"

    local dup_skills=""
    local dup_commands=""

    if [[ -s "$skills_manifest" ]]; then
        dup_skills=$(cut -f1 "$skills_manifest" | sort | uniq -d | tr '\n' ' ')
    fi

    if [[ -s "$commands_manifest" ]]; then
        dup_commands=$(cut -f1 "$commands_manifest" | sort | uniq -d | tr '\n' ' ')
    fi

    # Determine defaults for duplicates (first plugin in order wins)
    : > "$default_skill_map"
    : > "$default_command_map"

    if [[ -n "$dup_skills" && -s "$skills_manifest" ]]; then
        while IFS=$'\t' read -r skill_name plugin_name source_dir; do
            if string_contains "$skill_name" "$dup_skills"; then
                if ! grep -Fq "^${skill_name}\t" "$default_skill_map"; then
                    printf "%s\t%s\n" "$skill_name" "$plugin_name" >> "$default_skill_map"
                fi
            fi
        done < "$skills_manifest"
    fi

    if [[ -n "$dup_commands" && -s "$commands_manifest" ]]; then
        while IFS=$'\t' read -r cmd_name plugin_name source_file; do
            if string_contains "$cmd_name" "$dup_commands"; then
                if ! grep -Fq "^${cmd_name}\t" "$default_command_map"; then
                    printf "%s\t%s\n" "$cmd_name" "$plugin_name" >> "$default_command_map"
                fi
            fi
        done < "$commands_manifest"
    fi

    if [[ -n "$dup_skills" ]]; then
        warn "Codex skill name collisions detected; namespacing duplicates as <plugin>__<skill>"
    fi

    if [[ -n "$dup_commands" ]]; then
        warn "Codex command name collisions detected; namespacing duplicates as <plugin>__<command>.md"
    fi

    local expected_skills=""
    local expected_commands=""
    local skill_count=0
    local cmd_count=0

    # Sync skills
    if [[ -s "$skills_manifest" ]]; then
        while IFS=$'\t' read -r skill_name plugin_name source_dir; do
            if string_contains "$skill_name" "$dup_skills"; then
                local namespaced_skill="${plugin_name}__${skill_name}"
                if sync_skill_to_codex "$source_dir" "$namespaced_skill" "$codex_home" "$skill_name"; then
                    expected_skills="$expected_skills $namespaced_skill"
                    skill_count=$((skill_count + 1))
                fi

                if grep -Fq "^${skill_name}\t${plugin_name}$" "$default_skill_map"; then
                    if sync_skill_to_codex "$source_dir" "$skill_name" "$codex_home" "$skill_name"; then
                        expected_skills="$expected_skills $skill_name"
                        skill_count=$((skill_count + 1))
                    fi
                fi
            else
                if sync_skill_to_codex "$source_dir" "$skill_name" "$codex_home" "$skill_name"; then
                    expected_skills="$expected_skills $skill_name"
                    skill_count=$((skill_count + 1))
                fi
            fi
        done < "$skills_manifest"
    fi

    # Sync commands
    if [[ -s "$commands_manifest" ]]; then
        while IFS=$'\t' read -r cmd_name plugin_name source_file; do
            if string_contains "$cmd_name" "$dup_commands"; then
                local namespaced_cmd="${plugin_name}__${cmd_name}"
                if sync_command_to_codex "$source_file" "$namespaced_cmd" "$codex_home"; then
                    expected_commands="$expected_commands $namespaced_cmd"
                    cmd_count=$((cmd_count + 1))
                fi

                if grep -Fq "^${cmd_name}\t${plugin_name}$" "$default_command_map"; then
                    if sync_command_to_codex "$source_file" "$cmd_name" "$codex_home"; then
                        expected_commands="$expected_commands $cmd_name"
                        cmd_count=$((cmd_count + 1))
                    fi
                fi
            else
                if sync_command_to_codex "$source_file" "$cmd_name" "$codex_home"; then
                    expected_commands="$expected_commands $cmd_name"
                    cmd_count=$((cmd_count + 1))
                fi
            fi
        done < "$commands_manifest"
    fi

    cleanup_codex_orphans "$expected_skills" "$expected_commands" "$codex_home"

    if [[ $skill_count -gt 0 || $cmd_count -gt 0 ]]; then
        success "Synced $skill_count skills and $cmd_count commands to Codex"
    else
        info "No skills or commands to sync"
    fi

    rm -rf "$temp_dir"
}

# ============================================
# Codex MCP Sync Functions
# ============================================

toml_string() {
    printf "%s" "$1" | jq -R '@json'
}

toml_table_key() {
    local key="$1"
    if [[ "$key" =~ ^[A-Za-z0-9_]+$ ]]; then
        echo "$key"
    else
        printf '"%s"' "$(printf "%s" "$key" | sed 's/"/\\"/g')"
    fi
}

append_mcp_table() {
    local name="$1"
    local command="$2"
    local args_json="$3"
    local url="$4"
    local cwd="$5"
    local bearer_token_env_var="$6"
    local startup_timeout_sec="$7"
    local tool_timeout_sec="$8"
    local enabled="$9"
    local enabled_tools_json="${10}"
    local disabled_tools_json="${11}"
    local env_json="${12}"
    local env_vars_json="${13}"
    local http_headers_json="${14}"
    local env_http_headers_json="${15}"
    local block_file="${16}"

    local table_key
    table_key=$(toml_table_key "$name")

    {
        echo "[mcp_servers.${table_key}]"
        if [[ -n "$command" ]]; then
            echo "command = $(toml_string "$command")"
        fi
        if [[ -n "$args_json" && "$args_json" != "[]" ]]; then
            echo "args = $args_json"
        fi
        if [[ -n "$url" && -z "$command" ]]; then
            echo "url = $(toml_string "$url")"
        fi
        if [[ -n "$cwd" ]]; then
            echo "cwd = $(toml_string "$cwd")"
        fi
        if [[ -n "$bearer_token_env_var" ]]; then
            echo "bearer_token_env_var = $(toml_string "$bearer_token_env_var")"
        fi
        if [[ -n "$startup_timeout_sec" ]]; then
            echo "startup_timeout_sec = $startup_timeout_sec"
        fi
        if [[ -n "$tool_timeout_sec" ]]; then
            echo "tool_timeout_sec = $tool_timeout_sec"
        fi
        if [[ -n "$enabled" ]]; then
            echo "enabled = $enabled"
        fi
        if [[ -n "$enabled_tools_json" && "$enabled_tools_json" != "[]" ]]; then
            echo "enabled_tools = $enabled_tools_json"
        fi
        if [[ -n "$disabled_tools_json" && "$disabled_tools_json" != "[]" ]]; then
            echo "disabled_tools = $disabled_tools_json"
        fi
        echo ""
    } >> "$block_file"

    if [[ -n "$env_json" && "$env_json" != "{}" ]]; then
        echo "[mcp_servers.${table_key}.env]" >> "$block_file"
        echo "$env_json" | jq -r 'to_entries[] | "\(.key) = \(.value|@json)"' >> "$block_file"
        echo "" >> "$block_file"
    fi

    if [[ -n "$env_vars_json" && "$env_vars_json" != "{}" ]]; then
        echo "[mcp_servers.${table_key}.env_vars]" >> "$block_file"
        echo "$env_vars_json" | jq -r 'to_entries[] | "\(.key) = \(.value|@json)"' >> "$block_file"
        echo "" >> "$block_file"
    fi

    if [[ -n "$http_headers_json" && "$http_headers_json" != "{}" ]]; then
        echo "[mcp_servers.${table_key}.http_headers]" >> "$block_file"
        echo "$http_headers_json" | jq -r 'to_entries[] | "\(.key) = \(.value|@json)"' >> "$block_file"
        echo "" >> "$block_file"
    fi

    if [[ -n "$env_http_headers_json" && "$env_http_headers_json" != "{}" ]]; then
        echo "[mcp_servers.${table_key}.env_http_headers]" >> "$block_file"
        echo "$env_http_headers_json" | jq -r 'to_entries[] | "\(.key) = \(.value|@json)"' >> "$block_file"
        echo "" >> "$block_file"
    fi
}

update_codex_config_block() {
    local config_file="$1"
    local block_file="$2"
    local begin_marker="# BEGIN: agent-marketplace MCP servers (managed by setup.sh)"
    local end_marker="# END: agent-marketplace MCP servers (managed by setup.sh)"

    if [[ -f "$config_file" ]]; then
        if grep -Fq "$begin_marker" "$config_file"; then
            local temp_file
            temp_file=$(mktemp)
            awk -v begin="$begin_marker" -v end="$end_marker" -v block="$block_file" '
                $0 == begin {
                    while ((getline line < block) > 0) print line
                    close(block)
                    in_block = 1
                    next
                }
                in_block && $0 == end { in_block = 0; next }
                !in_block { print }
            ' "$config_file" > "$temp_file"
            mv "$temp_file" "$config_file"
        else
            echo "" >> "$config_file"
            cat "$block_file" >> "$config_file"
        fi
    else
        mkdir -p "$(dirname "$config_file")"
        cat "$block_file" > "$config_file"
    fi
}

sync_codex_mcp_servers() {
    if ! check_codex_available; then
        info "Codex not installed (~/.codex not found), skipping MCP sync"
        return 0
    fi

    local codex_home="${CODEX_HOME:-$HOME/.codex}"
    local installed_file="$HOME/.claude/plugins/installed_plugins.json"

    if [[ ! -f "$installed_file" ]]; then
        warn "Claude installed_plugins.json not found, skipping Codex MCP sync"
        return 0
    fi

    local temp_dir
    temp_dir=$(mktemp -d)
    local mcp_manifest="$temp_dir/mcp.jsonl"
    local default_mcp_map="$temp_dir/mcp-defaults.tsv"
    local block_file="$temp_dir/mcp-block.toml"

    local plugin_id
    local plugin_name
    local install_path
    local mcp_file
    local found_plugins=0

    for plugin_id in "${ALLOWED_PLUGINS[@]}"; do
        plugin_name="${plugin_id%@*}"
        install_path=$(get_plugin_install_path "$plugin_id")

        if [[ -z "$install_path" || ! -d "$install_path" ]]; then
            continue
        fi

        found_plugins=$((found_plugins + 1))
        mcp_file="$install_path/.mcp.json"

        if [[ -f "$mcp_file" ]]; then
            jq -c --arg plugin "$plugin_name" '
                .mcpServers // {} | to_entries[] |
                {
                  name: .key,
                  plugin: $plugin,
                  command: (.value.command // ""),
                  args: (.value.args // []),
                  url: (.value.url // ""),
                  type: (.value.type // ""),
                  env: (.value.env // {}),
                  env_vars: (.value.env_vars // .value.envVars // {}),
                  cwd: (.value.cwd // ""),
                  bearer_token_env_var: (.value.bearer_token_env_var // .value.bearerTokenEnvVar // ""),
                  http_headers: (.value.http_headers // .value.httpHeaders // {}),
                  env_http_headers: (.value.env_http_headers // .value.envHttpHeaders // {}),
                  startup_timeout_sec: (.value.startup_timeout_sec // .value.startupTimeoutSec // empty),
                  tool_timeout_sec: (.value.tool_timeout_sec // .value.toolTimeoutSec // empty),
                  enabled: (.value.enabled // empty),
                  enabled_tools: (.value.enabled_tools // .value.enabledTools // []),
                  disabled_tools: (.value.disabled_tools // .value.disabledTools // [])
                }
            ' "$mcp_file" >> "$mcp_manifest"
        fi
    done

    if [[ $found_plugins -eq 0 ]]; then
        warn "No installed plugin paths found, skipping Codex MCP sync"
        rm -rf "$temp_dir"
        return 0
    fi

    if [[ ! -s "$mcp_manifest" ]]; then
        info "No MCP servers found in plugins, skipping Codex MCP sync"
        rm -rf "$temp_dir"
        return 0
    fi

    local dup_servers
    dup_servers=$(jq -r '.name' "$mcp_manifest" | sort | uniq -d | tr '\n' ' ')

    : > "$default_mcp_map"
    if [[ -n "$dup_servers" ]]; then
        while IFS= read -r line; do
            local name
            local plugin
            name=$(echo "$line" | jq -r '.name')
            plugin=$(echo "$line" | jq -r '.plugin')
            if string_contains "$name" "$dup_servers"; then
                if ! grep -Fq "^${name}\t" "$default_mcp_map"; then
                    printf "%s\t%s\n" "$name" "$plugin" >> "$default_mcp_map"
                fi
            fi
        done < "$mcp_manifest"
        warn "Codex MCP server name collisions detected; namespacing duplicates as <plugin>__<server>"
    fi

    {
        echo "# BEGIN: agent-marketplace MCP servers (managed by setup.sh)"
        echo "# Generated from installed plugin .mcp.json files."
        echo ""
    } > "$block_file"

    while IFS= read -r line; do
        local name
        local plugin
        local command
        local args_json
        local url
        local type
        local env_json
        local env_vars_json
        local cwd
        local bearer_token_env_var
        local http_headers_json
        local env_http_headers_json
        local startup_timeout_sec
        local tool_timeout_sec
        local enabled
        local enabled_tools_json
        local disabled_tools_json

        name=$(echo "$line" | jq -r '.name')
        plugin=$(echo "$line" | jq -r '.plugin')
        command=$(echo "$line" | jq -r '.command')
        args_json=$(echo "$line" | jq -c '.args')
        url=$(echo "$line" | jq -r '.url')
        type=$(echo "$line" | jq -r '.type')
        env_json=$(echo "$line" | jq -c '.env')
        env_vars_json=$(echo "$line" | jq -c '.env_vars')
        cwd=$(echo "$line" | jq -r '.cwd')
        bearer_token_env_var=$(echo "$line" | jq -r '.bearer_token_env_var')
        http_headers_json=$(echo "$line" | jq -c '.http_headers')
        env_http_headers_json=$(echo "$line" | jq -c '.env_http_headers')
        startup_timeout_sec=$(echo "$line" | jq -r '.startup_timeout_sec // empty')
        tool_timeout_sec=$(echo "$line" | jq -r '.tool_timeout_sec // empty')
        enabled=$(echo "$line" | jq -r '.enabled // empty')
        enabled_tools_json=$(echo "$line" | jq -c '.enabled_tools')
        disabled_tools_json=$(echo "$line" | jq -c '.disabled_tools')

        if [[ "$type" == "sse" && "$name" == "linear" && "$url" == *"mcp.linear.app/sse"* ]]; then
            url="${url%/sse}/mcp"
        fi

        if [[ -z "$command" && -z "$url" ]]; then
            warn "Skipping MCP server '$name' (missing command/url)"
            continue
        fi

        if string_contains "$name" "$dup_servers"; then
            local namespaced="${plugin}__${name}"
            append_mcp_table "$namespaced" "$command" "$args_json" "$url" "$cwd" "$bearer_token_env_var" \
                "$startup_timeout_sec" "$tool_timeout_sec" "$enabled" "$enabled_tools_json" "$disabled_tools_json" \
                "$env_json" "$env_vars_json" "$http_headers_json" "$env_http_headers_json" "$block_file"

            if grep -Fq "^${name}\t${plugin}$" "$default_mcp_map"; then
                append_mcp_table "$name" "$command" "$args_json" "$url" "$cwd" "$bearer_token_env_var" \
                    "$startup_timeout_sec" "$tool_timeout_sec" "$enabled" "$enabled_tools_json" "$disabled_tools_json" \
                    "$env_json" "$env_vars_json" "$http_headers_json" "$env_http_headers_json" "$block_file"
            fi
        else
            append_mcp_table "$name" "$command" "$args_json" "$url" "$cwd" "$bearer_token_env_var" \
                "$startup_timeout_sec" "$tool_timeout_sec" "$enabled" "$enabled_tools_json" "$disabled_tools_json" \
                "$env_json" "$env_vars_json" "$http_headers_json" "$env_http_headers_json" "$block_file"
        fi
    done < "$mcp_manifest"

    echo "# END: agent-marketplace MCP servers (managed by setup.sh)" >> "$block_file"

    update_codex_config_block "$codex_home/config.toml" "$block_file"
    success "Synced MCP servers to Codex config"

    rm -rf "$temp_dir"
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

# Step 5: Sync to Codex (only on direct execution, not on SessionStart hook)
if [[ "$IS_DIRECT_EXECUTION" == "true" ]]; then
    echo "Step 5: Syncing Codex"
    echo "---------------------"
    sync_all_to_codex
    sync_codex_mcp_servers
    echo ""
fi

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
