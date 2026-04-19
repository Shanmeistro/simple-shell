#!/usr/bin/env bash
set -e
source ./scripts/helpers.sh

print_header "Kubernetes Tools Installer"

prompt_install_action "Kubernetes Tools"

# -----------------------------------------------------------------------
# Remove helpers
# -----------------------------------------------------------------------
remove_kubectl() {
    if command -v kubectl &>/dev/null; then
        print_warning "Removing kubectl..."
        sudo rm -f /usr/local/bin/kubectl
    fi
    if command -v kubectx &>/dev/null || command -v kubens &>/dev/null; then
        print_warning "Removing kubectx/kubens..."
        sudo rm -f /usr/local/bin/kubectx /usr/local/bin/kubens
        sudo rm -rf /opt/kubectx
    fi
}

remove_helm() {
    # Always remove stale apt sources regardless of whether the binary exists
    sudo rm -f /etc/apt/sources.list.d/helm-stable-debian.list
    sudo rm -f /usr/share/keyrings/helm.gpg
    if command -v helm &>/dev/null; then
        print_warning "Removing Helm..."
        sudo rm -f /usr/local/bin/helm
        sudo apt-get remove -y helm 2>/dev/null || true
    fi
}

remove_minikube() {
    if command -v minikube &>/dev/null; then
        print_warning "Stopping and removing minikube..."
        minikube stop 2>/dev/null || true
        minikube delete --all 2>/dev/null || true
        sudo rm -f /usr/local/bin/minikube
    fi
}

remove_k9s() {
    if command -v k9s &>/dev/null; then
        print_warning "Removing k9s..."
        sudo rm -f /usr/local/bin/k9s
    fi
}

# -----------------------------------------------------------------------
# Remove only
# -----------------------------------------------------------------------
if [[ "$INSTALL_ACTION" == "remove" ]]; then
    print_header "Removing All Kubernetes Tools"
    remove_kubectl
    remove_helm
    remove_k9s
    remove_minikube
    print_success "All Kubernetes tools removed."
    exit 0
fi

# -----------------------------------------------------------------------
# Update only
# -----------------------------------------------------------------------
if [[ "$INSTALL_ACTION" == "update" ]]; then
    print_header "Updating Kubernetes Tools"

    if command -v kubectl &>/dev/null; then
        print_header "Updating kubectl"
        sudo rm -f /usr/local/bin/kubectl
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
        sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
        rm kubectl
        print_success "kubectl updated to $(kubectl version --client --short 2>/dev/null || kubectl version --client)"
    else
        print_warning "kubectl not installed — skipping update"
    fi

    if command -v helm &>/dev/null; then
        print_header "Updating Helm"
        curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
        print_success "Helm updated to $(helm version --short)"
    else
        print_warning "Helm not installed — skipping update"
    fi

    if command -v k9s &>/dev/null; then
        print_header "Updating k9s"
        sudo rm -f /usr/local/bin/k9s
        K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
        wget -q -O /tmp/k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
        tar -xzf /tmp/k9s.tar.gz -C /tmp k9s
        sudo mv /tmp/k9s /usr/local/bin/
        rm /tmp/k9s.tar.gz
        print_success "k9s updated to $K9S_VERSION"
    else
        print_warning "k9s not installed — skipping update"
    fi

    if command -v minikube &>/dev/null; then
        print_header "Updating minikube"
        sudo rm -f /usr/local/bin/minikube
        curl -fsSL \
            "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64" \
            -o /tmp/minikube
        sudo install -o root -g root -m 0755 /tmp/minikube /usr/local/bin/minikube
        rm /tmp/minikube
        print_success "minikube updated to $(minikube version --short)"
    else
        print_warning "minikube not installed — skipping update"
    fi

    print_success "Update complete."
    exit 0
fi

