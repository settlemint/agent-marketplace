#!/usr/bin/env bash
# Validate all skills in the flow plugin
# Usage: ./validate-all-skills.sh [--fix]

set -euo pipefail

SCRIPT_DIR=$(dirname "$0")
PLUGIN_ROOT=$(dirname "$SCRIPT_DIR")
VALIDATOR="$SCRIPT_DIR/skills/validate-skill.py"

# Check for Python
if ! command -v python3 &>/dev/null; then
  echo "Error: python3 is required but not installed"
  exit 1
fi

# Check for PyYAML
if ! python3 -c "import yaml" 2>/dev/null; then
  echo "Error: PyYAML is required. Install with: pip3 install pyyaml"
  exit 1
fi

# Find all SKILL.md files
SKILLS_DIR="$PLUGIN_ROOT/skills"

if [[ ! -d "$SKILLS_DIR" ]]; then
  echo "Error: Skills directory not found: $SKILLS_DIR"
  exit 1
fi

echo "Validating skills in: $SKILLS_DIR"
echo ""

# Run the Python validator
python3 "$VALIDATOR" "$SKILLS_DIR"
exit_code=$?

echo ""
if [[ $exit_code -eq 0 ]]; then
  echo "All skills valid!"
else
  echo "Validation failed. Fix the errors above."
fi

exit $exit_code
