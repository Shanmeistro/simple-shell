#!/usr/bin/env bash
set -e

# Load helper functions
source ./scripts/helpers.sh

print_header "Linux Environment Bootstrap"

# Check distribution compatibility
check_linux_distro

# Update and upgrade system
update_packages
upgrade_packages

# Install core tools
./install-core.sh

# Shell Environment Setup (Interactive)
echo ""
echo "🐚 Shell Environment Setup"
echo "Choose your shell environment:"
echo ""
echo "1) Zsh with Oh My Zsh + Powerlevel10k (recommended)"
echo "   • Modern shell with advanced features"
echo "   • Oh My Zsh framework with plugins"
echo "   • Powerlevel10k theme for beautiful prompt"
echo ""
echo "2) Enhanced Bash with Starship + Bash-it"
echo "   • Enhanced Bash with modern tools"
echo "   • Starship prompt (fast and customizable)"
echo "   • Bash-it framework and useful CLI tools"
echo ""
echo "3) Skip shell customization"
echo ""
read -p "Enter choice (1-3) [1]: " choice
choice=${choice:-1}

case $choice in
    1)
        echo "Installing Zsh environment..."
        ./install-shell.sh
        ;;
    2)
        echo "Installing enhanced Bash environment..."
        ./install-bash.sh
        ;;
    3)
        echo "Skipping shell environment setup"
        ;;
    *)
        echo "Invalid choice, defaulting to Zsh..."
        ./install-shell.sh
        ;;
esac

echo ""
echo "🛠️ Optional Development Tools"
echo "Would you like to install optional development tools?"
echo ""
echo "Available options:"
echo "• Docker & Kubernetes"
echo "• Node.js & Development Tools"
echo "• Cloud CLIs (AWS, Azure, GCloud)"
echo "• Additional development environments"
echo ""
echo "You can install these now or run individual scripts later:"
echo "• ./install-docker.sh       - Docker and container tools"
echo "• ./install-kubernetes.sh   - Kubernetes tools (kubectl, helm)"
echo "• ./install-node.sh         - Node.js and npm"
echo "• ./optional-installers/    - Cloud CLIs and specialized tools"
echo ""
read -p "Install Docker and basic development tools now? (y/N): " install_dev
install_dev=${install_dev:-n}

case $install_dev in
    y|Y|yes|YES)
        echo "Installing Docker and Node.js..."
        ./install-docker.sh
        ./install-node.sh
        ;;
    *)
        echo "Skipping optional tools installation"
        echo "You can install them later using the individual scripts"
        ;;
esac

print_success "Linux environment bootstrap completed!"
echo ""
echo "🚀 Next steps:"
echo "• Restart your terminal or run 'source ~/.bashrc' or 'source ~/.zshrc'"
echo "• Explore optional tools in ./optional-installers/"
echo "• Customize your shell configuration as needed"
echo ""
echo "📚 For more information:"
echo "• Check the README.md in the project root"
echo "• Review individual installation scripts in this directory"