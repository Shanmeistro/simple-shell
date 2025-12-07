#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Node.js for Linux"

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