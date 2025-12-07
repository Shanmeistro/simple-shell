# WSL2 Setup Scripts

This folder contains scripts to bootstrap your WSL2 environment with development tools and a customized shell experience.

## Quick Start

### Option 1: Full Development Environment
For a complete dev environment with Docker, Kubernetes, Node.js, and optional cloud tools:
```bash
./bootstrap.sh
```

### Option 2: Shell Environment Only
For customized shell experience without dev tools:

**Zsh (recommended):**
```bash
./install-shell.sh
```

**Enhanced Bash:**
```bash
./install-bash.sh
```

### Option 3: Minimal Quick Setup
For a lightweight shell setup with auto-download capabilities:
```bash
./quick-shell-setup.sh
```

## What's Included

### Shell Environment (`install-shell.sh` / `install-bash.sh`)

**Zsh Option:**
- **Zsh Shell**: Modern shell with advanced features
- **Oh My Zsh**: Framework for managing Zsh configuration
- **Powerlevel10k**: Fast and customizable prompt theme
- **Essential Plugins**:
  - `zsh-autosuggestions` - Command auto-completion
  - `zsh-syntax-highlighting` - Real-time syntax highlighting
  - `colored-man-pages` - Colorized manual pages
  - `extract` - Universal archive extraction
  - `z` - Smart directory jumping

**Bash Option:**
- **Enhanced Bash**: Modern bash with advanced tools
- **Starship**: Fast, cross-platform prompt
- **Bash-it**: Framework for bash (similar to oh-my-zsh)
- **Modern CLI Tools**:
  - `fzf` - Fuzzy finder for files and history
  - `ripgrep` - Fast text search
  - `bat` - Enhanced cat with syntax highlighting
  - `exa` - Modern ls replacement

**Common Features:**
- **MesloLGS NF Fonts**: Optimized for powerline symbols
- **WSL2 Optimizations**: Windows integration and utilities

### Development Tools (`bootstrap.sh`)
- Core development packages (build-essential, git, curl, etc.)
- Node.js and npm
- Docker and container tools
- Kubernetes tools (kubectl, kind)
- Optional cloud CLIs (AWS, Azure, GCP)
- Terraform

## Prerequisites

- Fresh Ubuntu installation on WSL2
- Internet connection for downloading packages
- Windows Terminal (recommended for best font support)

## Installation Types

### Fresh Install
For new WSL2 instances, all scripts will install cleanly without conflicts.

### Existing System
The shell installer includes:
- Automatic detection of existing configurations
- Backup functionality for current settings
- Safe installation without overwriting custom configurations

## WSL2-Specific Features

The shell configuration includes WSL2-optimized features:

### Aliases
- `open` - Open files/folders in Windows Explorer
- `code` - Launch VS Code from WSL2
- `win-home` - Navigate to Windows user directory

### Functions
- `wsl-ip` - Get WSL2 IP address
- `mkcd` - Create and navigate to directory
- Safe file operations with confirmation prompts

### Environment
- Windows Terminal integration
- Proper DISPLAY variable for GUI applications
- Optimized PATH with local bin directories

## Font Configuration

After installation, configure Windows Terminal:

1. Open Windows Terminal Settings (Ctrl + ,)
2. Navigate to your WSL profile
3. Change font face to "MesloLGS NF"
4. Save and restart terminal

### Customization

### Zsh Customization
**Powerlevel10k Theme:**
Run the configuration wizard after installation:
```bash
p10k configure
```

**Shell Configuration:**
Edit `~/.zshrc` to customize:
- Aliases and functions
- Environment variables
- Plugin configuration
- Additional Oh My Zsh themes

### Bash Customization
**Starship Prompt:**
Edit `~/.config/starship.toml` for prompt customization:
```bash
starship config
```

**Bash-it Framework:**
```bash
# Show available themes
bash-it show themes

# Enable a theme
bash-it enable theme powerline

# Show available plugins
bash-it show plugins
```

**Shell Configuration:**
Edit `~/.bashrc` to customize your bash environment.

## Troubleshooting

### Font Issues
- Ensure "MesloLGS NF" is selected in Windows Terminal
- Restart terminal after font changes
- Use `fc-list | grep -i meslo` to verify font installation

### Shell Not Changing
If Zsh doesn't become default:
```bash
chsh -s $(which zsh)
```
Then restart your terminal.

### Permission Issues
Make scripts executable:
```bash
chmod +x *.sh
chmod +x scripts/*.sh
```

## File Structure

```
wsl2/
├── bootstrap.sh           # Full development environment
├── install-shell.sh       # Zsh environment setup
├── install-bash.sh        # Enhanced Bash environment
├── quick-shell-setup.sh   # Minimal setup with auto-download
├── install-core.sh        # Core packages
├── install-node.sh        # Node.js installation
├── install-docker.sh      # Docker setup
├── install-kubernetes.sh  # Kubernetes tools
├── scripts/
│   └── helpers.sh         # Utility functions
└── optional/              # Optional cloud tools
    ├── install-aws.sh
    ├── install-azure.sh
    ├── install-gcloud.sh
    └── install-terraform.sh
```

## Contributing

When adding new installers:
1. Follow the existing pattern with helper functions
2. Include proper error handling (`set -e`)
3. Add installation verification
4. Update this README with new features