#!/usr/bin/env bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

print_header() {
    echo -e "\n${BLUE}===================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================${NC}\n"
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

# Detect install type
detect_install_type() {
    if [ -f ~/.bashrc.backup ]; then
        echo "existing"
    else
        echo "fresh"
    fi
}

# Backup existing configurations
backup_existing_configs() {
    local backup_dir="$HOME/.config/bash-backup-$(date +%Y%m%d-%H%M%S)"
    
    print_header "Backing up existing bash configurations"
    
    local backed_up=()
    
    if [ -f ~/.bashrc ]; then
        mkdir -p "$backup_dir"
        cp ~/.bashrc "$backup_dir/" && backed_up+=(".bashrc")
    fi
    
    if [ -f ~/.bash_profile ]; then
        mkdir -p "$backup_dir"
        cp ~/.bash_profile "$backup_dir/" && backed_up+=(".bash_profile")
    fi
    
    if [ ${#backed_up[@]} -gt 0 ]; then
        print_success "Backup created at: $backup_dir"
        echo "Backed up: ${backed_up[*]}"
    else
        echo "No existing bash configurations found to backup"
    fi
}

# Install prerequisites
install_prerequisites() {
    print_header "Installing Bash Prerequisites"
    
    sudo apt update
    sudo apt install -y \
        bash \
        bash-completion \
        git \
        curl \
        wget \
        fontconfig \
        unzip
    
    print_success "Prerequisites installed"
}

# Install Nerd Font (FiraCode - universal choice)
install_nerd_font() {
    print_header "Installing FiraCode Nerd Font"
    
    local font_dir="$HOME/.local/share/fonts"
    mkdir -p "$font_dir"
    
    local font_url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip"
    local temp_zip="/tmp/FiraCode.zip"
    
    if [ ! -f "$font_dir/FiraCodeNerdFont-Regular.ttf" ]; then
        echo "Downloading FiraCode Nerd Font..."
        wget -q "$font_url" -O "$temp_zip"
        unzip -q "$temp_zip" -d "$font_dir"
        rm "$temp_zip"
        
        # Refresh font cache
        fc-cache -fv > /dev/null 2>&1
        
        print_success "FiraCode Nerd Font installed"
    else
        print_success "FiraCode Nerd Font already installed"
    fi
    
    print_warning "Set your terminal/IDE font to 'FiraCode Nerd Font' for icons to display"
}

# Prompt user to choose framework
choose_prompt_framework() {
    print_header "Choose Your Prompt Framework"
    echo "1) Starship (recommended - fast, cross-shell)"
    echo "2) Oh My Posh (colorful, Windows-friendly)"
    echo "3) None (simple default prompt)"
    echo ""
    read -p "Enter choice [1-3]: " choice
    
    case $choice in
        1) echo "starship" ;;
        2) echo "oh-my-posh" ;;
        3) echo "none" ;;
        *) echo "starship" ;; # Default to starship
    esac
}

# Install Starship
install_starship() {
    print_header "Installing Starship Prompt"
    
    if command -v starship >/dev/null 2>&1; then
        print_success "Starship already installed"
    else
        curl -sS https://starship.rs/install.sh | sh -s -- -y
        print_success "Starship installed"
    fi
}

# Install Oh My Posh
install_oh_my_posh() {
    print_header "Installing Oh My Posh"
    
    if command -v oh-my-posh >/dev/null 2>&1; then
        print_success "Oh My Posh already installed"
    else
        curl -s https://ohmyposh.dev/install.sh | bash -s
        print_success "Oh My Posh installed"
    fi
}

