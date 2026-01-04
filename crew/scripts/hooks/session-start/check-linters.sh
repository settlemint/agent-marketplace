#!/bin/bash
# Check and install required linters for CI
# Hooks must never fail - use defensive error handling
set +e

LINTERS=(actionlint shellcheck shfmt markdownlint)
missing=()
installed=()

for linter in "${LINTERS[@]}"; do
	if ! command -v "$linter" &>/dev/null; then
		missing+=("$linter")
	fi
done

if [[ ${#missing[@]} -gt 0 ]]; then
	echo "CONTEXT: Installing missing linters: ${missing[*]}"

	# Map markdownlint to its brew package name
	brew_packages=()
	for linter in "${missing[@]}"; do
		if [[ $linter == "markdownlint" ]]; then
			brew_packages+=("markdownlint-cli")
		else
			brew_packages+=("$linter")
		fi
	done

	if brew install "${brew_packages[@]}" 2>/dev/null; then
		installed=("${missing[@]}")
		echo "CONTEXT: Installed linters: ${installed[*]}"
	else
		echo "CONTEXT: Failed to install some linters. Run 'brew install ${brew_packages[*]}' manually."
	fi
fi

