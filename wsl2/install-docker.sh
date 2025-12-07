#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Docker Engine"

# Remove old versions
sudo apt remove -y docker docker-engine docker.io containerd runc || true

# Add Docker repo
sudo install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt update -y
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Add user to docker group
sudo groupadd docker || true
sudo usermod -aG docker "$USER"

print_success "Docker Engine Installed"
echo "👉 Restart your shell to use Docker without sudo."
