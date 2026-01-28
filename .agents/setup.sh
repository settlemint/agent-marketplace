#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/.."
CONFIG_FILE="$SCRIPT_DIR/setup.json"
TEMPLATES_DIR="$SCRIPT_DIR/templates"
SKILLS_LOCAL_DIR="$SCRIPT_DIR/skills-local"
RUN_CODEX_MCP=1
RUN_CODEX_INSTALL=1
RUN_POST_INSTALL=1
RUN_SKILLS=1
DOCS_ONLY=0

for arg in "$@"; do
    case "$arg" in
        --skip-postinstall)
            RUN_POST_INSTALL=0
            ;;
        --skip-skills)
            RUN_SKILLS=0
            ;;
        --docs-only)
            RUN_POST_INSTALL=0
            RUN_SKILLS=0
            DOCS_ONLY=1
            ;;
        --lite)
            RUN_POST_INSTALL=0
            ;;
        --skip-codex-mcp)
            RUN_CODEX_MCP=0
            ;;
        --skip-codex-install)
            RUN_CODEX_INSTALL=0
            ;;
    esac
done

# Check dependencies
if ! command -v jq &>/dev/null; then
    echo "Error: jq is required but not installed"
    exit 1
fi

if [[ ! -f "$CONFIG_FILE" ]]; then
    echo "Error: $CONFIG_FILE not found"
    exit 1
fi

# Install and configure Codex CLI
install_codex() {
    if [[ $RUN_CODEX_INSTALL -ne 1 ]]; then
        return
    fi

    echo "Configuring Codex CLI..."

    npx -y codex-1up install \
        --yes \
        --profile yolo \
        --profiles-scope all \
        --profile-mode overwrite \
        --file-opener cursor \
        --credentials-store auto \
        --alt-screen auto \
        --web-search live \
        --experimental steering,collaboration-modes \
        --codex-cli yes \
        --tools all \
        --skills skip \
        --no-vscode \
        --sound skip

    echo "Codex CLI configured successfully"
}

# Compose markdown files from templates
# $1: agent template directory (e.g., templates/claude or templates/codex)
# $2: template file name (e.g., CLAUDE.md or AGENTS.md)
# $3: output file path
compose_md_file() {
    local agent_template_dir="$1"
    local template_file="$agent_template_dir/$2"
    local output_file="$3"

    if [[ ! -f "$template_file" ]]; then
        return
    fi

    # Read all template content files from the agent-specific directory
    local task_classification_content=""
    local hard_requirements_content=""
    local anti_patterns_content=""
    local workflows_content=""
    local routing_content=""

    if [[ -f "$agent_template_dir/task-classification.md" ]]; then
        task_classification_content=$(cat "$agent_template_dir/task-classification.md")
    fi

    if [[ -f "$agent_template_dir/hard-requirements.md" ]]; then
        hard_requirements_content=$(cat "$agent_template_dir/hard-requirements.md")
    fi

    if [[ -f "$agent_template_dir/anti-patterns.md" ]]; then
        anti_patterns_content=$(cat "$agent_template_dir/anti-patterns.md")
    fi

    if [[ -f "$agent_template_dir/workflows.md" ]]; then
        workflows_content=$(cat "$agent_template_dir/workflows.md")
    fi

    if [[ -f "$agent_template_dir/skill-routing-table.md" ]]; then
        routing_content=$(cat "$agent_template_dir/skill-routing-table.md")
    fi

    # Read template and replace placeholders
    local content
    content=$(cat "$template_file")

    # Replace all placeholders
    content="${content//\{\{TASK_CLASSIFICATION\}\}/$task_classification_content}"
    content="${content//\{\{HARD_REQUIREMENTS\}\}/$hard_requirements_content}"
    content="${content//\{\{ANTI_PATTERNS\}\}/$anti_patterns_content}"
    content="${content//\{\{WORKFLOWS\}\}/$workflows_content}"
    content="${content//\{\{SKILL_ROUTING_TABLE\}\}/$routing_content}"

    echo "$content" > "$output_file"
}

