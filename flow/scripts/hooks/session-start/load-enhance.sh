#!/usr/bin/env bash
# Load core skills for every session and user prompt
# Fires on SessionStart AND UserPromptSubmit to ensure skills are always available
set +e
echo 'Skill({ skill: "flow:enhance" })
Skill({ skill: "devtools:rule-of-five" })'
