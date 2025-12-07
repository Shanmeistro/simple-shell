#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "macOS Development Environment Bootstrap"
print_info "Supporting macOS 11-15 (Big Sur through current)"

# Check macOS version compatibility
if ! is_supported_macos; then
    print_error "This script supports macOS 11-15. Your version: $(get_macos_version)"
    exit 1
fi

print_success "macOS $(get_macos_version) is supported"

# Install Xcode Command Line Tools
install_xcode_clt

# Install Homebrew
install_homebrew

# Update Homebrew
print_header "Updating Homebrew"
brew update
brew upgrade

# Install core packages
print_header "Installing Core Development Tools"
source ./install-core.sh

# Shell selection
print_header "Shell Configuration"
echo "Which shell would you like to configure?"
echo "1) Zsh (recommended)"
echo "2) Bash"
echo "3) Skip shell configuration"

while true; do
    read -p "Enter your choice (1-3): " choice
    case $choice in
        1)
            print_info "Installing enhanced Zsh environment..."
            source ./install-shell.sh
            break
            ;;
        2)
            print_info "Installing enhanced Bash environment..."
            source ./install-bash.sh
            break
            ;;
        3)
            print_warning "Skipping shell configuration"
            break
            ;;
        *)
            print_error "Invalid choice. Please enter 1, 2, or 3."
            ;;
    esac
done

# Optional development environments
print_header "Optional Development Environments"
echo "Would you like to install additional development tools?"
echo "1) Node.js development environment"
echo "2) Python development environment"
echo "3) Docker Desktop"
echo "4) Java development environment"
echo "5) Go development environment"
echo "6) Rust development environment"
echo "7) All of the above"
echo "8) Custom selection (choose multiple)"
echo "9) Skip optional installations"

while true; do
    read -p "Enter your choice (1-9): " choice
    case $choice in
        1)
            source ./install-node.sh
            break
            ;;
        2)
            source ./optional-installers/install-python.sh
            break
            ;;
        3)
            source ./install-docker.sh
            break
            ;;
        4)
            source ./optional-installers/install-java.sh
            break
            ;;
        5)
            source ./optional-installers/install-go.sh
            break
            ;;
        6)
            source ./optional-installers/install-rust.sh
            break
            ;;
        7)
            print_info "Installing all development environments..."
            source ./install-node.sh
            source ./optional-installers/install-python.sh
            source ./install-docker.sh
            source ./optional-installers/install-java.sh
            source ./optional-installers/install-go.sh
            source ./optional-installers/install-rust.sh
            break
            ;;
        8)
            echo "Select tools to install (space-separated numbers, e.g., '1 2 4'):"
            echo "1=Node.js 2=Python 3=Docker 4=Java 5=Go 6=Rust"
            read -p "Your selection: " selections
            for selection in $selections; do
                case $selection in
                    1) source ./install-node.sh ;;
                    2) source ./optional-installers/install-python.sh ;;
                    3) source ./install-docker.sh ;;
                    4) source ./optional-installers/install-java.sh ;;
                    5) source ./optional-installers/install-go.sh ;;
                    6) source ./optional-installers/install-rust.sh ;;
                    *) print_warning "Unknown selection: $selection" ;;
                esac
            done
            break
            ;;
        9)
            print_warning "Skipping optional installations"
            break
            ;;
        *)
            print_error "Invalid choice. Please enter 1-9."
            ;;
    esac
done

print_success "\n🎉 macOS Development Environment Setup Complete!"
echo ""
echo "📝 Next steps:"
echo "• Restart your terminal or run 'source ~/.zshrc' (or ~/.bashrc)"
echo "• Check installed versions with: brew list"
echo "• Explore your new shell features and tools"
echo "• Consider installing additional tools with: brew search <tool>"
echo ""
echo "🔧 Installed core tools:"
echo "• Homebrew package manager"
echo "• Git version control"
echo "• Enhanced shell environment"
echo "• Development tools and utilities"
echo ""
echo "📖 For more help: brew help or visit https://brew.sh"