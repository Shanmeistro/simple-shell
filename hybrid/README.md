# Simple Shell Environment - Hybrid Installer

A simplified, user-friendly shell environment installer that combines the best of both worlds: shell script simplicity with Python's advanced error handling and cross-platform compatibility.

## 🚀 Quick Start

```bash
./install.sh
```

The installer will guide you through an interactive setup process to customize your shell environment.

## ✨ Features

### **Interactive Configuration**
- **Shell Choice**: Bash or Zsh
- **Framework Options**: Oh My Zsh, Bash-it, or minimal setup
- **Prompt Themes**: Powerlevel10k, Starship, Oh My Posh, or default
- **Font Installation**: Automatic Nerd Font installation
- **Backup System**: Automatic backup of existing configurations

### **Supported Platforms**
- ✅ WSL2 (Ubuntu/Debian)
- ✅ Native Linux (Ubuntu, RHEL, Arch, etc.)
- ✅ macOS (with Homebrew)

### **IDE/Terminal Compatibility**
- ✅ VS Code (local and remote)
- ✅ JetBrains IDEs (IntelliJ, PyCharm, etc.)
- ✅ Windows Terminal
- ✅ iTerm2, Alacritty, and other modern terminals
- ✅ SSH and remote development

## 🛠 Installation Options

### Option 1: Interactive Setup (Recommended)
```bash
./install.sh
```

### Option 2: Direct Python Backend
```bash
python3 setup.py config.json
```

## 📋 Configuration Matrix

| Shell | Framework | Prompt | Compatibility | Notes |
|-------|-----------|--------|---------------|-------|
| **Zsh** | Oh My Zsh | Powerlevel10k | ⭐⭐⭐⭐⭐ | Most popular, feature-rich |
| **Zsh** | Oh My Zsh | Starship | ⭐⭐⭐⭐ | Modern, cross-shell |
| **Zsh** | None | Starship | ⭐⭐⭐⭐ | Minimal, fast |
| **Bash** | Bash-it | Starship | ⭐⭐⭐⭐ | Enhanced bash experience |
| **Bash** | None | Starship | ⭐⭐⭐⭐⭐ | Clean, modern |
| **Bash** | None | Oh My Posh | ⭐⭐⭐ | Colorful, Windows-friendly |

## 🎨 Prompt Themes

### **Powerlevel10k** (Zsh only)
- **Best for**: Zsh users who want the most feature-rich experience
- **Features**: Git status, command timing, system info, highly customizable
- **Fonts**: MesloLGS NF (automatically installed)
- **Performance**: Extremely fast
- **IDE Support**: Excellent

### **Starship** (Cross-shell)
- **Best for**: Users who want consistency across different shells
- **Features**: Git status, language detection, modern symbols
- **Fonts**: Any Nerd Font (FiraCode, JetBrains Mono installed)
- **Performance**: Very fast
- **IDE Support**: Excellent
- **Preset**: Nerd Font Symbols (automatically configured)

### **Oh My Posh** (Cross-shell, Windows-optimized)
- **Best for**: Bash users, Windows/WSL2 environments
- **Features**: Themes, segments, Windows integration
- **Fonts**: Nerd Fonts (automatically installed)
- **Performance**: Good
- **Preset**: 1_shell theme (clean, informative)
- **IDE Support**: Good

## 🔧 Advanced Usage

### Manual Configuration
Create a `config.json` file:

```json
{
    "shell": "zsh",
    "framework": "oh-my-zsh",
    "prompt": "powerlevel10k",
    "backup": true,
    "install_fonts": true,
    "set_default": true,
    "platform": "wsl2"
}
```

Then run:
```bash
python3 setup.py config.json
```

### Framework-less Setup
For minimal overhead:
```json
{
    "shell": "bash",
    "framework": "none",
    "prompt": "starship",
    "backup": true,
    "install_fonts": true,
    "set_default": true
}
```

## 🎯 WSL2 Specific Features

### **Windows Integration**
- `open .` - Open current directory in Windows Explorer
- `code .` - Launch VS Code from WSL2
- `wsl-ip` - Get WSL2 IP address

### **Font Configuration**
The installer automatically:
1. Downloads and installs appropriate Nerd Fonts
2. Provides Windows Terminal font configuration guidance
3. Ensures proper symbol rendering in IDEs

### **IDE Support**
Optimized for:
- **VS Code Remote-WSL**: Full theme and symbol support
- **JetBrains Gateway**: Remote development compatibility
- **Windows Terminal**: Native font and color support

## 🔍 Troubleshooting

### Python Not Found
The installer will attempt to install Python 3.6+ automatically. If this fails:

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install python3 python3-pip
```

**macOS:**
```bash
brew install python3
```

### Font Issues
If symbols don't display correctly:

1. **Windows Terminal**: Settings → Profiles → Font face → Select a Nerd Font
2. **VS Code**: Settings → Terminal → Font Family → Use a Nerd Font
3. **JetBrains IDEs**: Settings → Editor → Font → Choose a Nerd Font

### Shell Not Changing
If the default shell doesn't change automatically:
```bash
chsh -s $(which zsh)  # or bash
```

### Framework Issues
If Oh My Zsh or Bash-it installation fails, you can still use the prompt themes without frameworks:
- Choose \"None\" for framework
- Select Starship or Oh My Posh for prompt

## 📁 Project Structure

```
hybrid/
├── install.sh                 # Shell frontend (user interface)
├── setup.py                  # Python backend (main installer)
├── lib/                      # Python modules
│   ├── installer.py          # Main installer class
│   ├── platform.py           # Platform detection and system utils
│   ├── shell.py              # Shell and framework management
│   ├── fonts.py              # Font installation and management
│   ├── backup.py             # Backup and restoration
│   └── templates.py          # Configuration templates
└── README.md                 # This file
```

## 🔄 Backup and Recovery

### Automatic Backups
The installer automatically creates timestamped backups:
```
~/.config/shell-backup-20231207-143022/
├── .bashrc
├── .zshrc
├── .oh-my-zsh/
└── backup_manifest.txt
```

### Manual Backup Restoration
```python
from lib.backup import BackupManager

backup = BackupManager()
backups = backup.list_backups('shell')
backup.restore_backup(backups[0])  # Restore latest
```

## 🎯 Design Philosophy

### **Simplicity First**
- Single command installation
- Interactive configuration
- Sensible defaults
- Clear error messages

### **Cross-platform Compatibility**
- Works on WSL2, Linux, and macOS
- IDE and terminal agnostic
- Consistent experience across platforms

### **Modular Architecture**
- Shell frontend for familiarity
- Python backend for sophisticated logic
- Modular classes for maintainability
- Clean separation of concerns

### **User Choice**
- Every component is optional
- Multiple framework and theme options
- Framework-less minimal setups available
- Easy customization post-install

## 🛡 Safety Features

- **Automatic backups** before any changes
- **Dry-run capability** for testing
- **Error recovery** with detailed messages
- **Rollback support** via backup system
- **Non-destructive installation** (existing configs preserved)

## 🔮 Future Enhancements

- **Custom theme builder** for advanced users
- **Plugin marketplace** for framework extensions
- **Configuration migration** tools between setups
- **Cloud sync** for settings across machines

## 📝 Contributing

This hybrid installer is designed to be simple and maintainable. Key principles:

1. **Shell script handles UX** (user interaction, platform detection)
2. **Python handles logic** (installation, error handling, configuration)
3. **Modular classes** for easy testing and extension
4. **Clear separation** between frontend and backend

## 📄 License

MIT License - feel free to modify and distribute.

---

**Simple Shell Environment** - Making shell customization accessible to everyone! 🚀