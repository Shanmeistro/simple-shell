#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Docker Desktop for macOS"

# Check if Docker Desktop is already installed
if [ -d "/Applications/Docker.app" ]; then
    print_warning "Docker Desktop already installed"
    if command -v docker &> /dev/null; then
        print_info "Docker version: $(docker --version)"
        exit 0
    fi
fi

# Install Docker Desktop via Homebrew Cask
print_header "Installing Docker Desktop"
brew_cask_install docker

# Install Docker Compose (standalone) as backup
print_header "Installing Docker Compose (standalone)"
brew_install docker-compose

# Install additional Docker tools
print_header "Installing Additional Docker Tools"
brew_install lazydocker  # Terminal UI for Docker
brew_install dive        # Tool for exploring Docker images
brew_install ctop        # Top-like interface for containers

print_success "Docker Desktop Installation Complete!"
echo ""
echo "🐳 What was installed:"
echo "• Docker Desktop - Full Docker environment with GUI"
echo "• docker-compose - Container orchestration tool"
echo "• lazydocker - Terminal UI for Docker management"
echo "• dive - Docker image exploration tool"
echo "• ctop - Container monitoring tool"
echo ""
echo "💡 Next steps:"
echo "1. Open Docker Desktop from Applications folder"
echo "2. Complete Docker Desktop setup (sign-in optional)"
echo "3. Test installation: 'docker run hello-world'"
echo "4. Use lazydocker for easy container management"
echo ""
echo "🛠️ Useful commands:"
echo "• Start Docker Desktop: open /Applications/Docker.app"
echo "• Check status: docker info"
echo "• Container UI: lazydocker"
echo "• Explore images: dive <image-name>"
echo "• Monitor containers: ctop"