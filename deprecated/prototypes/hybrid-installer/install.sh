#!/bin/bash

# ===============================================================
# Simple Shell Environment - Hybrid Installer (Shell + Python)
# Entry point script for cross-platform installation
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

print_header() {
    echo -e "\n${BOLD}${BLUE}============================================${NC}"
    echo -e "${BOLD}${CYAN}  $1${NC}"
    echo -e "${BOLD}${BLUE}============================================${NC}\n"
}

print_step() {
    echo -e "\n${GREEN}==> $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
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
    local os_name=""
    local package_manager=""
    
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /proc/version ] && grep -qi microsoft /proc/version; then
            os_name="wsl2"
        else
            os_name="linux"
        fi
        
        if command_exists apt; then
            package_manager="apt"
        elif command_exists dnf; then
            package_manager="dnf"
        elif command_exists yum; then
            package_manager="yum"
        else
            package_manager="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        os_name="macos"
        package_manager="brew"
    else
        os_name="unknown"
        package_manager="unknown"
    fi
    
    echo "${os_name}:${package_manager}"
}

# Check Python availability
check_python() {
    print_step "Checking Python availability"
    
    if command_exists python3; then
        local version=$(python3 -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        print_success "Python 3 found: version $version"
        
        # Check if version is sufficient (3.6+)
        if python3 -c "import sys; sys.exit(0 if sys.version_info >= (3, 6) else 1)"; then
            return 0
        else
            print_warning "Python 3.6+ required, found $version"
            return 1
        fi
    elif command_exists python; then
        local version=$(python -c "import sys; print(f'{sys.version_info.major}.{sys.version_info.minor}')")
        if python -c "import sys; sys.exit(0 if sys.version_info >= (3, 6) else 1)"; then
            print_success "Python found: version $version"
            return 0
        else
            print_warning "Python 2 or old Python 3 found: $version"
            return 1
        fi
    else
        print_error "Python not found"
        return 1
    fi
}

# Install Python if needed
install_python() {
    local platform_info="$(detect_platform)"
    local os_name="${platform_info%%:*}"
    local package_manager="${platform_info##*:}"
    
    print_step "Installing Python"
    
    case "$package_manager" in
        "apt")
            sudo apt update
            sudo apt install -y python3 python3-pip python3-venv
            ;;
        "dnf")
            sudo dnf install -y python3 python3-pip
            ;;
        "yum")
            sudo yum install -y python3 python3-pip
            ;;
        "brew")
            if ! command_exists brew; then
                print_error "Homebrew not found. Please install it first:"
                print_info "Visit: https://brew.sh"
                exit 1
            fi
            brew install python3
            ;;
        *)
            print_error "Unable to install Python automatically on this system"
            print_info "Please install Python 3.6+ manually and run this script again"
            exit 1
            ;;
    esac
}

# Check and install system dependencies
install_system_deps() {
    local platform_info="$(detect_platform)"
    local os_name="${platform_info%%:*}"
    local package_manager="${platform_info##*:}"
    
    print_step "Installing system dependencies"
    
    case "$package_manager" in
        "apt")
            sudo apt update
            sudo apt install -y git curl wget
            ;;
        "dnf")
            sudo dnf install -y git curl wget
            ;;
        "yum")
            sudo yum install -y git curl wget
            ;;
        "brew")
            # Git and curl should already be available on macOS
            if ! command_exists git; then
                brew install git
            fi
            ;;
        *)
            print_warning "Cannot install system dependencies automatically"
            ;;
    esac
}

# Show platform information
show_platform_info() {
    local platform_info="$(detect_platform)"
    local os_name="${platform_info%%:*}"
    local package_manager="${platform_info##*:}"
    
    print_header "Platform Information"
    
    case "$os_name" in
        "wsl2")
            print_info "Environment: WSL2 (Windows Subsystem for Linux)"
            print_info "Package Manager: $package_manager"
            ;;
        "linux")
            print_info "Environment: Native Linux"
            print_info "Package Manager: $package_manager"
            ;;
        "macos")
            print_info "Environment: macOS"
            print_info "Package Manager: $package_manager"
            ;;
        *)
            print_warning "Unknown environment detected"
            print_info "OS Type: $OSTYPE"
            ;;
    esac
}

# Alternative installation methods for unsupported environments
show_alternatives() {
    print_header "Alternative Installation Methods"
    
    echo -e "${YELLOW}If you don't have a supported environment, try these options:${NC}\n"
    
    echo -e "${BLUE}1. Docker-based Installation:${NC}"
    echo -e "   ${CYAN}docker run --rm -it -v \$(pwd):/workspace ubuntu:20.04${NC}"
    echo -e "   ${CYAN}# Then inside container: apt update && apt install -y git python3${NC}"
    echo -e "   ${CYAN}# Clone repo and run installer${NC}\n"
    
    echo -e "${BLUE}2. GitHub Codespaces:${NC}"
    echo -e "   ${CYAN}Create a codespace from your repository${NC}"
    echo -e "   ${CYAN}Run the installer directly${NC}\n"
    
    echo -e "${BLUE}3. Cloud Shell (Google, Azure, AWS):${NC}"
    echo -e "   ${CYAN}Use your cloud provider's shell environment${NC}"
    echo -e "   ${CYAN}Clone repo and run installer${NC}\n"
    
    echo -e "${BLUE}4. Virtual Machine:${NC}"
    echo -e "   ${CYAN}Install Ubuntu 20.04+ in VirtualBox/VMware${NC}"
    echo -e "   ${CYAN}Run installer in the VM${NC}\n"
}

