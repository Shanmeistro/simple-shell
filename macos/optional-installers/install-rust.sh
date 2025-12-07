#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing Rust Development Environment for macOS"

# Install Rust via rustup
if ! command -v rustup &> /dev/null; then
    print_header "Installing Rustup and Rust"
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
else
    print_warning "Rust already installed"
fi

# Add cargo to PATH in shell profiles
for profile in ~/.bashrc ~/.bash_profile ~/.zshrc; do
    if [ -f "$profile" ]; then
        if ! grep -q 'source ~/.cargo/env' "$profile"; then
            echo '' >> "$profile"
            echo '# Rust environment' >> "$profile"
            echo 'source ~/.cargo/env' >> "$profile"
        fi
    fi
done

source ~/.cargo/env

# Update Rust to latest stable
print_header "Updating Rust"
rustup update stable
rustup default stable

# Install useful Rust components
print_header "Installing Rust Components"
rustup component add clippy
rustup component add rustfmt
rustup component add rust-analyzer

# Install useful Rust tools
print_header "Installing Rust Development Tools"
cargo install \
    cargo-edit \
    cargo-watch \
    cargo-expand \
    cargo-tree \
    cargo-audit \
    cargo-outdated \
    cargo-update \
    cargo-make \
    cargo-generate

# Install modern CLI tools written in Rust
print_header "Installing Rust-based CLI Tools"
cargo install \
    ripgrep \
    bat \
    exa \
    fd-find \
    tokei \
    hyperfine \
    du-dust \
    procs \
    bottom \
    starship

# Add useful targets
print_header "Adding Compilation Targets"
rustup target add x86_64-apple-darwin
if [[ $(uname -m) == "arm64" ]]; then
    rustup target add aarch64-apple-darwin
    rustup target add x86_64-apple-darwin  # For cross-compilation
fi

# Install wasm target for WebAssembly development
rustup target add wasm32-unknown-unknown

# Install wasm-pack for WebAssembly projects
cargo install wasm-pack

print_success "Rust Development Environment Installed!"
echo ""
echo "🦀 Rust $(rustc --version | cut -d' ' -f2) installed"
echo ""
echo "🛠️ Development tools installed:"
echo "• cargo-edit - Add/remove/upgrade dependencies"
echo "• cargo-watch - Auto-rebuild on file changes"
echo "• cargo-expand - Show macro expansions"
echo "• cargo-audit - Security audit of dependencies"
echo "• cargo-outdated - Check for outdated dependencies"
echo "• cargo-make - Task runner and build tool"
echo "• cargo-generate - Project templates"
echo "• wasm-pack - WebAssembly workflow"
echo ""
echo "🚀 Modern CLI tools:"
echo "• ripgrep (rg) - Fast text search"
echo "• bat - Cat with syntax highlighting"
echo "• exa - Modern ls replacement"
echo "• fd - Find alternative"
echo "• tokei - Code statistics"
echo "• hyperfine - Benchmarking tool"
echo "• bottom (btm) - System monitor"
echo ""
echo "💡 Quick start:"
echo "• New project: 'cargo new myproject'"
echo "• Add dependency: 'cargo add serde'"
echo "• Run with watch: 'cargo watch -x run'"
echo "• Check code: 'cargo clippy'"
echo "• Format code: 'cargo fmt'"
echo "• Security audit: 'cargo audit'"