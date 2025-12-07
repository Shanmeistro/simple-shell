#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing Terraform"

curl -fsSL https://apt.releases.hashicorp.com/gpg \
| sudo gpg --dearmor -o /etc/apt/keyrings/hashicorp.gpg

echo \
"deb [signed-by=/etc/apt/keyrings/hashicorp.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" \
| sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt update -y
sudo apt install -y terraform

print_success "Terraform Installed"