# Create Starship config (Nerd Font preset)
create_starship_config() {
    print_header "Creating Starship Configuration"
    
    mkdir -p ~/.config
    
    cat > ~/.config/starship.toml << 'EOF'
# Starship Nerd Font Preset
# Based on https://starship.rs/presets/nerd-font

format = """
[┌───────────────────>](bold green)
[│](bold green)$os$username$hostname$directory$git_branch$git_status$python$nodejs$docker_context
[└─>](bold green) """

[os]
disabled = false
format = '[$symbol](bold white) '

[os.symbols]
Windows = '󰍲'
Ubuntu = '󰕈'
Debian = '󰣚'
Arch = '󰣇'

[username]
show_always = true
format = '[$user]($style)@'
style_user = 'bold yellow'

[hostname]
ssh_only = false
format = '[$hostname]($style) '
style = 'bold green'

[directory]
truncation_length = 3
format = 'in [$path]($style)[$read_only]($read_only_style) '
style = 'bold cyan'
read_only = ' 󰌾'

[git_branch]
format = 'on [$symbol$branch]($style) '
symbol = ' '
style = 'bold purple'

[git_status]
format = '([\[$all_status$ahead_behind\]]($style)) '
style = 'bold red'
conflicted = '='
ahead = '⇡${count}'
behind = '⇣${count}'
diverged = '⇕⇡${ahead_count}⇣${behind_count}'
up_to_date = '✓'
untracked = '?${count}'
stashed = '$${count}'
modified = '!${count}'
staged = '+${count}'
renamed = '»${count}'
deleted = '✘${count}'

[python]
format = 'via [${symbol}${pyenv_prefix}(${version} )]($style)'
symbol = ' '
style = 'bold yellow'

[nodejs]
format = 'via [${symbol}(${version} )]($style)'
symbol = ' '
style = 'bold green'

[docker_context]
format = 'via [${symbol}${context}]($style) '
symbol = ' '
style = 'bold blue'

[cmd_duration]
min_time = 2_000
format = 'took [$duration]($style) '
style = 'bold yellow'

[character]
success_symbol = '[❯](bold green)'
error_symbol = '[❯](bold red)'
EOF
    
    print_success "Starship configuration created"
}

# Create Oh My Posh config (1_shell theme)
create_oh_my_posh_config() {
    print_header "Creating Oh My Posh Configuration"
    
    mkdir -p ~/.config/oh-my-posh
    
    # Download 1_shell theme
    wget -q https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/1_shell.omp.json \
        -O ~/.config/oh-my-posh/theme.json
    
    print_success "Oh My Posh configuration created (1_shell theme)"
}

# Create minimal .bashrc
create_bashrc_config() {
    local prompt_choice=$1
    
    print_header "Creating Minimal Bash Configuration"
    
    cat > ~/.bashrc << EOF
# ~/.bashrc - Minimal but powerful setup
# Generated by simple-shell installer

# If not running interactively, don't do anything
case \$- in
    *i*) ;;
      *) return;;
esac

# ----------------------------------------------------------------------
# Bash History Configuration
# ----------------------------------------------------------------------
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth:erasedups
shopt -s histappend
PROMPT_COMMAND="history -a; history -n"

# ----------------------------------------------------------------------
# Bash Options
# ----------------------------------------------------------------------
shopt -s checkwinsize  # Update window size after commands
shopt -s cdspell       # Auto-correct minor spelling errors in cd
shopt -s dirspell      # Auto-correct directory name spelling
shopt -s globstar      # Enable ** for recursive globbing

# ----------------------------------------------------------------------
# Completion System
# ----------------------------------------------------------------------
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Kubectl completion (if installed)
command -v kubectl &>/dev/null && source <(kubectl completion bash)

# ----------------------------------------------------------------------
# SSH Agent Configuration
# ----------------------------------------------------------------------
if [ -z "\$SSH_AUTH_SOCK" ]; then
    if pgrep -u "\$(whoami)" ssh-agent >/dev/null; then
        export SSH_AUTH_SOCK=\$(find /tmp/ssh-* -user "\$(whoami)" -name 'agent.*' 2>/dev/null | head -n 1)
        [ -z "\$SSH_AUTH_SOCK" ] && eval "\$(ssh-agent -s)"
    else
        eval "\$(ssh-agent -s)"
    fi
fi

# Add SSH keys silently
ssh-add -l >/dev/null 2>&1 || {
    [ -f ~/.ssh/id_rsa ] && ssh-add ~/.ssh/id_rsa &>/dev/null
    [ -f ~/.ssh/id_ed25519 ] && ssh-add ~/.ssh/id_ed25519 &>/dev/null
}

# ----------------------------------------------------------------------
# Aliases
# ----------------------------------------------------------------------
# System
alias ls='ls --color=auto'
alias ll='ls -alF'
alias la='ls -A'
alias grep='grep --color=auto'
alias update='sudo apt update && sudo apt upgrade -y'

