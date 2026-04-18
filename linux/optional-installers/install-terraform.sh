#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing Terraform"

# Stop and remove any existing Terraform installation
print_header "Removing Existing Terraform Installation"

if command -v terraform &>/dev/null; then
    TF_EXISTING=$(terraform version 2>/dev/null | head -1 || true)
    print_warning "Removing existing Terraform ($TF_EXISTING)..."
    sudo rm -f /usr/local/bin/terraform
    sudo rm -f /usr/bin/terraform
fi

# Remove any existing HashiCorp apt repo to ensure a clean re-add
sudo rm -f /etc/apt/sources.list.d/hashicorp.list
sudo rm -f /usr/share/keyrings/hashicorp-archive-keyring.gpg
sudo apt-get remove -y terraform 2>/dev/null || true
sudo apt-get autoremove -y 2>/dev/null || true

print_success "Existing Terraform installation cleaned up"

# Install prerequisites
sudo apt-get update
sudo apt-get install -y gnupg software-properties-common curl

# Add HashiCorp GPG key and apt repository
print_header "Adding HashiCorp Repository"
curl -fsSL https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    sudo tee /usr/share/keyrings/hashicorp-archive-keyring.gpg > /dev/null

echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    sudo tee /etc/apt/sources.list.d/hashicorp.list

sudo apt-get update
sudo apt-get install -y terraform

# Verify installation
print_header "Verifying Terraform Installation"
terraform version

# Enable bash completion (idempotent)
BASHRC="$HOME/.bashrc"
grep -qxF 'complete -C /usr/bin/terraform terraform' "$BASHRC" || \
    echo 'complete -C /usr/bin/terraform terraform' >> "$BASHRC"

print_success "Terraform Installation Complete!"
echo ""
echo "Run 'source ~/.bashrc' to activate Terraform completion in your current session."
