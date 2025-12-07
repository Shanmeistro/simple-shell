#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Core Development Packages for macOS"

# Essential development tools
print_header "Installing Essential Development Tools"
brew_install git
brew_install curl
brew_install wget
brew_install tree
brew_install jq
brew_install yq
brew_install htop
brew_install neofetch
brew_install bat
brew_install ripgrep
brew_install fd
brew_install exa
brew_install fzf
brew_install the_silver_searcher
brew_install watch

# Text editors and utilities
print_header "Installing Text Editors and Utilities"
brew_install vim
brew_install nano
brew_install tmux
brew_install screen
brew_install rsync
brew_install unzip
brew_install p7zip

# Network tools
print_header "Installing Network Tools"
brew_install nmap
brew_install telnet
brew_install netcat
brew_install openssh

# Setup fzf key bindings and fuzzy completion
print_header "Setting up fzf"
$(brew --prefix)/opt/fzf/install --all --no-bash --no-fish

print_success "Core Development Packages Installed Successfully!"
echo ""
echo "📦 Installed packages:"
echo "• Git, curl, wget - Basic tools"
echo "• tree, htop, neofetch - System utilities"
echo "• bat, ripgrep, fd, exa - Modern CLI tools"
echo "• fzf - Fuzzy finder with key bindings"
echo "• jq, yq - JSON/YAML processors"
echo "• vim, tmux - Development tools"
echo "• nmap, openssh - Network tools"