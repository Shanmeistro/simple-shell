# Enable Powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ----------------------------------------------------------------------
# Zsh History Configuration
# ----------------------------------------------------------------------
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history

setopt HIST_IGNORE_DUPS HIST_IGNORE_SPACE HIST_EXPIRE_DUPS_FIRST
setopt HIST_FCNTL_LOCK HIST_VERIFY HIST_REDUCE_BLANKS
setopt HIST_SAVE_NO_DUPS HIST_NO_STORE APPEND_HISTORY SHARE_HISTORY

# ----------------------------------------------------------------------
# Zsh Completion System (Native - Fast!)
# ----------------------------------------------------------------------
autoload -Uz compinit
compinit -C  # Skip security check for speed

# Kubectl completion (only if installed)
[[ $commands[kubectl] ]] && source <(kubectl completion zsh)

# Completion styling
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}

# ----------------------------------------------------------------------
# Zsh Plugins (Standalone - No OMZ!)
# ----------------------------------------------------------------------
# Install these once with:
# git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
# git clone https://github.com/zsh-users/zsh-syntax-highlighting ~/.zsh/zsh-syntax-highlighting

source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh 2>/dev/null
source ~/.zsh/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh 2>/dev/null

# ----------------------------------------------------------------------
# Zsh Key Bindings
# ----------------------------------------------------------------------
bindkey -e

# Navigation (Ctrl+Arrow keys)
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^[[3;5~" delete-word

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
# Powerlevel10k Configuration (Standalone - No OMZ!)
# ----------------------------------------------------------------------
source ~/.powerlevel10k/powerlevel10k.zsh-theme
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh