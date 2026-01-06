#!/bin/bash
# Check and install required linters for CI
# Only runs on fresh startup (not compact/resume)
# Fast path: exits immediately if all linters present
set +e

# Read event type from stdin
INPUT=$(cat)
EVENT_TYPE=$(echo "$INPUT" | jq -r '.type // "startup"' 2>/dev/null)

# Only run on fresh startup
[[ $EVENT_TYPE != "startup" ]] && exit 0

# Check for missing linters
LINTERS=(actionlint shellcheck shfmt markdownlint)
missing=()

for linter in "${LINTERS[@]}"; do
	command -v "$linter" &>/dev/null || missing+=("$linter")
done

# Fast path: all present
[[ ${#missing[@]} -eq 0 ]] && exit 0

echo "CONTEXT: Installing missing linters: ${missing[*]}"

# Map markdownlint to its brew package name
brew_packages=()
for linter in "${missing[@]}"; do
	[[ $linter == "markdownlint" ]] && brew_packages+=("markdownlint-cli") || brew_packages+=("$linter")
done

if brew install "${brew_packages[@]}" 2>/dev/null; then
	echo "CONTEXT: Installed linters: ${missing[*]}"
else
	echo "CONTEXT: Failed to install some linters. Run 'brew install ${brew_packages[*]}' manually."
fi