# Copy templates to project
copy_templates() {
    if [[ ! -d "$TEMPLATES_DIR" ]]; then
        return
    fi

    echo "Setting up project files..."

    local claude_templates="$TEMPLATES_DIR/claude"
    local codex_templates="$TEMPLATES_DIR/codex"

    # Copy Claude-specific settings.json and session-start script
    if [[ -d "$claude_templates/.claude" ]]; then
        mkdir -p "$PROJECT_ROOT/.claude/scripts/web/session-start"
        cp "$claude_templates/.claude/settings.json" "$PROJECT_ROOT/.claude/settings.json"
        cp "$claude_templates/.claude/scripts/web/session-start/setup.sh" "$PROJECT_ROOT/.claude/scripts/web/session-start/setup.sh"
        chmod +x "$PROJECT_ROOT/.claude/scripts/web/session-start/setup.sh"

        # Copy validation scripts if they exist
        if [[ -d "$claude_templates/.claude/scripts/validation" ]]; then
            mkdir -p "$PROJECT_ROOT/.claude/scripts/validation"
            cp "$claude_templates/.claude/scripts/validation/"*.sh "$PROJECT_ROOT/.claude/scripts/validation/" 2>/dev/null || true
            chmod +x "$PROJECT_ROOT/.claude/scripts/validation/"*.sh 2>/dev/null || true
        fi

        # Copy commands if they exist
        if [[ -d "$claude_templates/.claude/commands" ]]; then
            mkdir -p "$PROJECT_ROOT/.claude/commands"
            cp "$claude_templates/.claude/commands/"*.md "$PROJECT_ROOT/.claude/commands/" 2>/dev/null || true
            echo "  Installed Claude commands"
        fi

        # Copy agents if they exist
        if [[ -d "$claude_templates/.claude/agents" ]]; then
            mkdir -p "$PROJECT_ROOT/.claude/agents"
            cp "$claude_templates/.claude/agents/"*.md "$PROJECT_ROOT/.claude/agents/" 2>/dev/null || true
            echo "  Installed Claude agents"
        fi

        # Copy session scripts if they exist
        if [[ -d "$claude_templates/.claude/scripts/session" ]]; then
            mkdir -p "$PROJECT_ROOT/.claude/scripts/session"
            cp "$claude_templates/.claude/scripts/session/"*.sh "$PROJECT_ROOT/.claude/scripts/session/" 2>/dev/null || true
            chmod +x "$PROJECT_ROOT/.claude/scripts/session/"*.sh 2>/dev/null || true
            echo "  Installed session scripts"
        fi
    fi

    # Compose CLAUDE.md from claude/ templates
    if [[ -d "$claude_templates" ]] && [[ -f "$claude_templates/CLAUDE.md" ]]; then
        compose_md_file "$claude_templates" "CLAUDE.md" "$PROJECT_ROOT/CLAUDE.md"
        echo "  Generated CLAUDE.md from templates/claude/"
    fi

    # Compose AGENTS.md from codex/ templates
    if [[ -d "$codex_templates" ]] && [[ -f "$codex_templates/AGENTS.md" ]]; then
        compose_md_file "$codex_templates" "AGENTS.md" "$PROJECT_ROOT/AGENTS.md"
        echo "  Generated AGENTS.md from templates/codex/"
    fi
}

# Install local skills (from skills-local directory)
install_local_skills() {
    if [[ ! -d "$SKILLS_LOCAL_DIR" ]]; then
        return
    fi

    local skill_dirs
    skill_dirs=$(find "$SKILLS_LOCAL_DIR" -mindepth 1 -maxdepth 1 -type d 2>/dev/null)

    if [[ -z "$skill_dirs" ]]; then
        return
    fi

    echo "Installing local skills..."

    # Get configured agents
    local agents
    agents=$(jq -r '.agents // ["claude-code"] | .[]' "$CONFIG_FILE" 2>/dev/null)

    for skill_dir in $skill_dirs; do
        local skill_name
        skill_name=$(basename "$skill_dir")

        for agent in $agents; do
            case "$agent" in
                claude-code|claude)
                    # Symlink to .claude/skills/
                    mkdir -p "$PROJECT_ROOT/.claude/skills"
                    ln -sfn "../../.agents/skills-local/$skill_name" "$PROJECT_ROOT/.claude/skills/$skill_name"
                    ;;
                codex)
                    # Symlink to .codex/skills/
                    mkdir -p "$PROJECT_ROOT/.codex/skills"
                    ln -sfn "../../.agents/skills-local/$skill_name" "$PROJECT_ROOT/.codex/skills/$skill_name"
                    ;;
            esac
        done

        echo "  Installed $skill_name"
    done

    echo "Local skills installed successfully"
}

# Generate .mcp.json from config
generate_mcp_json() {
    local mcp_servers
    mcp_servers=$(jq -r '.mcpServers // empty' "$CONFIG_FILE")

    if [[ -z "$mcp_servers" || "$mcp_servers" == "null" ]]; then
        return
    fi

    echo "Generating .mcp.json..."

    local mcp_json
    mcp_json=$(jq -n --argjson servers "$mcp_servers" '{ mcpServers: $servers }')

    echo "$mcp_json" > "$PROJECT_ROOT/.mcp.json"
    echo "Generated .mcp.json with MCP server configurations"
}

# Configure Codex MCP servers in global config
configure_codex_mcp() {
    if [[ $RUN_CODEX_MCP -ne 1 ]]; then
        return
    fi

    local mcp_servers
    mcp_servers=$(jq -r '.mcpServers // empty' "$CONFIG_FILE")

    if [[ -z "$mcp_servers" || "$mcp_servers" == "null" ]]; then
        return
    fi

    local codex_home="${CODEX_HOME:-$HOME/.codex}"
    if [[ -z "$codex_home" ]]; then
        codex_home="$PROJECT_ROOT/.codex"
    fi

    local config_file="$codex_home/config.toml"
    mkdir -p "$codex_home"

    local tmp_file
    tmp_file=$(mktemp)

    if [[ -f "$config_file" ]]; then
        cp "$config_file" "$tmp_file"
    else
        : >"$tmp_file"
    fi

    local names
    names=$(echo "$mcp_servers" | jq -r 'keys[]')

    for name in $names; do
        local tmp_out
        tmp_out=$(mktemp)
        awk -v target="mcp_servers.${name}" '
        function is_header(line) { return line ~ /^\[[^]]+\]/ }
        {
          if ($0 == "[" target "]") { skip=1; next }
          if (skip && is_header($0)) { skip=0 }
          if (!skip) print $0
        }
      ' "$tmp_file" >"$tmp_out"
        mv "$tmp_out" "$tmp_file"
    done

    printf '\n' >>"$tmp_file"

    for name in $names; do
        local server_json url command args
        server_json=$(echo "$mcp_servers" | jq -c --arg name "$name" '.[$name]')
        url=$(echo "$server_json" | jq -r '.url // empty')
        command=$(echo "$server_json" | jq -r '.command // empty')
        args=$(echo "$server_json" | jq -c '.args // empty')

        {
            printf '[mcp_servers.%s]\n' "$name"
            if [[ -n "$url" ]]; then
                printf 'url = "%s"\n' "$url"
            fi
            if [[ -n "$command" ]]; then
                printf 'command = "%s"\n' "$command"
            fi
            if [[ -n "$args" && "$args" != "null" && "$args" != "[]" ]]; then
                printf 'args = %s\n' "$args"
            fi
            printf '\n'
        } >>"$tmp_file"
    done

    mv "$tmp_file" "$config_file"
    echo "Updated Codex MCP config at $config_file"
}

