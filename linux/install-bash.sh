#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Enhanced Bash Environment"

# Install Bash-it framework
if [ ! -d "$HOME/.bash_it" ]; then
    print_header "Installing Bash-it Framework"
    git clone --depth=1 https://github.com/Bash-it/bash-it.git ~/.bash_it
    ~/.bash_it/install.sh --silent
else
    print_warning "Bash-it already installed, skipping..."
fi

# Install Starship prompt
if ! command -v starship &> /dev/null; then
    print_header "Installing Starship Prompt"
    curl -sS https://starship.rs/install.sh | sh -s -- -y
else
    print_warning "Starship already installed, skipping..."
fi

# Create enhanced .bashrc
print_header "Configuring Enhanced Bash"
cat > "$HOME/.bashrc" << 'EOF'
# Bash-it configuration
export BASH_IT="$HOME/.bash_it"
export BASH_IT_THEME='powerline'
export SCM_CHECK=true

# Load Bash-it
source "$BASH_IT"/bash_it.sh

# Starship prompt
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# User configuration
export EDITOR='vim'
export HISTSIZE=10000
export HISTFILESIZE=20000

# Aliases
alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
alias ..='cd ..'
alias ...='cd ../..'
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi
EOF

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

# Install useful Bash-it plugins and aliases
print_header "Enabling Bash-it Plugins"
bash-it enable plugin base dirs extract git history ssh
bash-it enable alias general git docker
bash-it enable completion bash-it git docker ssh system

print_success "Enhanced Bash Environment Installed Successfully!"
echo ""
echo "🎨 Next steps:"
echo "• Restart your terminal or run 'source ~/.bashrc'"
echo "• Explore Bash-it: 'bash-it help'"
echo "• Customize Starship: edit ~/.config/starship.toml"