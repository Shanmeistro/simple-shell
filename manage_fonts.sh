#!/bin/bash

# Nerd Fonts Management Script
# Supports installation and removal on Linux, macOS, and Windows (WSL/Git Bash)
# Can be run standalone or integrated with Ansible

set -e

# Script metadata
SCRIPT_VERSION="1.0.0"
SCRIPT_NAME="Nerd Fonts Manager"

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
NC='\033[0m' # No Color

# Configuration
FONT_SOURCE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/nerd_fonts"
BACKUP_DIR="$HOME/.local/share/nerd-fonts-backup"
LOG_FILE="/tmp/nerd-fonts-manager.log"

# Global variables
OS=""
DISTRO=""
FONT_DIR=""
ANSIBLE_MODE=false

# Helper functions
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    if [[ "$ANSIBLE_MODE" == "false" ]]; then
        echo -e "$1"
    fi
}

print_header() {
    if [[ "$ANSIBLE_MODE" == "false" ]]; then
        clear
        echo -e "${CYAN}╔════════════════════════════════════════════════════════════════╗${NC}"
        echo -e "${CYAN}║                    $SCRIPT_NAME v$SCRIPT_VERSION                    ║${NC}"
        echo -e "${CYAN}╚════════════════════════════════════════════════════════════════╝${NC}"
        echo
    fi
}

print_success() {
    log "${GREEN}✓ $1${NC}"
}

print_error() {
    log "${RED}✗ $1${NC}"
}

print_warning() {
    log "${YELLOW}⚠ $1${NC}"
}

print_info() {
    log "${BLUE}ℹ $1${NC}"
}

# Detect OS and distribution
detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [[ -f /etc/os-release ]]; then
            . /etc/os-release
            OS="linux"
            DISTRO=$ID
        else
            OS="linux"
            DISTRO="unknown"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="macos"
        DISTRO="macos"
    elif [[ "$OSTYPE" == "cygwin" || "$OSTYPE" == "msys" ]]; then
        OS="windows"
        DISTRO="windows"
    else
        OS="unknown"
        DISTRO="unknown"
    fi
}

# Check if running in WSL
is_wsl() {
    [[ -n "${WSL_DISTRO_NAME:-}" ]] || [[ -n "${WSLENV:-}" ]] || [[ -f /proc/version ]] && grep -qi microsoft /proc/version
}

# Set font directory based on OS
set_font_directory() {
    case "$OS" in
        "macos")
            FONT_DIR="$HOME/Library/Fonts"
            ;;
        "linux")
            if is_wsl; then
                # For WSL, install in both Linux and Windows locations
                FONT_DIR="$HOME/.local/share/fonts"
                WINDOWS_FONT_DIR="/mnt/c/Windows/Fonts"
            else
                FONT_DIR="$HOME/.local/share/fonts"
            fi
            ;;
        "windows")
            FONT_DIR="$HOME/AppData/Local/Microsoft/Windows/Fonts"
            ;;
        *)
            print_error "Unsupported operating system: $OS"
            exit 1
            ;;
    esac
    
    mkdir -p "$FONT_DIR"
    print_info "Font directory: $FONT_DIR"
}

