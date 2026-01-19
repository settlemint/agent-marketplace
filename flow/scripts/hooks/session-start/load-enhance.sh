#!/usr/bin/env bash
# Load core skills for every session and user prompt
# Fires on SessionStart AND UserPromptSubmit to ensure skills are always available
set +e

# Core workflow skills (always loaded)
cat <<'EOF'
Skill({ skill: "flow:enhance" })
Skill({ skill: "devtools:rule-of-five" })
EOF

# Meta/review skills (always available for quality work)
cat <<'EOF'
Skill({ skill: "devtools:codex-patterns" })
Skill({ skill: "devtools:security-checklist" })
Skill({ skill: "devtools:code-health" })
Skill({ skill: "devtools:spec-writing" })
Skill({ skill: "devtools:stack-review" })
Skill({ skill: "devtools:typescript-lsp" })
Skill({ skill: "devtools:visual-context" })
Skill({ skill: "devtools:critique-driven" })
Skill({ skill: "devtools:vercel-design-guidelines" })
Skill({ skill: "devtools:chrome-testing" })
Skill({ skill: "devtools:ast-grep" })
Skill({ skill: "devtools:design-principles" })
Skill({ skill: "devtools:react-best-practices" })
EOF

# Official Anthropic plugins (always available)
cat <<'EOF'
Skill({ skill: "code-simplifier:code-simplifier" })
EOF
