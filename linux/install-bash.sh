#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Configuring Bash Environment"

# Ensure bash-completion is available
if ! dpkg -s bash-completion &>/dev/null; then
    sudo apt-get install -y bash-completion
fi

# Deploy dotfiles/.bashrc from the repo root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_BASHRC="$SCRIPT_DIR/../dotfiles/.bashrc"

if [ -f "$DOTFILES_BASHRC" ]; then
    cp "$DOTFILES_BASHRC" "$HOME/.bashrc"
    print_success ".bashrc deployed from dotfiles"
else
    print_error "dotfiles/.bashrc not found at $DOTFILES_BASHRC"
    exit 1
fi

print_success "Bash configuration complete"
echo ""
echo "Run 'source ~/.bashrc' to apply changes to your current session."
