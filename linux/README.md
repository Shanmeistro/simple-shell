# Linux Development Environment Setup

This folder contains configuration scripts to set up a comprehensive development environment on **Debian-based Linux distributions** (Ubuntu, Debian, Linux Mint, etc.).

## Quick Start

```bash
# Run the main bootstrap script
./bootstrap.sh
```

## Scripts Overview

### Core Scripts

- **`bootstrap.sh`** - Main setup script with interactive shell and tool selection
- **`install-core.sh`** - Installs essential development packages (git, curl, modern CLI tools)
- **`scripts/helpers.sh`** - Common functions and Linux distribution detection

### Shell Configuration

- **`install-shell.sh`** - Enhanced Zsh with Oh My Zsh, Powerlevel10k, and useful plugins
- **`install-bash.sh`** - Enhanced Bash with Bash-it framework and Starship prompt

### Development Environments

- **`install-node.sh`** - Node.js with npm, yarn, pnpm, and global packages
- **`install-docker.sh`** - Docker Engine with Docker Compose
- **`install-kubernetes.sh`** - kubectl, Helm, k9s, kubectx/kubens

### Optional Development Languages

- **`optional-installers/install-python.sh`** - Python with pyenv, poetry, and essential packages
- **`optional-installers/install-go.sh`** - Go with development tools and CLI utilities
- **`optional-installers/install-rust.sh`** - Rust with cargo tools and modern CLI replacements
- **`optional-installers/install-java.sh`** - Java with SDKMAN!, multiple JDK versions, and build tools

## Features

### Shell Enhancements
- **Zsh**: Oh My Zsh + Powerlevel10k theme + useful plugins
- **Bash**: Bash-it framework + Starship prompt
- **Modern CLI Tools**: exa, bat, ripgrep, fd, fzf
- **Nerd Fonts**: For better terminal icons and symbols

### Development Tools
- **Package Managers**: apt, snap, flatpak support
- **Version Managers**: pyenv (Python), nvm (Node.js), rustup (Rust)
- **Container Tools**: Docker, Docker Compose, lazydocker
- **Kubernetes**: Complete kubectl ecosystem
- **Code Quality**: ESLint, Prettier, Black, clippy

## System Requirements

- **OS**: Ubuntu 18.04+, Debian 10+, or other Debian-based distributions
- **Architecture**: x86_64 (amd64)
- **Privileges**: sudo access required for package installation
- **Network**: Internet connection for downloads

## Usage Examples

### Individual Script Execution

```bash
# Install just the shell environment
./install-shell.sh

# Install Docker
./install-docker.sh

# Install Python development environment
./optional-installers/install-python.sh
```

### Custom Installation

```bash
# Install core tools only
./install-core.sh

# Then selectively install what you need
./install-node.sh
./optional-installers/install-go.sh
```

## Post-Installation

1. **Restart your terminal** or run `source ~/.zshrc` / `source ~/.bashrc`
2. **Configure Powerlevel10k**: Run `p10k configure` for Zsh theme customization
3. **Set up Git**: Configure your git user name and email
4. **Install VS Code extensions** or your preferred editor setup

## Troubleshooting

### Common Issues

- **Permission denied**: Ensure scripts are executable (`chmod +x *.sh`)
- **Package not found**: Update package lists (`sudo apt update`)
- **Network timeout**: Check internet connection and retry
- **Disk space**: Ensure adequate free space (2GB+ recommended)

### Distribution-Specific Notes

- **Ubuntu 22.04+**: All features supported
- **Ubuntu 20.04**: May need manual Python 3.9+ installation
- **Debian 11+**: All features supported
- **Linux Mint**: Based on Ubuntu, fully supported

### Getting Help

- Check script output for specific error messages
- Verify system requirements
- Ensure sudo access is available
- Run scripts individually to isolate issues

## Customization

All scripts use variables and functions from `scripts/helpers.sh`. You can:

- Modify package lists in individual scripts
- Adjust shell configurations in template sections
- Add custom aliases and functions to shell configs
- Extend the bootstrap script with additional options

## Related

- **Root Level**: `../manage_optional_tools.sh` - Cross-platform tool installer
- **WSL2**: `../wsl2/` - Windows Subsystem for Linux setup
- **macOS**: `../macos/` - macOS development environment setup