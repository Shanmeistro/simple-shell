#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Node.js (LTS)"

curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt install -y nodejs

print_success "Node.js & npm Installed"
echo "node version: $(node -v)"
echo "npm version:  $(npm -v)"
