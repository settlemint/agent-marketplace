#!/bin/bash
# Post-compaction skill reload hook
# Fires on SessionStart — only outputs when source is "compact"

INPUT=$(cat)
SOURCE=$(echo "$INPUT" | jq -r '.source // empty')

if [ "$SOURCE" = "compact" ]; then
  cat <<'EOF'
COMPACTION DETECTED — SKILL RELOAD REQUIRED

Context was compacted. The crew-claude skill workflow (phases, gates, classification) was lost.

Your IMMEDIATE next action MUST be:
  Skill({ skill: "crew-claude" })

Do NOT continue previous work until the skill is reloaded and you output:
  CREW-CLAUDE LOADED: ✓

Then resume from where you left off by checking TaskList.
EOF
fi
