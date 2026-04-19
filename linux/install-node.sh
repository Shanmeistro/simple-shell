#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Node.js Installer"

prompt_install_action "Node.js"

# -----------------------------------------------------------------------
# Shared remove helper
# -----------------------------------------------------------------------
remove_node() {
    print_header "Removing Existing Node.js Installation"
    sudo apt-get remove -y nodejs 2>/dev/null || true
    sudo apt-get autoremove -y 2>/dev/null || true
    sudo rm -f /etc/apt/sources.list.d/nodesource.list
    # Remove nvm if present
    if [ -d "$HOME/.nvm" ]; then
        print_warning "Removing nvm..."
        rm -rf "$HOME/.nvm"
    fi
    print_success "Node.js removed"
}

# -----------------------------------------------------------------------
# Shared install logic
# -----------------------------------------------------------------------
install_node() {
    print_header "Adding NodeSource Repository (LTS)"
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

    print_header "Installing Node.js and npm"
    sudo apt-get install -y nodejs

    NODE_VERSION=$(node --version)
    NPM_VERSION=$(npm --version)
    print_success "Node.js $NODE_VERSION installed"
    print_success "npm $NPM_VERSION installed"

    # Configure npm global prefix to avoid requiring sudo for global installs
    print_header "Configuring npm global prefix"
    NPM_GLOBAL="$HOME/.npm-global"
    mkdir -p "$NPM_GLOBAL"
    npm config set prefix "$NPM_GLOBAL"

    # Idempotent PATH entry
    BASHRC="$HOME/.bashrc"
    grep -qxF 'export PATH="$HOME/.npm-global/bin:$PATH"' "$BASHRC" || \
        echo 'export PATH="$HOME/.npm-global/bin:$PATH"' >> "$BASHRC"
    export PATH="$NPM_GLOBAL/bin:$PATH"
    print_success "npm global prefix set to $NPM_GLOBAL (no sudo needed for global installs)"

    # Install global packages — runs without sudo due to prefix config above
    print_header "Installing Global npm Packages"
    npm install -g \
        yarn \
        pnpm \
        typescript \
        ts-node \
        nodemon \
        pm2 \
        http-server \
        eslint \
        prettier
    print_success "Global npm packages installed"
}

# -----------------------------------------------------------------------
# Remove only
# -----------------------------------------------------------------------
if [[ "$INSTALL_ACTION" == "remove" ]]; then
    remove_node
    exit 0
fi

# -----------------------------------------------------------------------
# Update only
# -----------------------------------------------------------------------
if [[ "$INSTALL_ACTION" == "update" ]]; then
    print_header "Updating Node.js"
    # Re-run the NodeSource setup to pull the latest LTS channel, then upgrade
    curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
    sudo apt-get install -y --only-upgrade nodejs
    print_success "Node.js updated to $(node --version)"

    print_header "Updating Global npm Packages"
    npm update -g
    print_success "Global npm packages updated"
    exit 0
fi

# -----------------------------------------------------------------------
# Reinstall or Clean install (default)
# -----------------------------------------------------------------------
remove_node
install_node

print_success "Node.js Setup Complete!"
echo ""
echo "Installed:"
echo "  Node.js $(node --version)"
echo "  npm $(npm --version)"
echo ""
echo "Global packages installed without sudo — prefix: ~/.npm-global"
echo "Run 'source ~/.bashrc' to activate the updated PATH in your current session."


# Install Node.js LTS via NodeSource repository
print_header "Adding NodeSource Repository"
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -

print_header "Installing Node.js and npm"
sudo apt-get install -y nodejs

# Verify installation
print_header "Verifying Node.js Installation"
NODE_VERSION=$(node --version)
NPM_VERSION=$(npm --version)

print_success "Node.js $NODE_VERSION installed"
print_success "npm $NPM_VERSION installed"

# Install global npm packages
print_header "Installing Global npm Packages"
npm install -g \
    yarn \
    pnpm \
    @vue/cli \
    create-react-app \
    @angular/cli \
    typescript \
    ts-node \
    nodemon \
    pm2 \
    http-server \
    json-server \
    eslint \
    prettier

print_success "Global npm packages installed"

# Install pnpm (alternative package manager)
print_header "Installing pnpm"
if ! command -v pnpm &> /dev/null; then
    curl -fsSL https://get.pnpm.io/install.sh | sh -
    export PNPM_HOME="$HOME/.local/share/pnpm"
    export PATH="$PNPM_HOME:$PATH"
fi

# Set up npm global directory to avoid permission issues
print_header "Configuring npm"
npm config set prefix ~/.npm-global
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.bashrc
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zshrc 2>/dev/null || true

print_success "Node.js Environment Setup Complete!"
echo ""
echo "📦 Installed tools:"
echo "• Node.js $(node --version)"
echo "• npm $(npm --version)"
echo "• yarn $(yarn --version 2>/dev/null || echo 'not installed')"
echo "• pnpm $(pnpm --version 2>/dev/null || echo 'installing...')"
echo ""
echo "🛠️ Global packages installed:"
echo "• Vue CLI, React CLI, Angular CLI"
echo "• TypeScript, ts-node, nodemon"
echo "• PM2, http-server, json-server"
echo "• ESLint, Prettier"
echo ""
echo "💡 Quick start:"
echo "• Create React app: 'npx create-react-app my-app'"
echo "• Create Vue app: 'vue create my-app'"
echo "• Start dev server: 'http-server' or 'json-server'"
echo "• Process manager: 'pm2 start app.js'"