# Install skills from config (parallel)
install_skills() {
    if [[ $RUN_SKILLS -ne 1 ]]; then
        return
    fi

    local agents
    agents=$(jq -r '.agents | map("-a " + .) | join(" ")' "$CONFIG_FILE")

    local repo_count
    repo_count=$(jq -r '.skills | length' "$CONFIG_FILE")

    if [[ $repo_count -eq 0 ]]; then
        return
    fi

    local tmp_dir
    tmp_dir=$(mktemp -d)

    cleanup_tmp() {
        rm -rf "$tmp_dir"
    }
    trap cleanup_tmp RETURN EXIT INT TERM

    local pids=()
    local repos=()
    local skill_args=()

    for ((i = 0; i < repo_count; i++)); do
        local repo
        repo=$(jq -r ".skills[$i].repo" "$CONFIG_FILE")

        if [[ ! "$repo" =~ ^[a-zA-Z0-9._-]+/[a-zA-Z0-9._-]+$ ]]; then
            echo "Error: Invalid repo format: $repo"
            exit 1
        fi
        repos+=("$repo")

        local skills=()
        while IFS= read -r skill; do
            skills+=("$skill")
        done < <(jq -r ".skills[$i].skills[]" "$CONFIG_FILE")
        local skill_flags=""
        for skill in "${skills[@]}"; do
            if [[ ! "$skill" =~ ^[a-zA-Z0-9._-]+$ ]]; then
                echo "Error: Invalid skill name: $skill"
                exit 1
            fi
            skill_flags+=" --skill $skill"
        done
        skill_args+=("$skill_flags")

        echo "Installing skills from $repo..."

        (
            set +e
            npx -y skills@latest add "$repo" -y $agents ${skill_args[$i]} > "$tmp_dir/$i.out" 2>&1
            echo $? > "$tmp_dir/$i.exit"
        ) &
        pids+=("$!")
    done

    local failed=0
    for ((i = 0; i < repo_count; i++)); do
        wait "${pids[$i]}" || true
        local exit_code
        exit_code=$(cat "$tmp_dir/$i.exit" 2>/dev/null || echo "1")

        if [[ $exit_code -ne 0 ]]; then
            echo "Error installing skills from ${repos[$i]}:"
            cat "$tmp_dir/$i.out" 2>/dev/null || echo "No output captured"
            failed=1
        fi
    done

    if [[ $failed -ne 0 ]]; then
        exit 1
    fi

    echo "All skills installed successfully"
}

# Run post-install commands from config
run_post_install() {
    if [[ $RUN_POST_INSTALL -ne 1 ]]; then
        return
    fi

    local cmd_count
    local post_type
    post_type=$(jq -r '.postInstall | type' "$CONFIG_FILE")
    local os_key=""
    local cmds=()
    local os_cmds=()

    case "$(uname -s)" in
        Darwin) os_key="darwin" ;;
        Linux) os_key="linux" ;;
        MINGW*|MSYS*|CYGWIN*) os_key="windows" ;;
    esac

    if [[ "$post_type" == "array" ]]; then
        while IFS= read -r line; do
            cmds+=("$line")
        done < <(jq -r '.postInstall[]' "$CONFIG_FILE")
    elif [[ "$post_type" == "object" ]]; then
        while IFS= read -r line; do
            cmds+=("$line")
        done < <(jq -r '.postInstall.common // [] | .[]' "$CONFIG_FILE")
        if [[ -n "$os_key" ]]; then
            while IFS= read -r line; do
                os_cmds+=("$line")
            done < <(jq -r --arg os "$os_key" '.postInstall[$os] // [] | .[]' "$CONFIG_FILE")
            cmds+=("${os_cmds[@]}")
        fi
    else
        return
    fi

    cmd_count=${#cmds[@]}

    if [[ $cmd_count -eq 0 ]]; then
        return
    fi

    echo "Running post-install commands..."

    for ((i = 0; i < cmd_count; i++)); do
        local cmd="${cmds[$i]}"

        echo "  Running: $cmd"

        local output
        local exit_code
        output=$(eval "$cmd" 2>&1) && exit_code=$? || exit_code=$?

        if [[ $exit_code -ne 0 ]]; then
            echo "Error running post-install command: $cmd"
            echo "$output"
            exit 1
        fi
    done

    echo "Post-install commands completed"
}

if [[ $DOCS_ONLY -eq 1 ]]; then
    generate_mcp_json
    copy_templates
    install_local_skills
    exit 0
fi

install_codex
copy_templates
install_local_skills
generate_mcp_json
configure_codex_mcp
install_skills
run_post_install || echo "Note: Some post-install commands failed (this is expected in web environments)"
