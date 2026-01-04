#!/bin/bash
# Check and install required linters for CI
# Hooks must never fail - use defensive error handling
set +e

source "$(dirname "$0")/../lib/hook-logger.sh" 2>/dev/null || true

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

result="linters-ok"
if [[ ${#missing[@]} -gt 0 ]]; then
	if [[ ${#installed[@]} -gt 0 ]]; then
		result="linters-installed:${installed[*]}"
	else
		result="linters-missing:${missing[*]}"
	fi
fi

log_hook "SessionStart" "check-linters" "$result" "${missing[*]}" 2>/dev/null || true
