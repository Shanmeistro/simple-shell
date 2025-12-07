#!/usr/bin/env bash
set -e

# Load helper functions
source ./scripts/helpers.sh

print_header "WSL Environment Bootstrap"

# Update system
sudo apt update -y && sudo apt upgrade -y

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

# Install Node.js (required)
./install-node.sh

# Install Docker + container tooling
./install-docker.sh

# Install Kubernetes tooling (kubectl, kind)
./install-kubernetes.sh

print_header "Optional Cloud & DevOps Tools"

echo "Choose additional tools to install:"
options=(
    "AWS CLI"
    "Azure CLI"
    "Google Cloud SDK"
    "Terraform"
    "None (finish setup)"
)

select opt in "${options[@]}"; do
    case $opt in
        "AWS CLI") ./optional/install-aws.sh ;;
        "Azure CLI") ./optional/install-azure.sh ;;
        "Google Cloud SDK") ./optional/install-gcloud.sh ;;
        "Terraform") ./optional/install-terraform.sh ;;
        "None (finish setup)") break ;;
        *) echo "Invalid option." ;;
    esac
done

print_header "Bootstrap Complete!"
echo ""
if command -v zsh >/dev/null 2>&1 && [ -d ~/.oh-my-zsh ]; then
    echo "🎉 Your WSL2 environment is ready with Zsh customization!"
    echo ""
    echo "Final steps:"
    echo "1. Set Windows Terminal font to 'MesloLGS NF' for best experience"
    echo "2. Restart terminal or run: exec zsh"
    echo "3. (Optional) Customize Powerlevel10k: p10k configure"
elif command -v starship >/dev/null 2>&1 && [ -f ~/.config/starship.toml ]; then
    echo "🎉 Your WSL2 environment is ready with Enhanced Bash!"
    echo ""
    echo "Final steps:"
    echo "1. Set Windows Terminal font to 'MesloLGS NF' for best experience"
    echo "2. Restart terminal or run: exec bash"
    echo "3. Try new commands: fcd, fzfp, sysinfo"
else
    echo "🎉 Your WSL2 environment is ready!"
fi
echo ""
echo "Restart your shell and enjoy your environment 😎"
