#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Kubernetes Tools for Linux"

# Stop and remove any existing Kubernetes tooling
print_header "Removing Existing Kubernetes Tools"

if command -v kubectl &>/dev/null; then
    print_warning "Removing existing kubectl..."
    sudo rm -f /usr/local/bin/kubectl
fi

if command -v helm &>/dev/null; then
    print_warning "Removing existing Helm..."
    sudo rm -f /usr/local/bin/helm
    sudo rm -f /etc/apt/sources.list.d/helm-stable-debian.list
    sudo rm -f /usr/share/keyrings/helm.gpg
    sudo apt-get remove -y helm 2>/dev/null || true
fi

if command -v k9s &>/dev/null; then
    print_warning "Removing existing k9s..."
    sudo rm -f /usr/local/bin/k9s
fi

if command -v kubectx &>/dev/null || command -v kubens &>/dev/null; then
    print_warning "Removing existing kubectx/kubens..."
    sudo rm -f /usr/local/bin/kubectx /usr/local/bin/kubens
    sudo rm -rf /opt/kubectx
fi

print_success "Existing Kubernetes tools cleaned up"

# Install kubectl
print_header "Installing kubectl"
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
rm kubectl
print_success "kubectl installed"

# Install Helm
print_header "Installing Helm"
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install -y apt-transport-https
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install -y helm
print_success "Helm installed"

# Install k9s (Kubernetes CLI dashboard)
print_header "Installing k9s"
K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
wget -O /tmp/k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
tar -xzf /tmp/k9s.tar.gz -C /tmp k9s
sudo mv /tmp/k9s /usr/local/bin/
rm /tmp/k9s.tar.gz
print_success "k9s installed"

# Install kubectx and kubens
print_header "Installing kubectx and kubens"
sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
print_success "kubectx and kubens installed"

# Set up kubectl bash completion (idempotent — avoid duplicate entries)
print_header "Setting up kubectl completion"
BASHRC="$HOME/.bashrc"

grep -qxF 'source <(kubectl completion bash)' "$BASHRC" || \
    echo 'source <(kubectl completion bash)' >> "$BASHRC"

grep -qxF 'alias k=kubectl' "$BASHRC" || \
    echo 'alias k=kubectl' >> "$BASHRC"

grep -qxF 'complete -o default -F __start_kubectl k' "$BASHRC" || \
    echo 'complete -o default -F __start_kubectl k' >> "$BASHRC"

print_success "Kubernetes Tools Installation Complete!"
echo ""
echo "Run 'source ~/.bashrc' to activate kubectl completion in your current session."


print_success "Kubernetes Tools Installation Complete!"
echo ""
echo "🚢 Installed tools:"
echo "• kubectl - Kubernetes command-line tool"
echo "• helm - Kubernetes package manager"
echo "• k9s - Terminal UI for Kubernetes"
echo "• kubectx/kubens - Context and namespace switching"
echo ""
echo "💡 Quick start:"
echo "• Check versions: 'kubectl version', 'helm version'"
echo "• Use k9s: just run 'k9s'"
echo "• Switch contexts: 'kubectx'"
echo "• Switch namespaces: 'kubens'"