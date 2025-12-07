#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Core Packages"

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
    apt-transport-https

print_success "Core Packages Installed"
