#!/usr/bin/env bash

# ===============================================================
# Simple Shell Environment - Hybrid Installer
# Shell frontend with user-friendly interface
# ===============================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Helper functions
print_header() {
    echo -e "\n${BOLD}${BLUE}============================================${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${BLUE}============================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

# Check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Detect platform
detect_platform() {
    local platform="unknown"
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if grep -qi microsoft /proc/version 2>/dev/null; then
            platform="wsl2"
        else
            platform="linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        platform="macos"
    fi
    
    echo "$platform"
}

# Check Python availability
check_python() {
    if command_exists python3; then
        local version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        local major=$(echo "$version" | cut -d'.' -f1)
        local minor=$(echo "$version" | cut -d'.' -f2)
        
        if [ "$major" -eq 3 ] && [ "$minor" -ge 6 ]; then
            return 0
        fi
    fi
    return 1
}

# Install Python if needed
install_python() {
    local platform=$(detect_platform)
    
    print_info "Python 3.6+ is required but not found. Installing..."
    
    case $platform in
        "wsl2"|"linux")
            if command_exists apt; then
                sudo apt update
                sudo apt install -y python3 python3-pip
            elif command_exists yum; then
                sudo yum install -y python3 python3-pip
            elif command_exists dnf; then
                sudo dnf install -y python3 python3-pip
            else
                print_error "Cannot install Python automatically. Please install Python 3.6+ manually."
                return 1
            fi
            ;;
        "macos")
            if command_exists brew; then
                brew install python3
            else
                print_error "Homebrew not found. Please install Python 3.6+ manually."
                return 1
            fi
            ;;
        *)
            print_error "Unsupported platform for automatic Python installation."
            return 1
            ;;
    esac
    
    return 0
}

# User configuration selection
select_shell() {
    echo "Choose your shell:"
    echo "1) Bash (widely compatible, stable)"
    echo "2) Zsh (modern features, powerful customization)"
    echo "3) Keep current shell ($(basename "$SHELL"))"
    echo
    read -p "Enter choice (1-3) [1]: " choice
    choice=${choice:-1}
    
    case $choice in
        1) echo "bash" ;;
        2) echo "zsh" ;;
        3) basename "$SHELL" ;;
        *) echo "bash" ;;
    esac
}

select_framework() {
    local shell_type=$1
    
    echo "Choose framework for $shell_type:"
    
    if [ "$shell_type" = "zsh" ]; then
        echo "1) Oh My Zsh (popular, feature-rich)"
        echo "2) None (minimal setup)"
        echo
        read -p "Enter choice (1-2) [1]: " choice
        choice=${choice:-1}
        
        case $choice in
            1) echo "oh-my-zsh" ;;
            2) echo "none" ;;
            *) echo "oh-my-zsh" ;;
        esac
    elif [ "$shell_type" = "bash" ]; then
        echo "1) Bash-it (bash equivalent of oh-my-zsh)"
        echo "2) None (minimal setup)"
        echo
        read -p "Enter choice (1-2) [2]: " choice
        choice=${choice:-2}
        
        case $choice in
            1) echo "bash-it" ;;
            2) echo "none" ;;
            *) echo "none" ;;
        esac
    else
        echo "none"
    fi
}

select_prompt() {
    local shell_type=$1
    local framework=$2
    
    echo "Choose prompt/theme:"
    
    if [ "$shell_type" = "zsh" ]; then
        if [ "$framework" = "oh-my-zsh" ]; then
            echo "1) Powerlevel10k (beautiful, fast)"
            echo "2) Starship (cross-shell, modern)"
            echo "3) Default Oh My Zsh theme"
        else
            echo "1) Starship (cross-shell, modern)"
            echo "2) Default Zsh prompt"
        fi
    elif [ "$shell_type" = "bash" ]; then
        echo "1) Starship (fast, modern)"
        echo "2) Oh My Posh with 1_shell theme (colorful)"
        if [ "$framework" = "bash-it" ]; then
            echo "3) Bash-it powerline theme"
            echo "4) Default bash prompt"
        else
            echo "3) Enhanced bash prompt"
        fi
    fi
    
    echo
    read -p "Enter choice [1]: " choice
    choice=${choice:-1}
    
    if [ "$shell_type" = "zsh" ]; then
        if [ "$framework" = "oh-my-zsh" ]; then
            case $choice in
                1) echo "powerlevel10k" ;;
                2) echo "starship" ;;
                3) echo "default" ;;
                *) echo "powerlevel10k" ;;
            esac
        else
            case $choice in
                1) echo "starship" ;;
                2) echo "default" ;;
                *) echo "starship" ;;
            esac
        fi
    elif [ "$shell_type" = "bash" ]; then
        if [ "$framework" = "bash-it" ]; then
            case $choice in
                1) echo "starship" ;;
                2) echo "oh-my-posh" ;;
                3) echo "bash-it" ;;
                4) echo "default" ;;
                *) echo "starship" ;;
            esac
        else
            case $choice in
                1) echo "starship" ;;
                2) echo "oh-my-posh" ;;
                3) echo "enhanced" ;;
                *) echo "starship" ;;
            esac
        fi
    fi
}