# Check for existing installations
check_existing() {
    print_step "Checking for existing installations"
    
    local found_existing=false
    
    if [ -d "$HOME/.oh-my-zsh" ]; then
        print_warning "Oh My Zsh already installed"
        found_existing=true
    fi
    
    if [ -f "$HOME/.zshrc" ]; then
        print_warning ".zshrc already exists"
        found_existing=true
    fi
    
    if [ -f "$HOME/.p10k.zsh" ]; then
        print_warning ".p10k.zsh already exists"
        found_existing=true
    fi
    
    if [ "$found_existing" = true ]; then
        echo
        print_warning "Existing shell configurations found!"
        print_info "The installer will backup your existing configurations before proceeding."
        echo
        read -p "Continue with installation? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_info "Installation cancelled by user"
            exit 0
        fi
    else
        print_success "No existing configurations found"
    fi
}

# Run the Python installer
run_python_installer() {
    local python_cmd="python3"
    
    # Use python if python3 is not available but python is Python 3
    if ! command_exists python3 && command_exists python; then
        if python -c "import sys; sys.exit(0 if sys.version_info >= (3, 6) else 1)" 2>/dev/null; then
            python_cmd="python"
        fi
    fi
    
    print_step "Running Python installer"
    
    # Check if we have the modular installer or the standalone one
    if [ -f "$SCRIPT_DIR/setup.py" ]; then
        $python_cmd "$SCRIPT_DIR/setup.py" "$@"
    elif [ -f "$SCRIPT_DIR/install.py" ]; then
        $python_cmd "$SCRIPT_DIR/install.py" "$@"
    else
        print_error "Python installer not found!"
        print_info "Expected files: setup.py or install.py"
        exit 1
    fi
}

# Show help information
show_help() {
    cat << EOF
Simple Shell Environment - Hybrid Installer

USAGE:
    $0 [OPTIONS]

OPTIONS:
    -h, --help              Show this help message
    -c, --check-only        Only check system requirements
    -s, --skip-deps         Skip system dependency installation
    -f, --force             Force installation even if requirements not met
    --alternatives          Show alternative installation methods

DESCRIPTION:
    This hybrid installer combines shell scripts for platform detection
    and system preparation with Python for the main installation logic.
    
    Supported platforms:
    - WSL2 with Ubuntu
    - Native Linux (Ubuntu, Fedora)
    - macOS (with Homebrew)

    The installer will:
    - Detect your platform and install dependencies
    - Install Zsh, Oh My Zsh, and Powerlevel10k
    - Install recommended fonts for terminal use
    - Configure your shell environment with sensible defaults
    - Backup any existing configurations

EXAMPLES:
    $0                      # Run full installation
    $0 --check-only         # Just check if system is ready
    $0 --alternatives       # Show alternative methods

EOF
}

# Main installation function
main() {
    local check_only=false
    local skip_deps=false
    local force=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -c|--check-only)
                check_only=true
                shift
                ;;
            -s|--skip-deps)
                skip_deps=true
                shift
                ;;
            -f|--force)
                force=true
                shift
                ;;
            --alternatives)
                show_alternatives
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                print_info "Use --help for usage information"
                exit 1
                ;;
        esac
    done
    
    print_header "Simple Shell Environment - Hybrid Installer"
    
    # Show platform information
    show_platform_info
    
    # Check for existing installations
    if [ "$check_only" = false ]; then
        check_existing
    fi
    
    # Install system dependencies if not skipped
    if [ "$skip_deps" = false ]; then
        install_system_deps
    fi
    
    # Check Python
    if ! check_python; then
        if [ "$force" = true ]; then
            print_warning "Proceeding anyway due to --force flag"
        elif [ "$check_only" = true ]; then
            print_error "Python check failed"
            return 1
        else
            print_step "Attempting to install Python"
            install_python
            
            if ! check_python; then
                print_error "Failed to install Python"
                print_info "Please install Python 3.6+ manually"
                exit 1
            fi
        fi
    fi
    
    if [ "$check_only" = true ]; then
        print_success "All system requirements satisfied!"
        print_info "Run without --check-only to proceed with installation"
        return 0
    fi
    
    # Run the Python installer
    print_step "Transferring control to Python installer"
    run_python_installer "$@"
    
    # Final message
    print_header "Installation Complete!"
    print_success "Simple Shell Environment has been installed successfully"
    print_info "Start a new shell session or run: exec zsh"
}

# Run main function with all arguments
main "$@"