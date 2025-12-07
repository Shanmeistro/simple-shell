#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Enhanced Zsh Environment for macOS"

# Install Zsh (if not already installed)
if ! command -v zsh &> /dev/null; then
    brew_install zsh
fi

# Make Zsh the default shell
if [[ "$SHELL" != */zsh ]]; then
    print_header "Setting Zsh as Default Shell"
    if ! grep -q $(which zsh) /etc/shells; then
        echo $(which zsh) | sudo tee -a /etc/shells
    fi
    chsh -s $(which zsh)
fi

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_header "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    print_warning "Oh My Zsh already installed, updating..."
    omz update
fi

# Install Powerlevel10k theme
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    print_header "Installing Powerlevel10k Theme"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    print_warning "Powerlevel10k already installed"
fi

# Install useful Zsh plugins
print_header "Installing Zsh Plugins"
ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

# zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
fi

# zsh-completions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-completions" ]; then
    git clone https://github.com/zsh-users/zsh-completions $ZSH_CUSTOM/plugins/zsh-completions
fi

# Install Nerd Fonts for better terminal experience
print_header "Installing Nerd Fonts"
brew tap homebrew/cask-fonts
brew_cask_install font-fira-code-nerd-font
brew_cask_install font-hack-nerd-font
brew_cask_install font-jetbrains-mono-nerd-font
brew_cask_install font-meslo-lg-nerd-font
brew_cask_install font-ubuntu-mono-nerd-font

# Create enhanced .zshrc
print_header "Configuring Enhanced Zsh"
cat > "$HOME/.zshrc" << 'EOF'
# Oh My Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    docker
    kubectl
    npm
    yarn
    pip
    brew
    vscode
    zsh-autosuggestions
    zsh-syntax-highlighting
    zsh-completions
    fzf
)

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='vim'
export HISTSIZE=10000
export SAVEHIST=10000
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS

# Aliases
alias ll='exa -la --icons'
alias la='exa -a --icons'
alias l='exa -l --icons'
alias ls='exa --icons'
alias tree='exa --tree --icons'
alias cat='bat'
alias find='fd'
alias grep='rg'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'

# macOS specific aliases
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# Homebrew environment
if [[ $(uname -m) == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/usr/local/bin/brew shellenv)"
fi

# fzf integration
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# Load completions
autoload -U compinit && compinit

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# Install Starship as an alternative prompt
print_header "Installing Starship Prompt (Alternative)"
brew_install starship

# Create Starship configuration
print_header "Configuring Starship Prompt"
mkdir -p "$HOME/.config"
cat > "$HOME/.config/starship.toml" << 'EOF'
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status\
$nodejs\
$python\
$golang\
$rust\
$docker_context\
$kubernetes\
$line_break\
$character"""

[character]
success_symbol = "[➜](bold green)"
error_symbol = "[➜](bold red)"

[directory]
truncation_length = 3
truncate_to_repo = false

[git_branch]
symbol = "🌱 "

[nodejs]
symbol = "⬢ "

[python]
symbol = "🐍 "

[golang]
symbol = "🐹 "

[rust]
symbol = "🦀 "

[docker_context]
symbol = "🐳 "
EOF

print_success "Enhanced Zsh Environment Installed Successfully!"
echo ""
echo "🎨 Features installed:"
echo "• Oh My Zsh with Powerlevel10k theme"
echo "• Useful plugins (autosuggestions, syntax highlighting, completions)"
echo "• Nerd Fonts for better icons and symbols"
echo "• Modern CLI tools (exa, bat, ripgrep, fd)"
echo "• Starship prompt (alternative to Powerlevel10k)"
echo ""
echo "💡 Next steps:"
echo "• Restart your terminal or run 'source ~/.zshrc'"
echo "• Run 'p10k configure' to customize Powerlevel10k"
echo "• Or add 'eval \"\$(starship init zsh)\"' to ~/.zshrc for Starship"
echo "• Install a Nerd Font in your terminal for best experience"