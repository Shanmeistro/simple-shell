#!/usr/bin/env bash

# Color definitions for output
COLOR_RESET='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_MAGENTA='\033[0;35m'
COLOR_CYAN='\033[0;36m'
COLOR_WHITE='\033[0;37m'

# Print functions
print_header() {
    echo -e "${COLOR_CYAN}\n▶ $1${COLOR_RESET}"
}

print_success() {
    echo -e "${COLOR_GREEN}✓ $1${COLOR_RESET}"
}

print_warning() {
    echo -e "${COLOR_YELLOW}⚠ $1${COLOR_RESET}"
}

print_error() {
    echo -e "${COLOR_RED}✗ $1${COLOR_RESET}" >&2
}

print_info() {
    echo -e "${COLOR_BLUE}ℹ $1${COLOR_RESET}"
}

# macOS version detection
get_macos_version() {
    sw_vers -productVersion | cut -d '.' -f 1,2
}

get_macos_major_version() {
    sw_vers -productVersion | cut -d '.' -f 1
}

is_supported_macos() {
    local major_version=$(get_macos_major_version)
    # Support macOS 11-15 (Big Sur through current)
    if [[ $major_version -ge 11 && $major_version -le 15 ]]; then
        return 0
    else
        return 1
    fi
}

# Homebrew functions
install_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_header "Installing Homebrew"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
    else
        print_warning "Homebrew already installed"
    fi
}

brew_install() {
    local package=$1
    if ! brew list "$package" &> /dev/null; then
        print_info "Installing $package via Homebrew"
        brew install "$package"
    else
        print_warning "$package already installed"
    fi
}

brew_cask_install() {
    local cask=$1
    if ! brew list --cask "$cask" &> /dev/null; then
        print_info "Installing $cask via Homebrew Cask"
        brew install --cask "$cask"
    else
        print_warning "$cask already installed"
    fi
}

# Xcode Command Line Tools
install_xcode_clt() {
    if ! xcode-select -p &> /dev/null; then
        print_header "Installing Xcode Command Line Tools"
        xcode-select --install
        print_info "Please complete the Xcode Command Line Tools installation and re-run this script"
        exit 1
    else
        print_warning "Xcode Command Line Tools already installed"
    fi
}