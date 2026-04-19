#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Docker Installer"

prompt_install_action "Docker"

# -----------------------------------------------------------------------
# Shared stop/remove helper
# -----------------------------------------------------------------------
remove_docker() {
    print_header "Removing Existing Docker Installation"
    if systemctl is-active --quiet docker 2>/dev/null; then
        print_warning "Stopping Docker service..."
        sudo systemctl stop docker
        sudo systemctl stop docker.socket 2>/dev/null || true
        sudo systemctl stop containerd 2>/dev/null || true
    fi

    sudo apt-get remove -y \
        docker \
        docker-engine \
        docker.io \
        containerd \
        runc \
        docker-ce \
        docker-ce-cli \
        docker-buildx-plugin \
        docker-compose-plugin \
        2>/dev/null || true

    sudo apt-get autoremove -y 2>/dev/null || true
    sudo rm -f /etc/apt/sources.list.d/docker.list
    sudo rm -f /etc/apt/keyrings/docker.gpg
    print_success "Existing Docker installation cleaned up"
}

# -----------------------------------------------------------------------
# Shared fresh install logic
# -----------------------------------------------------------------------
install_docker() {
    sudo apt-get update
    sudo apt-get install -y ca-certificates curl gnupg lsb-release

    sudo mkdir -m 0755 -p /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
      $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

    sudo apt-get update
    sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

    sudo usermod -aG docker "$USER"
    sudo systemctl enable docker
    sudo systemctl start docker

    # Standalone docker-compose binary (for scripts using the old command form)
    if ! command -v docker-compose &>/dev/null; then
        print_header "Installing Docker Compose (standalone)"
        sudo curl -fsSL \
            "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" \
            -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi

    print_header "Testing Docker Installation"
    if sudo docker run --rm hello-world &>/dev/null; then
        print_success "Docker installed and working correctly!"
    else
        print_error "Docker installation test failed"
    fi
}

# -----------------------------------------------------------------------
# Remove only
# -----------------------------------------------------------------------
if [[ "$INSTALL_ACTION" == "remove" ]]; then
    remove_docker
    print_success "Docker removed."
    exit 0
fi

# -----------------------------------------------------------------------
# Update only
# -----------------------------------------------------------------------
if [[ "$INSTALL_ACTION" == "update" ]]; then
    print_header "Updating Docker"
    sudo apt-get update
    sudo apt-get install -y --only-upgrade \
        docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    print_success "Docker updated to $(docker --version)"
    exit 0
fi

# -----------------------------------------------------------------------
# Reinstall or Clean install (default)
# -----------------------------------------------------------------------
remove_docker
install_docker

print_success "Docker Installation Complete!"
echo ""
echo "Important:"
echo "  Log out and back in (or run 'newgrp docker') for group changes to take effect"
echo "  Test with: docker run hello-world"
echo "  Docker Compose available as: 'docker compose' or 'docker-compose'"


# Stop and remove any existing Docker installation
print_header "Removing Existing Docker Installation"
if systemctl is-active --quiet docker 2>/dev/null; then
    print_warning "Stopping Docker service..."
    sudo systemctl stop docker
    sudo systemctl stop docker.socket 2>/dev/null || true
    sudo systemctl stop containerd 2>/dev/null || true
fi

sudo apt-get remove -y \
    docker \
    docker-engine \
    docker.io \
    containerd \
    runc \
    docker-ce \
    docker-ce-cli \
    docker-buildx-plugin \
    docker-compose-plugin \
    2>/dev/null || true

sudo apt-get autoremove -y 2>/dev/null || true

# Remove leftover Docker data and config
sudo rm -f /etc/apt/sources.list.d/docker.list
sudo rm -f /etc/apt/keyrings/docker.gpg
print_success "Existing Docker installation cleaned up"

# Install Docker prerequisites
sudo apt-get update
sudo apt-get install -y \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker's official GPG key
sudo mkdir -m 0755 -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

# Set up Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Install Docker Engine
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo usermod -aG docker $USER

# Enable and start Docker service
sudo systemctl enable docker
sudo systemctl start docker

# Install Docker Compose (standalone)
print_header "Installing Docker Compose"
if ! command -v docker-compose &> /dev/null; then
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Test Docker installation
print_header "Testing Docker Installation"
if sudo docker run hello-world &> /dev/null; then
    print_success "Docker installed and working correctly!"
else
    print_error "Docker installation test failed"
fi

print_success "Docker Installation Complete!"
echo ""
echo "🐳 Important notes:"
echo "• Log out and log back in for docker group changes to take effect"
echo "• Or run 'newgrp docker' to apply group changes immediately"
echo "• Test with: 'docker run hello-world'"
echo "• Docker Compose available as: 'docker compose' or 'docker-compose'"