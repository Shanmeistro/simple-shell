# ~/.bashrc - Minimal but powerful setup

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
[[ $commands[kubectl] ]] && source <(kubectl completion bash)

# ----------------------------------------------------------------------
# SSH Agent Configuration
# ----------------------------------------------------------------------
if [ -z "$SSH_AUTH_SOCK" ]; then
    if pgrep -u "$(whoami)" ssh-agent >/dev/null; then
        export SSH_AUTH_SOCK=$(find /tmp/ssh-* -user "$(whoami)" -name 'agent.*' 2>/dev/null | head -n 1)
        [ -z "$SSH_AUTH_SOCK" ] && eval "$(ssh-agent -s)"
    else
        eval "$(ssh-agent -s)"
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
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

# ----------------------------------------------------------------------
# Prompt Configuration
# ----------------------------------------------------------------------
# Choose ONE of these options:

# Option 1: Starship (recommended - works with both bash and zsh)
if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
fi

# Option 2: Oh My Posh (if you prefer)
# if command -v oh-my-posh &> /dev/null; then
#     eval "$(oh-my-posh init bash --config ~/.config/oh-my-posh/theme.json)"
# fi

# Option 3: Simple custom prompt (fallback if no framework)
# if ! command -v starship &> /dev/null && ! command -v oh-my-posh &> /dev/null; then
#     PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
# fi