# Get available font families
get_available_fonts() {
    local fonts=()
    if [[ -d "$FONT_SOURCE_DIR" ]]; then
        for font_dir in "$FONT_SOURCE_DIR"/*; do
            if [[ -d "$font_dir" ]]; then
                fonts+=("$(basename "$font_dir")")
            fi
        done
    fi
    echo "${fonts[@]}"
}

# Get installed font families
get_installed_fonts() {
    local installed=()
    if [[ -d "$FONT_DIR" ]]; then
        for font_dir in "$FONT_DIR"/*; do
            if [[ -d "$font_dir" ]]; then
                local basename_dir=$(basename "$font_dir")
                # Check if this looks like a nerd font directory
                if [[ "$basename_dir" != "." && "$basename_dir" != ".." ]]; then
                    installed+=("$basename_dir")
                fi
            fi
        done
    fi
    echo "${installed[@]}"
}

# Show font menu for interactive mode
show_font_menu() {
    local action="$1"
    local available_fonts=($(get_available_fonts))
    local installed_fonts=($(get_installed_fonts))
    
    echo
    echo -e "${CYAN}╔══════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                        Font ${action^} Menu                      ║${NC}"
    echo -e "${CYAN}╚══════════════════════════════════════════════════════════════════╝${NC}"
    echo
    
    case "$action" in
        "install")
            if [[ ${#available_fonts[@]} -eq 0 ]]; then
                print_error "No fonts found in $FONT_SOURCE_DIR"
                return 1
            fi
            
            echo -e "${GREEN}Available fonts for installation:${NC}"
            for i in "${!available_fonts[@]}"; do
                local font="${available_fonts[$i]}"
                local status=""
                if [[ " ${installed_fonts[*]} " =~ " ${font} " ]]; then
                    status=" ${YELLOW}(already installed)${NC}"
                fi
                echo -e "  ${WHITE}$((i+1)).${NC} ${CYAN}$font${NC}$status"
            done
            ;;
        "uninstall")
            if [[ ${#installed_fonts[@]} -eq 0 ]]; then
                print_warning "No Nerd Fonts currently installed"
                return 1
            fi
            
            echo -e "${RED}Installed fonts available for removal:${NC}"
            for i in "${!installed_fonts[@]}"; do
                echo -e "  ${WHITE}$((i+1)).${NC} ${YELLOW}${installed_fonts[$i]}${NC}"
            done
            ;;
    esac
    
    echo
    local total_fonts=$([[ "$action" == "install" ]] && echo ${#available_fonts[@]} || echo ${#installed_fonts[@]})
    echo -e "${BLUE}Bulk options:${NC}"
    echo -e "  ${WHITE}$((total_fonts + 1)).${NC} ${action^} all fonts"
    echo -e "  ${WHITE}$((total_fonts + 2)).${NC} Select multiple fonts"
    echo -e "  ${WHITE}$((total_fonts + 3)).${NC} Cancel"
    echo
}

# Install font family
install_font_family() {
    local font_family="$1"
    local source_dir="$FONT_SOURCE_DIR/$font_family"
    local target_dir="$FONT_DIR/$font_family"
    
    if [[ ! -d "$source_dir" ]]; then
        print_error "Font family $font_family not found in $source_dir"
        return 1
    fi
    
    print_info "Installing $font_family fonts..."
    
    # Create backup if fonts already exist
    if [[ -d "$target_dir" ]]; then
        backup_font_family "$font_family"
    fi
    
    mkdir -p "$target_dir"
    
    # Copy font files
    local font_count=0
    local font_types=()
    
    for font_file in "$source_dir"/*.{ttf,otf,TTF,OTF}; do
        if [[ -f "$font_file" ]]; then
            cp "$font_file" "$target_dir/"
            ((font_count++))
            
            # Track font variants
            local filename=$(basename "$font_file")
            case "$filename" in
                *"Mono"*) [[ ! " ${font_types[*]} " =~ " Mono " ]] && font_types+=("Mono") ;;
                *"Propo"*) [[ ! " ${font_types[*]} " =~ " Proportional " ]] && font_types+=("Proportional") ;;
                *) [[ ! " ${font_types[*]} " =~ " Regular " ]] && font_types+=("Regular") ;;
            esac
        fi
    done
    
    if [[ $font_count -eq 0 ]]; then
        print_warning "No font files found in $source_dir"
        rmdir "$target_dir" 2>/dev/null || true
        return 1
    else
        print_success "Installed $font_count files for $font_family"
        if [[ ${#font_types[@]} -gt 0 ]]; then
            print_info "Variants: ${font_types[*]}"
        fi
        
        # Install to Windows fonts directory if in WSL
        if is_wsl && [[ -d "$WINDOWS_FONT_DIR" ]]; then
            install_wsl_windows_fonts "$font_family" "$source_dir"
        fi
    fi
}

# Install fonts to Windows directory in WSL
install_wsl_windows_fonts() {
    local font_family="$1"
    local source_dir="$2"
    
    print_info "Installing $font_family to Windows fonts directory..."
    
    # Check if we have permission to write to Windows fonts
    if [[ -w "$WINDOWS_FONT_DIR" ]]; then
        for font_file in "$source_dir"/*.{ttf,otf,TTF,OTF}; do
            if [[ -f "$font_file" ]]; then
                cp "$font_file" "$WINDOWS_FONT_DIR/" 2>/dev/null || true
            fi
        done
        print_success "Fonts also installed to Windows"
    else
        print_warning "Cannot write to Windows fonts directory. Run as administrator for system-wide installation."
    fi
}

# Backup font family
backup_font_family() {
    local font_family="$1"
    local source_dir="$FONT_DIR/$font_family"
    local backup_target="$BACKUP_DIR/$font_family-$(date +%Y%m%d-%H%M%S)"
    
    if [[ -d "$source_dir" ]]; then
        mkdir -p "$BACKUP_DIR"
        cp -r "$source_dir" "$backup_target"
        print_info "Backed up existing $font_family to $backup_target"
    fi
}

# Uninstall font family
uninstall_font_family() {
    local font_family="$1"
    local target_dir="$FONT_DIR/$font_family"
    
    if [[ ! -d "$target_dir" ]]; then
        print_warning "Font family $font_family is not installed"
        return 1
    fi
    
    print_info "Uninstalling $font_family fonts..."
    
    # Create backup before removal
    backup_font_family "$font_family"
    
    # Remove font directory
    rm -rf "$target_dir"
    
    # Remove from Windows fonts if in WSL
    if is_wsl && [[ -d "$WINDOWS_FONT_DIR" ]]; then
        uninstall_wsl_windows_fonts "$font_family"
    fi
    
    print_success "Uninstalled $font_family"
}

# Remove fonts from Windows directory in WSL
uninstall_wsl_windows_fonts() {
    local font_family="$1"
    
    print_info "Removing $font_family from Windows fonts directory..."
    
    # This is tricky because we need to identify which files belong to this font family
    # We'll look for files that match common patterns
    local removed_count=0
    
    if [[ -w "$WINDOWS_FONT_DIR" ]]; then
        # Convert font family name to common patterns
        local patterns=("$font_family" "${font_family}Nerd" "${font_family// /}")
        
        for pattern in "${patterns[@]}"; do
            for font_file in "$WINDOWS_FONT_DIR"/*"$pattern"*.{ttf,otf,TTF,OTF}; do
                if [[ -f "$font_file" ]]; then
                    rm -f "$font_file" 2>/dev/null && ((removed_count++))
                fi
            done
        done
        
        if [[ $removed_count -gt 0 ]]; then
            print_success "Removed $removed_count font files from Windows"
        fi
    fi
}

# Refresh font cache
refresh_font_cache() {
    print_info "Refreshing font cache..."
    
    case "$OS" in
        "linux")
            if command -v fc-cache &> /dev/null; then
                fc-cache -fv >/dev/null 2>&1
                print_success "Font cache refreshed"
            else
                print_warning "fc-cache not available"
            fi
            ;;
        "macos")
            # macOS automatically manages font cache
            print_info "macOS will automatically refresh font cache"
            ;;
        "windows")
            print_info "Windows will automatically refresh font cache"
            ;;
    esac
}

# Interactive installation
interactive_install() {
    local available_fonts=($(get_available_fonts))
    
    if [[ ${#available_fonts[@]} -eq 0 ]]; then
        print_error "No fonts available for installation"
        return 1
    fi
    
    show_font_menu "install"
    
    read -p "Select option: " choice
    
    local total_fonts=${#available_fonts[@]}
    
    case $choice in
        $((total_fonts + 3)))
            print_info "Installation cancelled"
            return 0
            ;;
        $((total_fonts + 1)))
            print_info "Installing all available fonts..."
            for font in "${available_fonts[@]}"; do
                install_font_family "$font"
            done
            ;;
        $((total_fonts + 2)))
            select_multiple_fonts "install" "${available_fonts[@]}"
            ;;
        *)
            if [[ $choice -ge 1 && $choice -le $total_fonts ]]; then
                local selected_font="${available_fonts[$((choice-1))]}"
                install_font_family "$selected_font"
            else
                print_error "Invalid selection"
                return 1
            fi
            ;;
    esac
    
    refresh_font_cache
}

# Interactive uninstallation
interactive_uninstall() {
    local installed_fonts=($(get_installed_fonts))
    
    if [[ ${#installed_fonts[@]} -eq 0 ]]; then
        print_warning "No fonts installed"
        return 1
    fi
    
    show_font_menu "uninstall"
    
    read -p "Select option: " choice
    
    local total_fonts=${#installed_fonts[@]}
    
    case $choice in
        $((total_fonts + 3)))
            print_info "Uninstallation cancelled"
            return 0
            ;;
        $((total_fonts + 1)))
            echo -e "${RED}This will remove ALL installed Nerd Fonts!${NC}"
            read -p "Are you sure? (y/N): " confirm
            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                for font in "${installed_fonts[@]}"; do
                    uninstall_font_family "$font"
                done
            else
                print_info "Uninstallation cancelled"
            fi
            ;;
        $((total_fonts + 2)))
            select_multiple_fonts "uninstall" "${installed_fonts[@]}"
            ;;
        *)
            if [[ $choice -ge 1 && $choice -le $total_fonts ]]; then
                local selected_font="${installed_fonts[$((choice-1))]}"
                echo -e "${YELLOW}Remove $selected_font?${NC}"
                read -p "Confirm (y/N): " confirm
                if [[ "$confirm" =~ ^[Yy]$ ]]; then
                    uninstall_font_family "$selected_font"
                else
                    print_info "Skipped $selected_font"
                fi
            else
                print_error "Invalid selection"
                return 1
            fi
            ;;
    esac
    
    refresh_font_cache
}

# Select multiple fonts
select_multiple_fonts() {
    local action="$1"
    shift
    local fonts=("$@")
    local selected_fonts=()
    
    echo
    echo -e "${CYAN}Multiple Font Selection Mode${NC}"
    echo -e "${WHITE}Enter font numbers separated by spaces (e.g., 1 2 3)${NC}"
    echo
    
    read -p "Enter your selections: " -a selections
    
    for selection in "${selections[@]}"; do
        if [[ $selection =~ ^[0-9]+$ ]] && [[ $selection -ge 1 && $selection -le ${#fonts[@]} ]]; then
            selected_fonts+=("${fonts[$((selection-1))]}")
        else
            print_warning "Invalid selection: $selection (skipped)"
        fi
    done
    
    if [[ ${#selected_fonts[@]} -eq 0 ]]; then
        print_error "No valid fonts selected"
        return 1
    fi
    
    echo
    print_info "${action^}ing selected fonts: ${selected_fonts[*]}"
    
    if [[ "$action" == "uninstall" ]]; then
        read -p "Confirm removal of these fonts? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            print_info "Operation cancelled"
            return 0
        fi
    fi
    
    for font in "${selected_fonts[@]}"; do
        if [[ "$action" == "install" ]]; then
            install_font_family "$font"
        else
            uninstall_font_family "$font"
        fi
    done
}

# List fonts
list_fonts() {
    local available_fonts=($(get_available_fonts))
    local installed_fonts=($(get_installed_fonts))
    
    echo
    echo -e "${CYAN}Font Status Report${NC}"
    echo -e "${CYAN}==================${NC}"
    echo
    
    echo -e "${GREEN}Available fonts in repository:${NC}"
    if [[ ${#available_fonts[@]} -eq 0 ]]; then
        echo -e "  ${GRAY}None found${NC}"
    else
        for font in "${available_fonts[@]}"; do
            local status=""
            if [[ " ${installed_fonts[*]} " =~ " ${font} " ]]; then
                status=" ${GREEN}[INSTALLED]${NC}"
            else
                status=" ${GRAY}[NOT INSTALLED]${NC}"
            fi
            echo -e "  • ${CYAN}$font${NC}$status"
        done
    fi
    
    echo
    echo -e "${YELLOW}Currently installed:${NC}"
    if [[ ${#installed_fonts[@]} -eq 0 ]]; then
        echo -e "  ${GRAY}None installed${NC}"
    else
        for font in "${installed_fonts[@]}"; do
            local file_count=$(find "$FONT_DIR/$font" -name "*.ttf" -o -name "*.otf" 2>/dev/null | wc -l)
            echo -e "  • ${YELLOW}$font${NC} ${GRAY}($file_count files)${NC}"
        done
    fi
    
    echo
}

# Show usage information
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] [COMMAND] [FONTS...]

COMMANDS:
    install [fonts...]    Install specified fonts (interactive if none specified)
    uninstall [fonts...]  Uninstall specified fonts (interactive if none specified)
    list                  List available and installed fonts
    status               Show font status and system information

OPTIONS:
    -h, --help           Show this help message
    -v, --version        Show version information
    -q, --quiet          Quiet mode (minimal output)
    --ansible            Ansible mode (JSON output, no colors)
    --font-dir DIR       Override default font directory

EXAMPLES:
    $0                          # Interactive mode
    $0 install                  # Interactive font installation
    $0 install CascadiaCode     # Install specific font
    $0 install all              # Install all available fonts
    $0 uninstall FiraCode       # Uninstall specific font
    $0 list                     # List all fonts
    $0 --ansible install all   # Ansible-friendly installation

FONT DIRECTORIES:
    Linux:   ~/.local/share/fonts/
    macOS:   ~/Library/Fonts/
    Windows: ~/AppData/Local/Microsoft/Windows/Fonts/
    WSL:     Both Linux and Windows directories

EOF
}

# Main menu for interactive mode
show_main_menu() {
    while true; do
        print_header
        
        echo -e "${WHITE}Font Management Options:${NC}"
        echo
        echo "  1. Install fonts"
        echo "  2. Uninstall fonts"
        echo "  3. List fonts"
        echo "  4. Show status"
        echo "  5. Exit"
        echo
        
        read -p "Select option (1-5): " choice
        
        case $choice in
            1) interactive_install ;;
            2) interactive_uninstall ;;
            3) list_fonts ;;
            4) show_status ;;
            5) 
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please try again."
                sleep 2
                ;;
        esac
        
        if [[ "$choice" != "5" ]]; then
            echo
            read -p "Press Enter to continue..."
        fi
    done
}

# Show system status
show_status() {
    echo
    echo -e "${CYAN}System Information${NC}"
    echo -e "${CYAN}==================${NC}"
    echo -e "OS: $OS"
    echo -e "Distribution: $DISTRO"
    echo -e "WSL: $(is_wsl && echo "Yes" || echo "No")"
    echo -e "Font Directory: $FONT_DIR"
    echo -e "Source Directory: $FONT_SOURCE_DIR"
    
    local available_count=$(get_available_fonts | wc -w)
    local installed_count=$(get_installed_fonts | wc -w)
    
    echo -e "Available Fonts: $available_count"
    echo -e "Installed Fonts: $installed_count"
    echo -e "Font Cache: $(command -v fc-cache &>/dev/null && echo "Available" || echo "Not available")"
    
    list_fonts
}

# Parse command line arguments
parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -v|--version)
                echo "$SCRIPT_NAME v$SCRIPT_VERSION"
                exit 0
                ;;
            -q|--quiet)
                exec > /dev/null
                shift
                ;;
            --ansible)
                ANSIBLE_MODE=true
                shift
                ;;
            --font-dir)
                FONT_DIR="$2"
                shift 2
                ;;
            install)
                shift
                if [[ $# -eq 0 ]]; then
                    interactive_install
                elif [[ "$1" == "all" ]]; then
                    local fonts=($(get_available_fonts))
                    for font in "${fonts[@]}"; do
                        install_font_family "$font"
                    done
                    refresh_font_cache
                else
                    while [[ $# -gt 0 ]]; do
                        install_font_family "$1"
                        shift
                    done
                    refresh_font_cache
                fi
                exit 0
                ;;
            uninstall)
                shift
                if [[ $# -eq 0 ]]; then
                    interactive_uninstall
                elif [[ "$1" == "all" ]]; then
                    local fonts=($(get_installed_fonts))
                    for font in "${fonts[@]}"; do
                        uninstall_font_family "$font"
                    done
                    refresh_font_cache
                else
                    while [[ $# -gt 0 ]]; do
                        uninstall_font_family "$1"
                        shift
                    done
                    refresh_font_cache
                fi
                exit 0
                ;;
            list)
                list_fonts
                exit 0
                ;;
            status)
                show_status
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    # Initialize log
    echo "=== Nerd Fonts Manager Session Started ===" > "$LOG_FILE"
    
    detect_os
    
    # Set font directory if not overridden
    if [[ -z "$FONT_DIR" ]]; then
        set_font_directory
    fi
    
    # Check if font source directory exists
    if [[ ! -d "$FONT_SOURCE_DIR" ]]; then
        print_error "Font source directory not found: $FONT_SOURCE_DIR"
        exit 1
    fi
    
    # Parse command line arguments
    if [[ $# -gt 0 ]]; then
        parse_arguments "$@"
    else
        # Interactive mode
        show_main_menu
    fi
}

# Run main function
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi