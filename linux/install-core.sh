#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Core Packages for Linux"

# Essential development packages for Debian-based systems
sudo apt install -y \
    build-essential \
    curl \
    wget \
    git \
    unzip \
    jq \
    ca-certificates \
    gnupg \
    lsb-release \
    software-properties-common \
    apt-transport-https \
    htop \
    tree \
    nano \
    vim \
    tmux \
    rsync \
    zip \
    p7zip-full \
    net-tools \
    dnsutils

print_success "Core Packages Installed Successfully"
print_header "Package Installation Summary"
echo "✅ Build tools (gcc, make, etc.)"
echo "✅ Network utilities (curl, wget, net-tools)"
echo "✅ Development tools (git, jq, vim)"
echo "✅ System utilities (htop, tree, tmux)"
echo "✅ Archive tools (zip, unzip, p7zip)"
echo "✅ Security certificates and GPG"