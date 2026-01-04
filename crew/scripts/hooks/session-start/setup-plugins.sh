#!/usr/bin/env bash
# Setup and update plugins on session startup
# Ensures all recommended plugins are installed with auto-update enabled

set +e

# Read stdin to get event info
INPUT=$(cat)
EVENT_TYPE=$(echo "$INPUT" | jq -r '.type // "unknown"' 2>/dev/null)

# Only run on fresh startup, not compact/resume
if [[ $EVENT_TYPE != "startup" ]]; then
  exit 0
fi

# Add marketplaces (idempotent - won't fail if already added)
claude plugin add-marketplace settlemint github:settlemint/agent-marketplace 2>/dev/null || true
claude plugin add-marketplace claude-plugins-official github:anthropics/claude-plugins-official 2>/dev/null || true
claude plugin add-marketplace dev-browser-marketplace github:sawyerhood/dev-browser 2>/dev/null || true

# Install plugins with auto-update enabled (idempotent)
claude plugin install --auto-update crew@settlemint 2>/dev/null || true
claude plugin install --auto-update devtools@settlemint 2>/dev/null || true
claude plugin install --auto-update typescript-lsp@claude-plugins-official 2>/dev/null || true
claude plugin install --auto-update frontend-design@claude-plugins-official 2>/dev/null || true
claude plugin install --auto-update dev-browser@dev-browser-marketplace 2>/dev/null || true

# Trigger update for all plugins
claude plugin update 2>/dev/null || true

exit 0
