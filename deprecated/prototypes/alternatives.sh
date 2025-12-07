#!/bin/bash

# ===============================================================
# Simple Shell Environment - Alternative Installation Methods
# For environments without native Linux support
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

# Detect environment type
detect_environment() {
    if [ -f /proc/version ]; then
        if grep -qi microsoft /proc/version; then
            echo "wsl"
        elif [ -f /.dockerenv ]; then
            echo "docker"
        elif [ -n "$CODESPACES" ]; then
            echo "codespaces"
        elif [ -n "$GITPOD_WORKSPACE_ID" ]; then
            echo "gitpod"
        else
            echo "linux"
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

# Check if Docker is available and working
check_docker() {
    if ! command -v docker &> /dev/null; then
        return 1
    fi
    
    if ! docker info &> /dev/null; then
        return 1
    fi
    
    return 0
}

# Install using Docker container
install_via_docker() {
    print_header "Docker-based Installation"
    
    if ! check_docker; then
        print_error "Docker is not available or not running"
        print_info "Please install Docker and ensure it's running:"
        print_info "https://docs.docker.com/get-docker/"
        return 1
    fi
    
    local repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    local output_dir="/tmp/simple-shell-output"
    
    print_step "Creating temporary output directory"
    mkdir -p "$output_dir"
    
    print_step "Running installation in Docker container"
    
    # Create Dockerfile for installation
    cat > "$output_dir/Dockerfile" << 'EOF'
FROM ubuntu:20.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=UTC

# Install required packages
RUN apt-get update && apt-get install -y \
    zsh \
    git \
    curl \
    wget \
    python3 \
    python3-pip \
    fontconfig \
    locales \
    && rm -rf /var/lib/apt/lists/*

# Set up locale
RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8

# Create a non-root user
RUN useradd -m -s /bin/zsh shelluser
USER shelluser
WORKDIR /home/shelluser

# Copy installer files
COPY --chown=shelluser:shelluser . /home/shelluser/simple-shell/

# Run the installer
RUN cd simple-shell && python3 install.py --docker-mode

# Create export script
RUN echo '#!/bin/bash' > /tmp/export.sh && \
    echo 'cd /home/shelluser' >> /tmp/export.sh && \
    echo 'tar czf /tmp/shell-config.tar.gz .oh-my-zsh .zshrc .p10k.zsh .local/share/fonts 2>/dev/null || true' >> /tmp/export.sh && \
    chmod +x /tmp/export.sh

CMD ["/tmp/export.sh"]
EOF

    # Build and run Docker container
    print_step "Building Docker image"
    if ! docker build -t simple-shell-installer "$repo_dir" -f "$output_dir/Dockerfile"; then
        print_error "Failed to build Docker image"
        return 1
    fi
    
    print_step "Extracting configuration from container"
    if ! docker run --rm -v "$output_dir:/tmp/output" simple-shell-installer sh -c "cd /home/shelluser && tar czf /tmp/output/shell-config.tar.gz .oh-my-zsh .zshrc .p10k.zsh .local/share/fonts 2>/dev/null || true"; then
        print_error "Failed to extract configuration from container"
        return 1
    fi
    
    # Extract to user's home directory
    if [ -f "$output_dir/shell-config.tar.gz" ]; then
        print_step "Installing configuration to home directory"
        cd "$HOME"
        tar xzf "$output_dir/shell-config.tar.gz"
        print_success "Configuration extracted successfully"
    else
        print_error "Configuration archive not found"
        return 1
    fi
    
    # Clean up
    print_step "Cleaning up temporary files"
    rm -rf "$output_dir"
    docker rmi simple-shell-installer &>/dev/null || true
    
    print_success "Docker-based installation completed!"
    return 0
}

# Install in cloud environment (Codespaces, GitPod, etc.)
install_cloud_environment() {
    print_header "Cloud Environment Installation"
    
    print_info "Detected cloud development environment"
    print_warning "Some features may be limited in cloud environments"
    
    # Check if we can run the installer directly
    if [ -f "install.py" ]; then
        print_step "Running installer in cloud mode"
        python3 install.py --cloud-mode
        return $?
    elif [ -f "prototypes/python-installer/install.py" ]; then
        print_step "Running installer in cloud mode"
        cd prototypes/python-installer
        python3 install.py --cloud-mode
        return $?
    else
        print_step "Downloading installer from repository"
        
        # Try to download the installer
        local installer_url="https://raw.githubusercontent.com/Shanmeistro/simple-shell/main/prototypes/python-installer/install.py"
        
        if command -v curl &> /dev/null; then
            curl -fsSL "$installer_url" -o /tmp/simple-shell-install.py
        elif command -v wget &> /dev/null; then
            wget -q "$installer_url" -O /tmp/simple-shell-install.py
        else
            print_error "Neither curl nor wget available for download"
            return 1
        fi
        
        if [ -f /tmp/simple-shell-install.py ]; then
            python3 /tmp/simple-shell-install.py --cloud-mode
            rm -f /tmp/simple-shell-install.py
            return $?
        else
            print_error "Failed to download installer"
            return 1
        fi
    fi
}

# Set up WSL environment
setup_wsl_environment() {
    print_header "WSL Setup Instructions"
    
    cat << 'EOF'
To set up WSL2 with Ubuntu for running this installer:

1. Enable WSL feature (run in PowerShell as Administrator):
   dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart

2. Enable Virtual Machine Platform:
   dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

3. Restart your computer

4. Set WSL 2 as default version:
   wsl --set-default-version 2

5. Install Ubuntu from Microsoft Store or command line:
   wsl --install -d Ubuntu

6. After Ubuntu starts, update packages:
   sudo apt update && sudo apt upgrade -y

7. Install git and clone this repository:
   sudo apt install -y git
   git clone https://github.com/Shanmeistro/simple-shell.git
   cd simple-shell

8. Run the installer:
   ./install.sh

Alternative: Use Ubuntu 22.04 LTS:
   wsl --install -d Ubuntu-22.04

For more details, visit:
https://docs.microsoft.com/en-us/windows/wsl/install
EOF
    
    echo
    read -p "Have you completed the WSL setup? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        print_step "Great! You can now run the regular installer"
        if [ -f "install.sh" ]; then
            ./install.sh
        else
            print_info "Navigate to the repository directory and run: ./install.sh"
        fi
    else
        print_info "Complete the WSL setup first, then run this script again"
    fi
}

# Create portable configuration script
create_portable_installer() {
    print_header "Creating Portable Configuration"
    
    local script_name="portable-shell-setup.sh"
    
    cat > "$script_name" << 'EOF'
#!/bin/bash
# Portable Simple Shell Environment Setup
# Generated by alternative installer

set -e

# Basic configuration for Zsh + Oh My Zsh + P10k
setup_shell() {
    echo "Setting up portable shell environment..."
    
    # Install Oh My Zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    
    # Install Powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    
    # Install plugins
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
    
    # Create basic .zshrc
    cat > ~/.zshrc << 'ZSHRC'
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
plugins=(git zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# Basic aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'

export PATH="$HOME/.local/bin:$PATH"
ZSHRC
    
    echo "Portable shell setup completed!"
    echo "Start a new shell session or run: exec zsh"
    echo "Configure Powerlevel10k with: p10k configure"
}

# Download fonts
download_fonts() {
    echo "Downloading recommended fonts..."
    
    local font_dir
    if [[ "$OSTYPE" == "linux-gnu"* ]] || [[ "$OSTYPE" == "msys" ]]; then
        font_dir="$HOME/.local/share/fonts"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        font_dir="$HOME/Library/Fonts"
    else
        font_dir="$HOME/fonts"
    fi
    
    mkdir -p "$font_dir"
    
    local fonts=(
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf"
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf"
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf"
        "https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf"
    )
    
    for font in "${fonts[@]}"; do
        local filename=$(basename "$font" | sed 's/%20/ /g')
        if command -v curl &> /dev/null; then
            curl -fsSL "$font" -o "$font_dir/$filename"
        elif command -v wget &> /dev/null; then
            wget -q "$font" -O "$font_dir/$filename"
        fi
    done
    
    # Refresh font cache on Linux
    if command -v fc-cache &> /dev/null; then
        fc-cache -fv
    fi
    
    echo "Fonts downloaded to: $font_dir"
}

main() {
    echo "Portable Simple Shell Environment Setup"
    echo "========================================"
    
    setup_shell
    download_fonts
    
    echo
    echo "Setup completed! Restart your terminal and enjoy your new shell."
}

main "$@"
EOF

    chmod +x "$script_name"
    print_success "Created portable installer: $script_name"
    print_info "You can run this script on any system with zsh, git, and curl/wget"
    print_info "Usage: ./$script_name"
}

# Show manual installation instructions
show_manual_instructions() {
    print_header "Manual Installation Instructions"
    
    cat << 'EOF'
If automated installation fails, you can set up manually:

1. Install Zsh:
   Ubuntu/Debian: sudo apt install zsh
   CentOS/RHEL:   sudo yum install zsh
   macOS:         brew install zsh

2. Install Oh My Zsh:
   sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

3. Install Powerlevel10k theme:
   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

4. Install useful plugins:
   git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
   git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting

5. Update your .zshrc:
   ZSH_THEME="powerlevel10k/powerlevel10k"
   plugins=(git zsh-autosuggestions zsh-syntax-highlighting)

6. Download MesloLGS NF fonts from:
   https://github.com/romkatv/powerlevel10k#manual-font-installation

7. Set your terminal font to MesloLGS NF

8. Restart your shell and run: p10k configure

For detailed instructions, visit:
https://github.com/romkatv/powerlevel10k#installation
EOF
}

# Main function
main() {
    print_header "Simple Shell Environment - Alternative Installer"
    
    local env=$(detect_environment)
    print_info "Detected environment: $env"
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --docker)
                install_via_docker
                exit $?
                ;;
            --cloud)
                install_cloud_environment
                exit $?
                ;;
            --wsl-setup)
                setup_wsl_environment
                exit 0
                ;;
            --portable)
                create_portable_installer
                exit 0
                ;;
            --manual)
                show_manual_instructions
                exit 0
                ;;
            -h|--help)
                cat << 'EOF'
Alternative Installation Methods

USAGE:
    ./alternatives.sh [OPTION]

OPTIONS:
    --docker        Use Docker-based installation
    --cloud         Cloud environment installation
    --wsl-setup     Show WSL setup instructions
    --portable      Create portable installer script
    --manual        Show manual installation steps
    -h, --help      Show this help

Without options, automatically detects environment and suggests best method.
EOF
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                print_info "Use --help for available options"
                exit 1
                ;;
        esac
        shift
    done
    
    # Auto-detect and suggest installation method
    case "$env" in
        "wsl"|"linux"|"macos")
            print_success "Standard environment detected"
            print_info "You can use the regular installer: ./install.sh"
            ;;
        "docker")
            print_warning "Docker environment detected"
            print_info "Consider running with --cloud flag for cloud-optimized installation"
            ;;
        "codespaces"|"gitpod")
            print_info "Cloud development environment detected"
            print_info "Running cloud-optimized installation..."
            install_cloud_environment
            ;;
        *)
            print_warning "Unsupported or unknown environment"
            echo
            print_info "Available options:"
            echo "  --docker      Use Docker for isolated installation"
            echo "  --cloud       Install in cloud environment"
            echo "  --wsl-setup   Set up WSL2 (Windows users)"
            echo "  --portable    Create portable installer"
            echo "  --manual      Manual installation instructions"
            echo
            read -p "Which method would you like to use? (docker/cloud/wsl/portable/manual): " method
            
            case "$method" in
                docker) install_via_docker ;;
                cloud) install_cloud_environment ;;
                wsl) setup_wsl_environment ;;
                portable) create_portable_installer ;;
                manual) show_manual_instructions ;;
                *) print_error "Invalid choice" ;;
            esac
            ;;
    esac
}

# Run main function
main "$@"