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
claude plugin marketplace add settlemint/agent-marketplace 2>/dev/null || true
claude plugin marketplace add anthropics/claude-plugins-official 2>/dev/null || true
claude plugin marketplace add sawyerhood/dev-browser 2>/dev/null || true

# Install plugins (idempotent)
claude plugin install crew@settlemint 2>/dev/null || true
claude plugin install devtools@settlemint 2>/dev/null || true
claude plugin install typescript-lsp@anthropics-claude-plugins-official 2>/dev/null || true
claude plugin install frontend-design@anthropics-claude-plugins-official 2>/dev/null || true
claude plugin install dev-browser@sawyerhood-dev-browser 2>/dev/null || true

# Trigger update for all marketplaces
claude plugin marketplace update settlemint 2>/dev/null || true
claude plugin marketplace update anthropics-claude-plugins-official 2>/dev/null || true
claude plugin marketplace update sawyerhood-dev-browser 2>/dev/null || true

exit 0