# -----------------------------------------------------------------------
# Reinstall or Clean install — ask which tools to install
# -----------------------------------------------------------------------
print_header "Select Tools to Install"
echo "Select which Kubernetes tools to install:"
echo ""

read -p "  kubectl + kubectx/kubens (core CLI tools)? (Y/n): " _want_kubectl
read -p "  Helm (Kubernetes package manager)?          (Y/n): " _want_helm
read -p "  k9s (terminal UI dashboard)?               (Y/n): " _want_k9s
read -p "  minikube (local Kubernetes cluster)?       (Y/n): " _want_minikube
echo ""

WANT_KUBECTL=true; WANT_HELM=true; WANT_K9S=true; WANT_MINIKUBE=true
[[ "${_want_kubectl}"   =~ ^[Nn]$ ]] && WANT_KUBECTL=false
[[ "${_want_helm}" =~      ^[Nn]$ ]] && WANT_HELM=false
[[ "${_want_k9s}" =~       ^[Nn]$ ]] && WANT_K9S=false
[[ "${_want_minikube}" =~  ^[Nn]$ ]] && WANT_MINIKUBE=false

# Clean up existing installations before fresh install
print_header "Removing Existing Kubernetes Tools"
remove_kubectl
remove_helm
remove_k9s
remove_minikube
print_success "Existing Kubernetes tools cleaned up"

# -----------------------------------------------------------------------
# kubectl + kubectx/kubens
# -----------------------------------------------------------------------
if [[ "$WANT_KUBECTL" == true ]]; then
    print_header "Installing kubectl"
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
    rm kubectl
    print_success "kubectl installed"

    print_header "Installing kubectx and kubens"
    sudo git clone --depth=1 https://github.com/ahmetb/kubectx /opt/kubectx
    sudo ln -s /opt/kubectx/kubectx /usr/local/bin/kubectx
    sudo ln -s /opt/kubectx/kubens /usr/local/bin/kubens
    print_success "kubectx and kubens installed"

    # kubectl bash completion (idempotent)
    print_header "Setting up kubectl completion"
    BASHRC="$HOME/.bashrc"
    grep -qxF 'source <(kubectl completion bash)' "$BASHRC" || \
        echo 'source <(kubectl completion bash)' >> "$BASHRC"
    grep -qxF 'alias k=kubectl' "$BASHRC" || \
        echo 'alias k=kubectl' >> "$BASHRC"
    grep -qxF 'complete -o default -F __start_kubectl k' "$BASHRC" || \
        echo 'complete -o default -F __start_kubectl k' >> "$BASHRC"
    print_success "kubectl completion configured"
fi

# -----------------------------------------------------------------------
# Helm — official install script (no apt repo dependency)
# -----------------------------------------------------------------------
if [[ "$WANT_HELM" == true ]]; then
    print_header "Installing Helm"
    curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
    print_success "Helm $(helm version --short) installed"
fi

# -----------------------------------------------------------------------
# k9s
# -----------------------------------------------------------------------
if [[ "$WANT_K9S" == true ]]; then
    print_header "Installing k9s"
    K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
    wget -q -O /tmp/k9s.tar.gz "https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz"
    tar -xzf /tmp/k9s.tar.gz -C /tmp k9s
    sudo mv /tmp/k9s /usr/local/bin/
    rm /tmp/k9s.tar.gz
    print_success "k9s $K9S_VERSION installed"
fi

# -----------------------------------------------------------------------
# minikube
# -----------------------------------------------------------------------
if [[ "$WANT_MINIKUBE" == true ]]; then
    print_header "Installing minikube"
    curl -fsSL \
        "https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64" \
        -o /tmp/minikube
    sudo install -o root -g root -m 0755 /tmp/minikube /usr/local/bin/minikube
    rm /tmp/minikube
    print_success "minikube $(minikube version --short) installed"
fi

print_success "Kubernetes Tools Installation Complete!"
echo ""
echo "Run 'source ~/.bashrc' to activate kubectl completion in your current session."