# Generate configuration
generate_config() {
    local shell_type=$1
    local framework=$2
    local prompt=$3
    
    cat > "$SCRIPT_DIR/config.json" << EOF
{
    "shell": "$shell_type",
    "framework": "$framework",
    "prompt": "$prompt",
    "backup": true,
    "install_fonts": true,
    "set_default": true,
    "platform": "$(detect_platform)"
}
EOF
}

# Main installation
main() {
    print_header "Simple Shell Environment Installer"
    
    local platform=$(detect_platform)
    
    echo "Detected platform: $platform"
    echo
    
    if [ "$platform" = "unknown" ]; then
        print_error "Unsupported platform. This installer supports Linux, WSL2, and macOS."
        exit 1
    fi
    
    # Check Python
    if ! check_python; then
        if ! install_python; then
            print_error "Python installation failed. Please install Python 3.6+ manually and try again."
            exit 1
        fi
    fi
    
    print_success "Python 3.6+ is available"
    echo
    
    # Interactive configuration
    print_info "Let's configure your shell environment..."
    echo
    
    local shell_type=$(select_shell)
    echo
    
    local framework=$(select_framework "$shell_type")
    echo
    
    local prompt=$(select_prompt "$shell_type" "$framework")
    echo
    
    # Show configuration summary
    print_header "Configuration Summary"
    echo "Shell: $shell_type"
    echo "Framework: $framework"
    echo "Prompt: $prompt"
    echo "Platform: $platform"
    echo
    
    # Confirmation
    read -p "Proceed with installation? (Y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$|^$ ]]; then
        echo "Installation cancelled."
        exit 0
    fi
    
    # Generate configuration and run Python installer
    generate_config "$shell_type" "$framework" "$prompt"
    
    print_header "Running Installation"
    
    if python3 "$SCRIPT_DIR/setup.py" "$SCRIPT_DIR/config.json"; then
        print_success "Installation completed successfully!"
        
        # Clean up
        rm -f "$SCRIPT_DIR/config.json"
        
        echo
        print_info "Please restart your terminal or run: exec $shell_type"
        
        if [ "$platform" = "wsl2" ]; then
            print_info "For best experience in WSL2:"
            echo "  1. Set Windows Terminal font to a Nerd Font"
            echo "  2. Restart Windows Terminal"
        fi
    else
        print_error "Installation failed. Check the output above for details."
        rm -f "$SCRIPT_DIR/config.json"
        exit 1
    fi
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Simple Shell Environment Installer"
        echo
        echo "Usage: $0 [options]"
        echo
        echo "Options:"
        echo "  --help, -h     Show this help"
        echo "  --version      Show version info"
        echo
        echo "Interactive installer for shell environments with:"
        echo "  • Shell choice (Bash/Zsh)"
        echo "  • Framework options (Oh My Zsh, Bash-it, or none)"
        echo "  • Prompt themes (Powerlevel10k, Starship, Oh My Posh)"
        echo "  • Font installation (Nerd Fonts)"
        echo "  • IDE/WSL2 compatibility"
        echo
        exit 0
        ;;
    --version)
        echo "Simple Shell Environment v2.0"
        echo "Hybrid installer (Shell + Python backend)"
        exit 0
        ;;
esac

# Run main function
main "$@"