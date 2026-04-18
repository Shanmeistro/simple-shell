#!/usr/bin/env bash
set -e

# Load helper functions
source ./scripts/helpers.sh

print_header "simple-shell Bootstrap"

# Back up the user's current .bashrc before anything modifies it
backup_bashrc

# Check distribution compatibility
check_linux_distro

# Update and upgrade system
update_packages
upgrade_packages

# Install core tools
./install-core.sh

# Configure Bash environment
./install-bash.sh

echo ""
echo "Optional Development Tools"
echo "You can install additional tools now or run individual scripts later:"
echo "  ./install-docker.sh              - Docker and container tools"
echo "  ./install-kubernetes.sh          - Kubernetes tools (kubectl, helm, k9s)"
echo "  ./install-node.sh                - Node.js via nvm"
echo "  ./optional-installers/install-*  - Language runtimes (Go, Rust, Java, Python)"
echo ""
read -p "Install Docker now? (y/N): " install_docker
install_docker=${install_docker:-n}

case $install_docker in
    y|Y|yes|YES)
        ./install-docker.sh
        ;;
    *)
        echo "Skipping Docker installation."
        ;;
esac

read -p "Install Node.js (nvm) now? (y/N): " install_node
install_node=${install_node:-n}

case $install_node in
    y|Y|yes|YES)
        ./install-node.sh
        ;;
    *)
        echo "Skipping Node.js installation."
        ;;
esac

print_success "Bootstrap complete!"
echo ""
echo "Next steps:"
echo "  source ~/.bashrc   - Apply the new Bash configuration in your current session"
echo "  Explore optional installers in ./optional-installers/ for language runtimes"