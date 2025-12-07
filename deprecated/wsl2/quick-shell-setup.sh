#!/usr/bin/env bash
set -e

# WSL2 Quick Shell Setup
# For users who only want the shell environment without dev tools

# Create scripts directory and helpers if they don't exist
if [ ! -d "scripts" ]; then
    mkdir -p scripts
fi

if [ ! -f "scripts/helpers.sh" ]; then
    cat > scripts/helpers.sh << 'HELPERS_EOF'
#!/usr/bin/env bash

# Helper function to print headers
print_header() {
    echo ""
    echo "======================================"
    echo " $1"
    echo "======================================"
    echo ""
}

# Helper function to print success messages
print_success() {
    echo "✅ $1"
}
HELPERS_EOF
fi

# Source the helpers
source ./scripts/helpers.sh

print_header "WSL2 Quick Shell Environment Setup"

echo "This will install:"
echo "• Zsh shell with Oh My Zsh framework"
echo "• Powerlevel10k theme"
echo "• Essential plugins (autosuggestions, syntax highlighting)"
echo "• MesloLGS NF fonts for Powerlevel10k"
echo "• WSL2-optimized shell configuration"
echo ""

read -p "Continue with installation? (Y/n): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$|^$ ]]; then
    echo "Installation cancelled."
    exit 0
fi

# Download the install-shell.sh script if it doesn't exist
if [ ! -f "install-shell.sh" ]; then
    print_header "Downloading Shell Installer"
    curl -fsSL https://raw.githubusercontent.com/USERNAME/REPO/main/wsl2/install-shell.sh -o install-shell.sh
    chmod +x install-shell.sh
fi

# Run the shell installer
./install-shell.sh

print_header "Quick Setup Complete!"
echo ""
echo "🎉 Your WSL2 shell environment is ready!"
echo ""
echo "Next steps:"
echo "1. Set your Windows Terminal font to 'MesloLGS NF'"
echo "2. Restart your terminal or run: exec zsh"
echo "3. (Optional) Customize Powerlevel10k theme: p10k configure"
echo ""
echo "For more advanced dev tools (Docker, Kubernetes, Cloud CLIs),"
echo "run the full bootstrap.sh instead."