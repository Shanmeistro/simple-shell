#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Enhanced Bash Environment for macOS"

# Install latest Bash (macOS comes with old version)
print_header "Installing Latest Bash"
brew_install bash
brew_install bash-completion@2

# Add new Bash to /etc/shells and set as default
NEW_BASH=$(brew --prefix)/bin/bash
if ! grep -q "$NEW_BASH" /etc/shells; then
    echo "$NEW_BASH" | sudo tee -a /etc/shells
fi

echo "Would you like to set the latest Bash as your default shell? (y/n)"
read -r response
if [[ "$response" =~ ^[Yy]$ ]]; then
    chsh -s "$NEW_BASH"
    print_success "Default shell set to latest Bash"
fi

# Install Bash-it framework
if [ ! -d "$HOME/.bash_it" ]; then
    print_header "Installing Bash-it Framework"
    git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
    ~/.bash_it/install.sh --silent
else
    print_warning "Bash-it already installed, skipping..."
fi

# Install Starship prompt
brew_install starship

# Create enhanced .bash_profile
print_header "Configuring Enhanced Bash"
cat > "$HOME/.bash_profile" << 'EOF'
# Homebrew environment
if [[ $(uname -m) == "arm64" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    eval "$(/usr/local/bin/brew shellenv)"
fi

# Bash-it configuration
export BASH_IT="$HOME/.bash_it"
export BASH_IT_THEME='powerline'
export SCM_CHECK=true

# Load Bash-it
source "$BASH_IT"/bash_it.sh

# Bash completion
[[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && . "$(brew --prefix)/etc/profile.d/bash_completion.sh"

# Starship prompt
eval "$(starship init bash)"

# User configuration
export EDITOR='vim'
export HISTSIZE=10000
export HISTFILESIZE=20000
export HISTCONTROL=ignoreboth
shopt -s histappend

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

# fzf integration
[ -f ~/.fzf.bash ] && source ~/.fzf.bash
EOF

# Create .bashrc that sources .bash_profile (for compatibility)
cat > "$HOME/.bashrc" << 'EOF'
# Source .bash_profile for interactive shells
if [ -f ~/.bash_profile ]; then
    source ~/.bash_profile
fi
EOF

# Enable useful Bash-it plugins
print_header "Enabling Bash-it Plugins"
bash-it enable plugin base dirs extract git history ssh brew osx
bash-it enable alias general git docker homebrew osx
bash-it enable completion bash-it git docker ssh system brew

print_success "Enhanced Bash Environment Installed Successfully!"
echo ""
echo "🎨 Features installed:"
echo "• Latest Bash $(bash --version | head -1)"
echo "• Bash-it framework with useful plugins"
echo "• Starship prompt for modern shell experience"
echo "• Enhanced bash completion"
echo "• Modern CLI tools integration"
echo ""
echo "💡 Next steps:"
echo "• Restart your terminal or run 'source ~/.bash_profile'"
echo "• Explore Bash-it: 'bash-it help'"
echo "• Customize Starship: edit ~/.config/starship.toml"
echo "• Install Nerd Fonts in your terminal for best experience"