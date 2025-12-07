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
            ubuntu|debian|pop|linuxmint)
                print_success "Detected supported distribution: $PRETTY_NAME"
                return 0
                ;;
            *)
                print_warning "Distribution $PRETTY_NAME may have limited support"
                print_warning "This script is optimized for Debian-based distributions"
                return 1
                ;;
        esac
    else
        print_error "Cannot detect Linux distribution"
        return 1
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