#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing Go Development Environment for macOS"

# Install Go via Homebrew
print_header "Installing Go"
brew_install go

# Set up Go environment
print_header "Configuring Go Environment"
for profile in ~/.bashrc ~/.bash_profile ~/.zshrc; do
    if [ -f "$profile" ]; then
        if ! grep -q 'GOPATH' "$profile"; then
            echo '' >> "$profile"
            echo '# Go environment' >> "$profile"
            echo 'export GOPATH=$HOME/go' >> "$profile"
            echo 'export PATH=$PATH:$GOPATH/bin' >> "$profile"
        fi
    fi
done

export GOPATH=$HOME/go
export PATH=$PATH:$GOPATH/bin

# Create Go workspace
mkdir -p "$HOME/go/{bin,pkg,src}"

# Install useful Go tools
print_header "Installing Go Development Tools"
go install golang.org/x/tools/gopls@latest
go install github.com/go-delve/delve/cmd/dlv@latest
go install honnef.co/go/tools/cmd/staticcheck@latest
go install golang.org/x/tools/cmd/goimports@latest
go install github.com/golangci/golangci-lint/cmd/golangci-lint@latest
go install github.com/fatih/gomodifytags@latest
go install github.com/josharian/impl@latest
go install github.com/cweill/gotests/gotests@latest

# Install popular Go CLI tools
print_header "Installing Popular Go CLI Tools"
go install github.com/goreleaser/goreleaser@latest
go install github.com/cosmtrek/air@latest
go install github.com/githubnemo/CompileDaemon@latest

print_success "Go Development Environment Installed!"
echo ""
echo "🐹 Go $(go version | cut -d' ' -f3) installed"
echo ""
echo "🛠️ Development tools installed:"
echo "• gopls - Language server for VS Code/editors"
echo "• dlv - Go debugger"
echo "• staticcheck - Static analyzer"
echo "• goimports - Import formatter"
echo "• golangci-lint - Meta-linter"
echo "• gomodifytags - Struct tag modifier"
echo "• impl - Interface implementation generator"
echo "• gotests - Test generator"
echo ""
echo "🚀 CLI tools installed:"
echo "• goreleaser - Release automation"
echo "• air - Live reload for Go apps"
echo "• CompileDaemon - File watcher"
echo ""
echo "💡 Quick start:"
echo "• Create module: 'go mod init myproject'"
echo "• Run with live reload: 'air'"
echo "• Generate tests: 'gotests -w -all .'"
echo "• Format imports: 'goimports -w .'"
echo "• Lint code: 'golangci-lint run'"