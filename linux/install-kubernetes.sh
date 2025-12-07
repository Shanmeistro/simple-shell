#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Installing Kubernetes Tools for Linux"

# Install kubectl
print_header "Installing kubectl"
if ! command -v kubectl &> /dev/null; then
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    print_success "kubectl installed"
else
    print_warning "kubectl already installed"
fi

# Install Helm
print_header "Installing Helm"
if ! command -v helm &> /dev/null; then
    curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
    sudo apt-get install apt-transport-https --yes
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
    sudo apt-get update
    sudo apt-get install helm
    print_success "Helm installed"
else
    print_warning "Helm already installed"
fi

# Install k9s (Kubernetes CLI dashboard)
print_header "Installing k9s"
if ! command -v k9s &> /dev/null; then
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget -O /tmp/k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
    tar -xzf /tmp/k9s.tar.gz -C /tmp
    sudo mv /tmp/k9s /usr/local/bin/
    rm /tmp/k9s.tar.gz
    print_success "k9s installed"
else
    print_warning "k9s already installed"
fi

# Install kubectx and kubens
print_header "Installing kubectx and kubens"
if ! command -v kubectx &> /dev/null; then
    sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
    print_success "kubectx and kubens installed"
else
    print_warning "kubectx already installed"
fi

# Enable kubectl bash completion
print_header "Setting up kubectl completion"
echo 'source <(kubectl completion bash)' >> ~/.bashrc
echo 'alias k=kubectl' >> ~/.bashrc
echo 'complete -o default -F __start_kubectl k' >> ~/.bashrc

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