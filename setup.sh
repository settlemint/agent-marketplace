#!/bin/bash
set -e

REPO="roderik/mpe"
BRANCH="main"
ARCHIVE_URL="https://github.com/$REPO/archive/refs/heads/$BRANCH.tar.gz"
ARGS=("$@")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="$(pwd)"
TARGET_AGENTS_DIR="$TARGET_DIR/.agents"
SOURCE_AGENTS_DIR="$SCRIPT_DIR/.agents"

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

ensure_agents_dir() {
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

echo "Setting up agent skills..."

ensure_agents_dir

chmod +x "$TARGET_AGENTS_DIR/setup.sh"

# Run the setup
echo "Installing skills..."
ensure_jq
bash "$TARGET_AGENTS_DIR/setup.sh" "${ARGS[@]}"

echo "Done! Skills installed to .agents/skills/"
