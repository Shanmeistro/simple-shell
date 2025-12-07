#!/usr/bin/env bash
set -e
source ../scripts/helpers.sh

print_header "Installing Go Development Environment"

# Get latest Go version
GO_VERSION=$(curl -s https://api.github.com/repos/golang/go/releases/latest | grep tag_name | cut -d '"' -f 4 | sed 's/go//')

# Download and install Go
print_header "Installing Go $GO_VERSION"
wget -O /tmp/go${GO_VERSION}.linux-amd64.tar.gz "https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz"
sudo rm -rf /usr/local/go
sudo tar -C /usr/local -xzf /tmp/go${GO_VERSION}.linux-amd64.tar.gz
rm /tmp/go${GO_VERSION}.linux-amd64.tar.gz

# Add Go to PATH
for profile in ~/.bashrc ~/.zshrc; do
    if [ -f "$profile" ]; then
        echo '' >> "$profile"
        echo '# Go environment' >> "$profile"
        echo 'export PATH=$PATH:/usr/local/go/bin' >> "$profile"
        echo 'export GOPATH=$HOME/go' >> "$profile"
        echo 'export PATH=$PATH:$GOPATH/bin' >> "$profile"
    fi
done

export PATH=$PATH:/usr/local/go/bin
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

print_success "Go Development Environment Installed!"
echo ""
echo "🐹 Go $(go version | cut -d' ' -f3) installed"
echo ""
echo "🛠️ Development tools installed:"
echo "• gopls - Language server"
echo "• dlv - Debugger"
echo "• staticcheck - Static analyzer"
echo "• goimports - Import formatter"
echo "• golangci-lint - Linter"
echo ""
echo "💡 Quick start:"
echo "• Create module: 'go mod init myproject'"
echo "• Run code: 'go run main.go'"
echo "• Build: 'go build'"
echo "• Test: 'go test ./...'"