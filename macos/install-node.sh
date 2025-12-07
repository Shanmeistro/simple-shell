#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Node.js Development Environment for macOS"

# Install Node Version Manager (nvm)
if [ ! -d "$HOME/.nvm" ]; then
    print_header "Installing Node Version Manager (nvm)"
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
    
    # Source nvm for current session
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
else
    print_warning "nvm already installed"
    export NVM_DIR="$HOME/.nvm"
    [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
fi

# Install latest LTS Node.js
print_header "Installing Node.js LTS"
nvm install --lts
nvm use --lts
nvm alias default lts/*

# Install latest stable Node.js
print_header "Installing Latest Node.js"
nvm install node

# Install Yarn via Homebrew
print_header "Installing Yarn Package Manager"
brew_install yarn

# Install pnpm
print_header "Installing pnpm Package Manager"
curl -fsSL https://get.pnpm.io/install.sh | sh -

# Add nvm to shell profiles
for profile in ~/.bashrc ~/.bash_profile ~/.zshrc; do
    if [ -f "$profile" ]; then
        if ! grep -q 'NVM_DIR' "$profile"; then
            echo '' >> "$profile"
            echo '# Node Version Manager' >> "$profile"
            echo 'export NVM_DIR="$HOME/.nvm"' >> "$profile"
            echo '[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"' >> "$profile"
            echo '[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"' >> "$profile"
        fi
        if ! grep -q 'pnpm' "$profile"; then
            echo '' >> "$profile"
            echo '# pnpm' >> "$profile"
            echo 'export PNPM_HOME="$HOME/.local/share/pnpm"' >> "$profile"
            echo 'case ":$PATH:" in' >> "$profile"
            echo '  *":$PNPM_HOME:"*) ;;' >> "$profile"
            echo '  *) export PATH="$PNPM_HOME:$PATH" ;;' >> "$profile"
            echo 'esac' >> "$profile"
        fi
    fi
done

# Install global npm packages
print_header "Installing Global npm Packages"
npm install -g \
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
    prettier \
    npm-check-updates \
    serve \
    vercel \
    netlify-cli

# Install Bun (fast JavaScript runtime)
print_header "Installing Bun Runtime"
if ! command -v bun &> /dev/null; then
    curl -fsSL https://bun.sh/install | bash
fi

print_success "Node.js Development Environment Installed!"
echo ""
echo "📦 Node.js environments:"
nvm list
echo ""
echo "🛠️ Package managers installed:"
echo "• npm $(npm --version)"
echo "• yarn $(yarn --version 2>/dev/null || echo 'not found')"
echo "• pnpm $(pnpm --version 2>/dev/null || echo 'installing...')"
echo "• bun $(bun --version 2>/dev/null || echo 'installing...')"
echo ""
echo "💡 Global tools installed:"
echo "• Vue CLI, React CLI, Angular CLI"
echo "• TypeScript, ts-node, nodemon"
echo "• PM2 process manager"
echo "• Development servers (http-server, json-server)"
echo "• Code quality tools (ESLint, Prettier)"
echo "• Deployment tools (Vercel, Netlify)"
echo ""
echo "💡 Usage:"
echo "• Switch Node version: 'nvm use <version>'"
echo "• List versions: 'nvm list'"
echo "• Create React app: 'npx create-react-app my-app'"
echo "• Create Vue app: 'vue create my-app'"
echo "• Start dev server: 'npm run dev' or 'yarn dev'"