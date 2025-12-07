#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Docker for Linux"

# Remove old Docker installations
sudo apt-get remove -y docker docker-engine docker.io containerd runc 2>/dev/null || true

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