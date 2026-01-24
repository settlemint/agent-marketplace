#!/bin/bash

# Only runs in remote environments
if [ "$CLAUDE_CODE_REMOTE" != "true" ]; then
    exit 0
fi

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$SCRIPT_DIR/../../../.."

has_cmd() {
    command -v "$1" >/dev/null 2>&1
}

python_module_installed() {
    python3 - <<PY >/dev/null 2>&1
import importlib.util
import sys
sys.exit(0 if importlib.util.find_spec("$1") else 1)
PY
}

echo "Installing system dependencies..."
export DEBIAN_FRONTEND=noninteractive
missing_pkgs=()
has_cmd jq || missing_pkgs+=("jq")
has_cmd rg || missing_pkgs+=("ripgrep")
has_cmd dot || missing_pkgs+=("graphviz")
has_cmd pdfinfo || missing_pkgs+=("poppler-utils")
has_cmd soffice || missing_pkgs+=("libreoffice-calc")
has_cmd unzip || missing_pkgs+=("unzip")

if has_cmd apt-get && [[ ${#missing_pkgs[@]} -gt 0 ]]; then
    apt-get update -qq 2>/dev/null || true
    apt-get install -y -qq "${missing_pkgs[@]}" >/dev/null 2>&1 || true
fi

echo "Installing Python packages..."
python_pkgs=()
if has_cmd python3; then
    python_module_installed markitdown || python_pkgs+=("markitdown[pptx]")
    python_module_installed defusedxml || python_pkgs+=("defusedxml")
fi
has_cmd semgrep || python_pkgs+=("semgrep")

if [[ ${#python_pkgs[@]} -gt 0 ]]; then
    if has_cmd uv; then
        uv pip install --system --break-system-packages "${python_pkgs[@]}" --quiet || true
    elif has_cmd python3; then
        python3 -m pip install --break-system-packages "${python_pkgs[@]}" --quiet || true
    else
        echo "  Skipping Python packages (python3 not available)"
    fi
fi

echo "Installing Node packages..."
node_pkgs=(agent-browser pptxgenjs playwright react-icons react react-dom sharp)
if has_cmd bun; then
    bun install -g "${node_pkgs[@]}" --silent || true
elif has_cmd npm; then
    npm install -g "${node_pkgs[@]}" --silent || true
else
    echo "  Skipping Node packages (bun/npm not available)"
fi

if has_cmd agent-browser; then
    agent-browser install >/dev/null 2>&1 || true
fi

if has_cmd playwright; then
    playwright install chromium >/dev/null 2>&1 || true
elif has_cmd bunx; then
    bunx playwright install chromium >/dev/null 2>&1 || true
elif has_cmd npx; then
    npx playwright install chromium >/dev/null 2>&1 || true
fi

echo "Installing CodeQL..."
if ! command -v codeql &>/dev/null; then
    if has_cmd curl && curl -sL --max-time 10 https://github.com/github/codeql-cli-binaries/releases/latest/download/codeql-linux64.zip -o /tmp/codeql.zip 2>/dev/null; then
        if has_cmd unzip; then
            unzip -q /tmp/codeql.zip -d /usr/local/
            ln -sf /usr/local/codeql/codeql /usr/local/bin/codeql
            rm -f /tmp/codeql.zip
        else
            echo "  Skipping CodeQL (unzip not available)"
        fi
    else
        echo "  Skipping CodeQL (download blocked by proxy)"
    fi
fi

if [ -f "$PROJECT_ROOT/package.json" ]; then
    echo "Installing project dependencies..."
    cd "$PROJECT_ROOT"
    if has_cmd bun; then
        bun install
    elif has_cmd npm; then
        npm install
    else
        echo "  Skipping project dependencies (bun/npm not available)"
    fi
fi

echo "Remote environment setup complete"
