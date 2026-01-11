#!/usr/bin/env bash
#
# git-machete installation and shell completion setup
#
# Usage:
#   ./install.sh           # Install and configure completions
#   ./install.sh --check   # Check if installed and configured
#
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}ℹ${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; }

# Detect OS
detect_os() {
	case "$(uname -s)" in
	Darwin*) echo "macos" ;;
	Linux*) echo "linux" ;;
	MINGW* | CYGWIN* | MSYS*) echo "windows" ;;
	*) echo "unknown" ;;
	esac
}

# Detect shell
detect_shell() {
	local shell_name
	shell_name=$(basename "${SHELL:-bash}")
	echo "$shell_name"
}

# Check if git-machete is installed
check_installed() {
	if command -v git-machete &>/dev/null; then
		local version
		version=$(git-machete version 2>/dev/null || echo "unknown")
		success "git-machete is installed: $version"
		return 0
	else
		return 1
	fi
}

# Install git-machete
install_git_machete() {
	local os
	os=$(detect_os)

	info "Installing git-machete..."

	case "$os" in
	macos)
		if command -v brew &>/dev/null; then
			info "Installing via Homebrew..."
			brew install git-machete
		else
			warn "Homebrew not found, falling back to pip"
			pip3 install --user git-machete
		fi
		;;
	linux)
		if command -v brew &>/dev/null; then
			info "Installing via Homebrew..."
			brew install git-machete
		elif command -v snap &>/dev/null; then
			info "Installing via Snap..."
			sudo snap install --classic git-machete
		elif command -v pip3 &>/dev/null; then
			info "Installing via pip..."
			pip3 install --user git-machete
		else
			error "No supported package manager found (brew, snap, or pip3)"
			echo "Please install manually: https://github.com/VirtusLab/git-machete#install"
			exit 1
		fi
		;;
	windows)
		if command -v scoop &>/dev/null; then
			info "Installing via Scoop..."
			scoop install git-machete
		elif command -v pip &>/dev/null; then
			info "Installing via pip..."
			pip install --user git-machete
		else
			error "No supported package manager found (scoop or pip)"
			echo "Please install manually: https://github.com/VirtusLab/git-machete#install"
			exit 1
		fi
		;;
	*)
		error "Unsupported OS"
		exit 1
		;;
	esac

	if check_installed; then
		success "git-machete installed successfully"
	else
		error "Installation failed"
		exit 1
	fi
}

# Configure shell completions
configure_completions() {
	local shell_type
	shell_type=$(detect_shell)

	info "Configuring completions for $shell_type..."

	case "$shell_type" in
	bash)
		local bashrc="${HOME}/.bashrc"
		local bash_profile="${HOME}/.bash_profile"
		local target_file="$bashrc"

		# Use .bash_profile on macOS
		if [[ $(detect_os) == "macos" ]] && [[ -f "$bash_profile" ]]; then
			target_file="$bash_profile"
		fi

		local completion_line='eval "$(git machete completion bash)"'

		if grep -q "git machete completion bash" "$target_file" 2>/dev/null; then
			success "Bash completions already configured in $target_file"
		else
			echo "" >>"$target_file"
			echo "# git-machete completions" >>"$target_file"
			echo "$completion_line" >>"$target_file"
			success "Added bash completions to $target_file"
			warn "Run 'source $target_file' or restart your terminal"
		fi
		;;

	zsh)
		local zshrc="${HOME}/.zshrc"
		local completion_line='eval "$(git machete completion zsh)"'

		if grep -q "git machete completion zsh" "$zshrc" 2>/dev/null; then
			success "Zsh completions already configured in $zshrc"
		else
			echo "" >>"$zshrc"
			echo "# git-machete completions" >>"$zshrc"
			echo "$completion_line" >>"$zshrc"
			success "Added zsh completions to $zshrc"
			warn "Run 'source $zshrc' or restart your terminal"
		fi
		;;

	fish)
		local fish_config="${HOME}/.config/fish/config.fish"
		local completion_line='git machete completion fish | source'

		mkdir -p "$(dirname "$fish_config")"

		if grep -q "git machete completion fish" "$fish_config" 2>/dev/null; then
			success "Fish completions already configured in $fish_config"
		else
			echo "" >>"$fish_config"
			echo "# git-machete completions" >>"$fish_config"
			echo "$completion_line" >>"$fish_config"
			success "Added fish completions to $fish_config"
			warn "Run 'source $fish_config' or restart your terminal"
		fi
		;;

	*)
		warn "Unknown shell: $shell_type"
		info "Manual completion setup:"
		echo "  Bash: eval \"\$(git machete completion bash)\""
		echo "  Zsh:  eval \"\$(git machete completion zsh)\""
		echo "  Fish: git machete completion fish | source"
		;;
	esac
}

# Configure recommended git-machete settings
configure_settings() {
	info "Configuring recommended settings..."

	# Enable squash merge detection
	if ! git config --global machete.squashMergeDetection &>/dev/null; then
		git config --global machete.squashMergeDetection simple
		success "Enabled squash merge detection (simple mode)"
	else
		success "Squash merge detection already configured"
	fi
}

# Show usage help
show_help() {
	echo "git-machete Installation Script"
	echo ""
	echo "Usage:"
	echo "  ./install.sh           Install git-machete and configure completions"
	echo "  ./install.sh --check   Check installation status"
	echo "  ./install.sh --help    Show this help"
	echo ""
	echo "What this script does:"
	echo "  1. Installs git-machete via brew/snap/pip (if not already installed)"
	echo "  2. Configures shell completions for bash/zsh/fish"
	echo "  3. Sets up recommended git config options"
}

# Main
main() {
	case "${1:-}" in
	--check)
		echo "Checking git-machete installation..."
		if check_installed; then
			info "Shell: $(detect_shell)"
			info "OS: $(detect_os)"
		else
			warn "git-machete is not installed"
			exit 1
		fi
		;;
	--help | -h)
		show_help
		;;
	*)
		echo "=== git-machete Installation ==="
		echo ""

		if ! check_installed; then
			install_git_machete
		fi

		echo ""
		configure_completions

		echo ""
		configure_settings

		echo ""
		success "Setup complete!"
		echo ""
		info "Quick start:"
		echo "  cd your-repo"
		echo "  git machete discover      # Discover branch layout"
		echo "  git machete status -l     # View branch tree"
		echo "  git machete traverse -W   # Sync all branches"
		;;
	esac
}

main "$@"
