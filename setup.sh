#!/bin/bash
set -e

REPO="settlemint/agent-marketplace"
BRANCH="main"
ARCHIVE_URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)"
TARGET_AGENTS_DIR="$TARGET_DIR/.agents"
SOURCE_AGENTS_DIR="$SCRIPT_DIR/.agents"
FORCE_UPDATE=0

# Parse args, separating --update from pass-through args
ARGS=()
for arg in "$@"; do
    case "$arg" in
        --update)
            FORCE_UPDATE=1
            ;;
        *)
            ARGS+=("$arg")
            ;;
    esac
done

ensure_jq() {
    if command -v jq &>/dev/null; then
        return
    fi

    echo "jq not found. Attempting to install..."

    if command -v brew &>/dev/null; then
        brew install jq
    elif command -v apt-get &>/dev/null; then
        if [[ "$(id -u)" -eq 0 ]]; then
            apt-get update -qq && apt-get install -y jq
        elif command -v sudo &>/dev/null; then
            sudo -n apt-get update -qq && sudo -n apt-get install -y jq
        else
            echo "Error: jq is required. Install jq or run this script with sudo."
            exit 1
        fi
    elif command -v dnf &>/dev/null; then
        if [[ "$(id -u)" -eq 0 ]]; then
            dnf install -y jq
        elif command -v sudo &>/dev/null; then
            sudo -n dnf install -y jq
        else
            echo "Error: jq is required. Install jq or run this script with sudo."
            exit 1
        fi
    elif command -v yum &>/dev/null; then
        if [[ "$(id -u)" -eq 0 ]]; then
            yum install -y jq
        elif command -v sudo &>/dev/null; then
            sudo -n yum install -y jq
        else
            echo "Error: jq is required. Install jq or run this script with sudo."
            exit 1
        fi
    else
        echo "Error: jq is required but no supported package manager was found."
        exit 1
    fi

    if ! command -v jq &>/dev/null; then
        echo "Error: jq install failed. Please install jq manually."
        exit 1
    fi
}

agents_ready() {
    [[ -f "$TARGET_AGENTS_DIR/setup.sh" ]] \
        && [[ -f "$TARGET_AGENTS_DIR/setup.json" ]] \
        && [[ -d "$TARGET_AGENTS_DIR/templates" ]] \
        && [[ -d "$TARGET_AGENTS_DIR/skills" ]]
}

download_agents() {
    echo "Downloading .agents from $REPO..."

    if ! command -v tar &>/dev/null; then
        echo "Error: tar is required to download .agents."
        exit 1
    fi

    local tmp_dir repo_name repo_dir
    tmp_dir=$(mktemp -d)
    repo_name="${REPO##*/}"

    curl -sL "$ARCHIVE_URL" | tar -xz -C "$tmp_dir"

    repo_dir="$tmp_dir/${repo_name}-${BRANCH}"
    if [[ ! -d "$repo_dir/.agents" ]]; then
        echo "Error: .agents not found in downloaded archive."
        exit 1
    fi

    mkdir -p "$TARGET_AGENTS_DIR"
    cp -R "$repo_dir/.agents"/. "$TARGET_AGENTS_DIR"/

    rm -rf "$tmp_dir"
}

update_agents() {
    echo "Updating .agents..."

    # Remove existing .agents (except skills which are gitignored anyway)
    if [[ -d "$TARGET_AGENTS_DIR" ]]; then
        rm -rf "$TARGET_AGENTS_DIR"
    fi

    # Download fresh
    download_agents
}

ensure_agents_dir() {
    # Force update if requested
    if [[ $FORCE_UPDATE -eq 1 ]]; then
        update_agents
        return
    fi

    if agents_ready; then
        return
    fi

    if [[ -d "$SOURCE_AGENTS_DIR" && "$SOURCE_AGENTS_DIR" != "$TARGET_AGENTS_DIR" ]]; then
        echo "Copying .agents from $SOURCE_AGENTS_DIR..."
        mkdir -p "$TARGET_AGENTS_DIR"
        cp -R "$SOURCE_AGENTS_DIR"/. "$TARGET_AGENTS_DIR"/
        return
    fi

    download_agents
}

configure_claude_global_settings() {
    local claude_home="${HOME}/.claude"
    local settings_file="$claude_home/settings.json"

    echo "Configuring global Claude settings..."

    mkdir -p "$claude_home"

    # Start with existing settings or empty object
    local current_settings="{}"
    if [[ -f "$settings_file" ]]; then
        current_settings=$(cat "$settings_file")
    fi

    # Define the settings to merge
    local new_settings
    new_settings=$(cat <<'SETTINGS_EOF'
{
  "statusLine": {
    "type": "command",
    "command": "wt list statusline --claude-code"
  },
  "env": {
    "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR": "1",
    "DISABLE_COST_WARNINGS": "1",
    "ENABLE_LSP_TOOLS": "1",
    "ENABLE_TOOL_SEARCH": "1",
    "FORCE_AUTOUPDATE_PLUGINS": "1"
  },
  "includeCoAuthoredBy": false,
  "permissions": {
    "defaultMode": "bypassPermissions"
  },
  "enableAllProjectMcpServers": true
}
SETTINGS_EOF
)

    # Merge settings (new settings override existing)
    local merged_settings
    merged_settings=$(echo "$current_settings" | jq --argjson new "$new_settings" '. * $new')

    echo "$merged_settings" > "$settings_file"
    echo "  Updated $settings_file"
}

echo "Setting up agent skills..."

ensure_jq
ensure_agents_dir

chmod +x "$TARGET_AGENTS_DIR/setup.sh"

# Configure global Claude settings
configure_claude_global_settings

# Run the setup
echo "Installing skills..."
bash "$TARGET_AGENTS_DIR/setup.sh" "${ARGS[@]}"

echo "Done! Skills installed to .agents/skills/"
