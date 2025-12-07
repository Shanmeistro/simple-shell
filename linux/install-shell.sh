#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Zsh Shell Environment"

# Install Zsh
sudo apt install -y zsh

# Install Oh My Zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    print_header "Installing Oh My Zsh"
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
else
    print_warning "Oh My Zsh already installed, skipping..."
fi

# Install Powerlevel10k theme
if [ ! -d "$HOME/.oh-my-zsh/custom/themes/powerlevel10k" ]; then
    print_header "Installing Powerlevel10k Theme"
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
else
    print_warning "Powerlevel10k already installed, skipping..."
fi

# Install useful Oh My Zsh plugins
print_header "Installing Oh My Zsh Plugins"

# zsh-autosuggestions
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
fi

# zsh-syntax-highlighting
if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
fi

# Create .zshrc configuration
print_header "Configuring Zsh"
cat > "$HOME/.zshrc" << 'EOF'
# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Theme
ZSH_THEME="powerlevel10k/powerlevel10k"

# Plugins
plugins=(
    git
    sudo
    docker
    kubectl
    node
    npm
    python
    pip
    zsh-autosuggestions
    zsh-syntax-highlighting
)

source $ZSH/oh-my-zsh.sh

# User configuration
export EDITOR='vim'

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
EOF

# Install Nerd Fonts for better terminal experience
print_header "Installing Nerd Fonts"
if [ ! -d "$HOME/.local/share/fonts" ]; then
    mkdir -p "$HOME/.local/share/fonts"
fi

# Download and install FiraCode Nerd Font
if [ ! -f "$HOME/.local/share/fonts/FiraCodeNerdFont-Regular.ttf" ]; then
    wget -O /tmp/FiraCode.zip "https://github.com/ryanoasis/nerd-fonts/releases/download/v3.1.1/FiraCode.zip"
    unzip -o /tmp/FiraCode.zip -d "$HOME/.local/share/fonts/"
    fc-cache -f -v
    rm /tmp/FiraCode.zip
    print_success "FiraCode Nerd Font installed"
else
    print_warning "FiraCode Nerd Font already installed"
fi

# Change default shell to zsh
print_header "Setting Zsh as Default Shell"
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
    print_success "Default shell changed to Zsh"
    print_warning "Please log out and log back in for the shell change to take effect"
else
    print_success "Zsh is already the default shell"
fi

print_success "Zsh Shell Environment Installed Successfully!"
echo ""
echo "🎨 Next steps:"
echo "• Restart your terminal or run 'zsh'"
echo "• Run 'p10k configure' to customize your prompt"
echo "• Set your terminal font to 'FiraCode Nerd Font' for best experience"