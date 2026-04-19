print_header() {
    echo ""
    echo "=============================================="
    echo "  $1"
    echo "=============================================="
}

print_success() {
    echo "✅ $1"
}

print_warning() {
    echo "⚠️ $1"
}

print_error() {
    echo "❌ $1"
}

# Check if running on supported Linux distribution
check_linux_distro() {
    if [[ -f /etc/os-release ]]; then
        . /etc/os-release
        case $ID in
            ubuntu|debian|pop|linuxmint|kali|raspbian|elementary|zorin|parrot|mx)
                print_success "Detected supported distribution: $PRETTY_NAME"
                return 0
                ;;
            *)
                # Also accept distros derived from debian/ubuntu via ID_LIKE
                if [[ "$ID_LIKE" == *"debian"* || "$ID_LIKE" == *"ubuntu"* ]]; then
                    print_success "Detected Debian-based distribution: $PRETTY_NAME"
                    return 0
                fi
                print_warning "Distribution '$PRETTY_NAME' is not officially supported."
                print_warning "This setup targets Debian-based distributions (apt required)."
                read -p "Continue anyway? (y/N): " proceed
                [[ "$proceed" =~ ^[Yy]$ ]] || exit 1
                ;;
        esac
    else
        print_error "Cannot detect Linux distribution (/etc/os-release not found)"
        exit 1
    fi
}

# Prompt the user to choose an install action.
# Sets the global INSTALL_ACTION to: remove | update | reinstall | clean
# Default (Enter with no input) = clean install.
prompt_install_action() {
    local tool="$1"
    echo ""
    print_header "$tool — Choose Action"
    echo "  1) Remove only"
    echo "  2) Update existing installation"
    echo "  3) Reinstall (remove + clean install)"
    echo "  [Enter] Clean install (default — removes existing, installs fresh)"
    echo ""
    read -p "Choice [1/2/3 or Enter]: " _action_choice
    case "${_action_choice}" in
        1) INSTALL_ACTION="remove"    ;;
        2) INSTALL_ACTION="update"    ;;
        3) INSTALL_ACTION="reinstall" ;;
        *) INSTALL_ACTION="clean"     ;;
    esac
    echo ""
}

# Backup the user's current .bashrc with a timestamp
backup_bashrc() {
    local backup_dir="$HOME/.config/simple-shell/backups"
    mkdir -p "$backup_dir"
    if [ -f "$HOME/.bashrc" ]; then
        local backup_file="$backup_dir/.bashrc.$(date +%Y%m%d_%H%M%S).bak"
        cp "$HOME/.bashrc" "$backup_file"
        print_success "Existing .bashrc backed up to $backup_file"
    fi
}

# Update package lists
update_packages() {
    print_header "Updating Package Lists"
    sudo apt update -y
    print_success "Package lists updated"
}

# Upgrade system packages
upgrade_packages() {
    print_header "Upgrading System Packages"
    sudo apt upgrade -y
    print_success "System packages upgraded"
}