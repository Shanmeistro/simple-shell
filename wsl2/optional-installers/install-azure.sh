#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing Azure CLI"

curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

print_success "Azure CLI Installed"
