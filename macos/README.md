# macOS Development Environment Setup

This folder contains configuration scripts to set up a comprehensive development environment on **macOS 11-15** (Big Sur through current versions).

## Quick Start

```bash
# Run the main bootstrap script
./bootstrap.sh
```

## Scripts Overview

### Core Scripts

- **`bootstrap.sh`** - Main setup script with interactive shell and tool selection
- **`install-core.sh`** - Installs essential development packages via Homebrew
- **`scripts/helpers.sh`** - Common functions and macOS version detection

### Shell Configuration

- **`install-shell.sh`** - Enhanced Zsh with Oh My Zsh, Powerlevel10k, and Nerd Fonts
- **`install-bash.sh`** - Latest Bash with Bash-it framework and enhanced features

### Development Environments

- **`install-node.sh`** - Node.js with nvm, multiple package managers, and global tools
- **`install-docker.sh`** - Docker Desktop with additional container tools

### Optional Development Languages

- **`optional-installers/install-python.sh`** - Python with pyenv, poetry, and scientific packages
- **`optional-installers/install-go.sh`** - Go with comprehensive toolchain and CLI utilities
- **`optional-installers/install-rust.sh`** - Rust with cargo ecosystem and modern CLI tools
- **`optional-installers/install-java.sh`** - Java with SDKMAN!, multiple JDK versions, and IDEs

## Features

### Shell Enhancements
- **Zsh**: Oh My Zsh + Powerlevel10k + useful plugins + Nerd Fonts
- **Bash**: Latest Bash + Bash-it + Starship prompt
- **Modern CLI Tools**: exa, bat, ripgrep, fd, fzf (via Homebrew)
- **macOS Integration**: Finder aliases, DNS flushing, system shortcuts

### Development Tools
- **Package Manager**: Homebrew with cask support
- **Version Managers**: nvm (Node.js), pyenv (Python), rustup (Rust), SDKMAN! (Java)
- **Container Tools**: Docker Desktop, lazydocker, dive, ctop
- **Multiple Architectures**: Intel x86_64 and Apple Silicon (arm64) support
- **Code Quality**: Language-specific linters, formatters, and analyzers

## System Requirements

- **OS**: macOS 11 (Big Sur) through macOS 15 (current)
- **Architecture**: Intel x86_64 or Apple Silicon (M1/M2/M3)
- **Xcode**: Command Line Tools (installed automatically)
- **Homebrew**: Installed automatically if not present
- **Network**: Internet connection for downloads

## Supported macOS Versions

✅ **macOS 15** (Sequoia) - Fully supported  
✅ **macOS 14** (Sonoma) - Fully supported  
✅ **macOS 13** (Ventura) - Fully supported  
✅ **macOS 12** (Monterey) - Fully supported  
✅ **macOS 11** (Big Sur) - Fully supported

## Architecture Support

### Apple Silicon (M1/M2/M3)
- Homebrew installed to `/opt/homebrew`
- Native ARM64 packages preferred
- Rosetta 2 for Intel-only packages
- Cross-compilation targets included

### Intel Macs
- Homebrew installed to `/usr/local`
- Full x86_64 package support
- Legacy compatibility maintained

## Usage Examples

### Individual Script Execution

```bash
# Install just the shell environment
./install-shell.sh

# Install Docker Desktop
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
./optional-installers/install-rust.sh
```

## Post-Installation

1. **Restart your terminal** or run `source ~/.zshrc` / `source ~/.bash_profile`
2. **Configure Powerlevel10k**: Run `p10k configure` for Zsh theme customization
3. **Install Nerd Font**: Set your terminal to use a Nerd Font for best experience
4. **Start Docker Desktop**: Open from Applications folder and complete setup
5. **Configure Git**: Set up your git credentials and SSH keys

## macOS-Specific Features

### System Integration
- **Finder Aliases**: Show/hide hidden files, flush DNS cache
- **Homebrew Optimization**: Architecture-aware installation paths
- **Font Management**: Nerd Fonts via Homebrew Cask
- **App Installation**: GUI applications via Homebrew Cask

### Security & Privacy
- **Xcode Command Line Tools**: Automatically prompted for installation
- **Homebrew Security**: Official signed packages
- **System Permissions**: Respects macOS security model
- **Keychain Integration**: Native credential storage

## Troubleshooting

### Common Issues

**Xcode Command Line Tools Missing**
```bash
# Install manually if needed
xcode-select --install
```

**Homebrew Permission Issues**
```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) $(brew --prefix)/*
```

**Apple Silicon Compatibility**
```bash
# Check if running under Rosetta
arch
# Expected: arm64 (native) or i386 (Rosetta)
```

**Path Issues**
```bash
# Reload shell environment
source ~/.zshrc  # or ~/.bash_profile
```

### Version-Specific Notes

- **macOS 15**: All features supported, latest package versions
- **macOS 14**: Full compatibility, may have minor UI differences
- **macOS 13**: Stable support, some newer features may be limited
- **macOS 12**: Supported with compatibility modes
- **macOS 11**: Minimum version, basic feature set

### Getting Help

- Check Console.app for system-level errors
- Use `brew doctor` to diagnose Homebrew issues
- Verify architecture with `uname -m`
- Check script permissions with `ls -la *.sh`

## Customization

All scripts use functions from `scripts/helpers.sh`. You can:

- Modify Homebrew package lists in individual scripts
- Adjust shell configurations in the template sections
- Add custom macOS aliases and functions
- Extend the bootstrap script with additional GUI applications
- Configure Homebrew taps for additional software sources

## Performance Tips

- **SSD Recommended**: Fast storage improves compilation times
- **Memory**: 8GB+ RAM recommended for development
- **Network**: Fast internet for initial Homebrew package downloads
- **Background Apps**: Close unnecessary apps during installation

## Related

- **Root Level**: `../manage_optional_tools.sh` - Cross-platform tool installer
- **Linux**: `../linux/` - Linux development environment setup
- **WSL2**: `../wsl2/` - Windows Subsystem for Linux setup
- **Homebrew**: Visit [brew.sh](https://brew.sh) for package search