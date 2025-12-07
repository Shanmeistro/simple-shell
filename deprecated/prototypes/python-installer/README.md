# Simple Shell Environment - Python Installer Prototype

A clean, modern Python-based installer for setting up a beautiful shell environment with Zsh, Oh My Zsh, and Powerlevel10k.

## Features

- **Pure Python Implementation**: No external dependencies beyond Python 3.6+
- **Cross-Platform Support**: WSL2, Native Linux, macOS
- **Modular Design**: Clean separation of concerns with dedicated modules
- **Smart Backup**: Automatic backup of existing configurations
- **Font Management**: Automatic installation of recommended Powerlevel10k fonts
- **Error Handling**: Robust error handling with recovery options

## Quick Start

```bash
# Clone or download the prototype
cd prototypes/python-installer

# Run the installer
python3 install.py

# Or if python3 is not available
python install.py
```

## What It Does

1. **Platform Detection**: Automatically detects your environment (WSL2, Linux, macOS)
2. **Backup**: Creates timestamped backups of existing shell configurations
3. **Dependencies**: Installs required system packages (zsh, git, curl, fonts)
4. **Oh My Zsh**: Downloads and installs Oh My Zsh framework
5. **Powerlevel10k**: Installs and configures the Powerlevel10k theme
6. **Plugins**: Installs useful plugins (autosuggestions, syntax-highlighting)
7. **Fonts**: Downloads and installs MesloLGS NF fonts
8. **Configuration**: Creates comprehensive .zshrc and .p10k.zsh files
9. **Shell Setup**: Attempts to set Zsh as default shell

## Project Structure

```
python-installer/
├── install.py              # Main installer script
├── lib/
│   ├── platform.py         # Platform detection and utilities
│   ├── shell.py            # Shell management (Oh My Zsh, P10k)
│   ├── fonts.py            # Font installation and management
│   ├── backup.py           # Backup and restore functionality
│   └── installer.py        # Base installer class
└── templates.py            # Configuration templates
```

## Module Overview

### Platform Detection (`lib/platform.py`)
- Detects OS type and package manager
- Provides platform-specific configurations
- Handles system dependency installation

### Shell Manager (`lib/shell.py`)
- Oh My Zsh installation and updates
- Powerlevel10k theme management
- Zsh plugin installation
- Configuration file creation

### Font Manager (`lib/fonts.py`)
- Downloads Powerlevel10k recommended fonts
- Handles platform-specific font directories
- Provides font configuration instructions

### Backup Manager (`lib/backup.py`)
- Creates timestamped backups
- Supports selective restore
- Configuration validation
- Backup cleanup utilities

## Configuration Templates

The installer creates comprehensive configuration files:

- **`.zshrc`**: Full-featured Zsh configuration with plugins, aliases, and functions
- **`.p10k.zsh`**: Powerlevel10k configuration optimized for development

## Supported Platforms

| Platform | Package Manager | Status |
|----------|-----------------|--------|
| WSL2 Ubuntu | apt | ✅ Full support |
| Native Linux (Ubuntu/Debian) | apt | ✅ Full support |
| Native Linux (Fedora) | dnf | ✅ Full support |
| macOS | brew | ✅ Full support |

## Alternative Installation

For environments without direct Python access:

```bash
# Use the alternative installer
../alternatives.sh --cloud
```

## Advanced Usage

```bash
# Check requirements only
python3 install.py --help

# View verbose output
python3 install.py -v

# Continue on errors
python3 install.py --continue-on-error
```

## Backup Management

```python
from lib.backup import BackupManager

# List available backups
manager = BackupManager()
backups = manager.list_backups()

# Restore specific backup
result = manager.restore_backup(backup_path)
```

## Pros and Cons

### Advantages
- **Single Language**: Everything in Python, easier to maintain
- **Rich Libraries**: Full access to Python standard library
- **Cross-Platform**: Better Windows/WSL support than shell scripts
- **Modular**: Easy to test and extend individual components
- **Error Handling**: Sophisticated error recovery
- **Type Safety**: Can add type hints for better development experience

### Disadvantages
- **Python Dependency**: Requires Python 3.6+ (usually available)
- **Less Universal**: Not as universal as shell scripts
- **Complexity**: More files and structure than a single script

## Customization

### Adding New Platforms
1. Extend `PlatformDetector` in `lib/platform.py`
2. Add platform-specific logic in other modules

### Adding New Shells
1. Create new shell manager in `lib/shell.py`
2. Add shell-specific templates in `templates.py`

### Adding New Themes
1. Extend theme installation logic in `lib/shell.py`
2. Add theme-specific configuration templates

## Testing

```bash
# Test platform detection
python3 -c "from lib.platform import PlatformDetector; print(PlatformDetector().info)"

# Test backup functionality
python3 -c "from lib.backup import BackupManager; print(BackupManager().list_backups())"

# Validate configurations
python3 -c "from lib.backup import ConfigValidator; print(ConfigValidator.validate_zshrc('.zshrc'))"
```

## Migration from Current Setup

To migrate from your current Ansible-based setup:

1. **Backup Current**: Run current backup procedures
2. **Test Prototype**: Test in isolated environment first
3. **Compare Outputs**: Ensure feature parity
4. **Gradual Migration**: Move one component at a time

This prototype demonstrates how Python can simplify your installation process while maintaining all the functionality of your current Ansible setup.