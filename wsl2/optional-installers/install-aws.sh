#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing AWS CLI"

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
rm -rf aws awscliv2.zip

print_success "AWS CLI Installed"
