#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Kubernetes Tooling"

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s \
https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl

# kind
curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind

print_success "Kubernetes Tools Installed"
echo "kubectl version: $(kubectl version --client --short)"
