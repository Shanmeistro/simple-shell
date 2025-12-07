#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing Google Cloud SDK"

echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] \
https://packages.cloud.google.com/apt cloud-sdk main" \
| sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

curl https://packages.cloud.google.com/apt/doc/apt-key.gpg \
| sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg

sudo apt update -y && sudo apt install -y google-cloud-cli

print_success "Google Cloud SDK Installed"