# Git
alias ga='git add'
alias gc='git commit -m'
alias gp='git push'
alias gl='git pull'
alias gst='git status'
alias gco='git checkout'

# Docker
alias dcup='docker-compose up -d'
alias dcdown='docker-compose down'
alias dclogs='docker-compose logs -f'

# Kubernetes
alias k='kubectl'
alias kget='kubectl get'
alias klogs='kubectl logs -f'

# Navigation
alias work='cd ~/work'
alias personal='cd ~/personal'

# ----------------------------------------------------------------------
# NVM (Node Version Manager)
# ----------------------------------------------------------------------
export NVM_DIR="\$HOME/.nvm"
[ -s "\$NVM_DIR/nvm.sh" ] && \. "\$NVM_DIR/nvm.sh"
[ -s "\$NVM_DIR/bash_completion" ] && \. "\$NVM_DIR/bash_completion"

# ----------------------------------------------------------------------
# Prompt Configuration
# ----------------------------------------------------------------------
EOF

    # Add prompt configuration based on choice
    case $prompt_choice in
        starship)
            cat >> ~/.bashrc << 'EOF'
# Starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi
EOF
            ;;
        oh-my-posh)
            cat >> ~/.bashrc << 'EOF'
# Oh My Posh prompt
if command -v oh-my-posh &> /dev/null; then
    eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/theme.json)"
fi
EOF
            ;;
        none)
            cat >> ~/.bashrc << 'EOF'
# Simple custom prompt
PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
EOF
            ;;
    esac
    
    print_success "Minimal .bashrc created"
}

# Main installation flow
main() {
    local install_type=$(detect_install_type)
    
    print_header "Bash Environment Setup"
    echo "Installation type: $install_type"
    echo ""
    
    if [ "$install_type" = "existing" ]; then
        echo "Found existing bash configurations."
        read -p "Create backup before proceeding? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            backup_existing_configs
        fi
    fi
    
    # Core installation
    install_prerequisites
    install_nerd_font
    
    # Choose prompt framework
    local prompt_choice=$(choose_prompt_framework)
    
    case $prompt_choice in
        starship)
            install_starship
            create_starship_config
            ;;
        oh-my-posh)
            install_oh_my_posh
            create_oh_my_posh_config
            ;;
        none)
            print_success "Using default prompt"
            ;;
    esac
    
    create_bashrc_config "$prompt_choice"
    
    print_header "Bash Environment Setup Complete!"
    echo ""
    echo "🎉 Your minimal bash environment is ready!"
    echo ""
    echo "Installed:"
    echo "• FiraCode Nerd Font (universal)"
    case $prompt_choice in
        starship)
            echo "• Starship prompt (Nerd Font preset)"
            ;;
        oh-my-posh)
            echo "• Oh My Posh (1_shell theme)"
            ;;
        none)
            echo "• Simple default prompt"
            ;;
    esac
    echo ""
    echo "Next steps:"
    echo "1. Restart terminal or run: exec bash"
    echo "2. Set terminal font to 'FiraCode Nerd Font'"
    echo "3. Set IDE/editor font to 'FiraCode Nerd Font'"
    echo ""
    echo "Font configuration:"
    echo "• Windows Terminal: Settings → Font Face → 'FiraCode Nerd Font'"
    echo "• VS Code/Cursor/Windsurf: Settings → Font Family → 'FiraCode Nerd Font'"
    echo ""
    if [ "$prompt_choice" = "starship" ]; then
        echo "Customize: Edit ~/.config/starship.toml"
    elif [ "$prompt_choice" = "oh-my-posh" ]; then
        echo "Customize: Edit ~/.config/oh-my-posh/theme.json"
    fi
    echo ""
}

# Handle command line arguments
case "${1:-}" in
    --help|-h)
        echo "Bash Environment Installer"
        echo ""
        echo "Usage: $0 [options]"
        echo ""
        echo "Options:"
        echo "  --help, -h    Show this help"
        echo ""
        echo "This script installs:"
        echo "• Minimal bash configuration"
        echo "• FiraCode Nerd Font"
        echo "• Choice of Starship or Oh My Posh"
        echo "• Essential aliases and completions"
        echo ""
        exit 0
        ;;
esac

# Run main function
main "$@"