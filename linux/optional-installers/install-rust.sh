#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing Rust Development Environment"

# Install Rust via rustup
if ! command -v rustup &> /dev/null; then
    print_header "Installing Rustup and Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
else
    print_warning "Rust already installed"
fi

# Add cargo to PATH in shell profiles
for profile in ~/.bashrc ~/.zshrc; do
    if [ -f "$profile" ]; then
        grep -q 'source ~/.cargo/env' "$profile" || echo 'source ~/.cargo/env' >> "$profile"
    fi
done

source ~/.cargo/env

# Update Rust to latest stable
print_header "Updating Rust"
rustup update stable
rustup default stable

# Install useful Rust tools
print_header "Installing Rust Development Tools"
cargo install \
    cargo-edit \
    cargo-watch \
    cargo-expand \
    cargo-tree \
    cargo-audit \
    cargo-outdated \
    ripgrep \
    bat \
    exa \
    fd-find \
    tokei \
    hyperfine

# Install Rust analyzer (language server)
rustup component add rust-analyzer

# Add useful targets
print_header "Adding Compilation Targets"
rustup target add x86_64-unknown-linux-musl

print_success "Rust Development Environment Installed!"
echo ""
echo "🦀 Rust $(rustc --version | cut -d' ' -f2) installed"
echo ""
echo "🛠️ Development tools installed:"
echo "• cargo-edit - Add/remove dependencies"
echo "• cargo-watch - Auto-rebuild on changes"
echo "• cargo-expand - Show macro expansions"
echo "• cargo-audit - Security audit"
echo "• ripgrep, bat, exa, fd - Modern CLI tools"
echo "• tokei - Code statistics"
echo "• hyperfine - Benchmarking tool"
echo ""
echo "💡 Quick start:"
echo "• New project: 'cargo new myproject'"
echo "• Add dependency: 'cargo add serde'"
echo "• Run with watch: 'cargo watch -x run'"
echo "• Build release: 'cargo build --release'"