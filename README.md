# ✨ Simple Shell Environment Setup ✨

Welcome to **Simple Shell Environment Setup!** A streamlined, user-friendly installer that creates a consistent, beautiful shell environment across all your development machines. Say goodbye to complex configurations and hello to a ready-to-code setup in minutes!

---

## 📖 Table of Contents

- [🚀 Quick Start](#-quick-start)
- [✨ Features](#-features)
- [🐚 Shell & Framework Options](#-shell--framework-options)
- [🛠️ Prerequisites](#️-prerequisites)
- [🎨 Installation Options](#-installation-options)
- [💻 Platform Support](#-platform-support)
- [🔧 Advanced Usage](#-advanced-usage)
- [📂 Project Structure](#-project-structure)
- [🔍 Troubleshooting](#-troubleshooting)
- [🤝 Contributing](#-contributing)

---

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/Shanmeistro/simple-shell.git
cd simple-shell

# Run the interactive installer
cd hybrid
./install.sh
```

The installer will guide you through selecting your shell, framework, and prompt theme with an interactive menu.

---

## ✨ Features

- **🎯 Simple & Interactive:** One command installation with guided setup
- **🌍 Cross-Platform:** WSL2, Linux, and macOS support
- **🐚 Multi-Shell:** Bash and Zsh with framework options
- **🎨 Multiple Themes:** Powerlevel10k, Starship, Oh My Posh
- **🔤 Smart Fonts:** Automatic Nerd Font installation
- **🛡️ Safe Backups:** Automatic configuration backups
- **🚀 IDE Ready:** Optimized for VS Code, JetBrains IDEs, and terminals
- **⚙️ Fully Optional:** Every component can be customized or skipped

---

## 🐚 Shell & Framework Options

### **Shell Options**

| Shell | Description | Best For |
|-------|-------------|----------|
| **Zsh** | Modern shell with advanced features | Power users, extensive customization |
| **Bash** | Universal shell, widely compatible | Simplicity, broad compatibility |

### **Framework Options**

| Framework | Shell | Description |
|-----------|-------|-------------|
| **Oh My Zsh** | Zsh | Popular framework with extensive plugin ecosystem |
| **Bash-it** | Bash | Bash equivalent of Oh My Zsh |
| **None** | Both | Minimal setup, framework-free |

### **Prompt Themes**

| Theme | Compatibility | Features | Performance |
|-------|---------------|----------|-------------|
| **Powerlevel10k** | Zsh only | Rich info, highly customizable | ⚡ Extremely fast |
| **Starship** | Cross-shell | Modern, consistent | ⚡ Very fast |
| **Oh My Posh** | Cross-shell | Windows-optimized, colorful | 🔄 Good |
| **Default** | Both | Simple, no dependencies | ⚡ Instant |

---

## 🛠️ Prerequisites

- **Python 3.6+** (auto-installed if missing)
- **Git** (for cloning repository)
- **Internet connection** (for downloading components)
- **Terminal with font support** (Windows Terminal, iTerm2, etc.)

---

## 🎨 Installation Options

### **Option 1: Interactive Setup (Recommended)**
```bash
cd hybrid
./install.sh
```

### **Option 2: Direct Configuration**
Create a `config.json` file:
```json
{
    "shell": "zsh",
    "framework": "oh-my-zsh",
    "prompt": "powerlevel10k",
    "backup": true,
    "install_fonts": true,
    "set_default": true
}
```

Then run:
```bash
python3 setup.py config.json
```

### **Option 3: Minimal Setup**
For a lightweight installation:
```json
{
    "shell": "bash",
    "framework": "none",
    "prompt": "starship",
    "backup": true,
    "install_fonts": true,
    "set_default": false
}
```

---

## 💻 Platform Support

### **WSL2** ⭐
- Full Windows Terminal integration
- VS Code Remote-WSL optimized
- Windows filesystem access (`open .`, `code .`)
- Automatic font configuration guidance

### **Native Linux** ⭐
- Ubuntu, Debian, RHEL, Arch support
- Package manager auto-detection
- Terminal emulator compatibility
- SSH and remote development ready

### **macOS** ⭐
- Homebrew integration
- iTerm2 and Terminal.app support
- Apple Silicon and Intel compatibility
- Development tool chain ready

---

## 🔧 Advanced Usage

### **Custom Configurations**

#### **Zsh with Powerlevel10k**
```bash
# After installation, customize Powerlevel10k
p10k configure

# Edit configurations
vim ~/.zshrc
vim ~/.p10k.zsh
```

#### **Bash with Starship**
```bash
# Customize Starship prompt
vim ~/.config/starship.toml

# Edit bash configuration
vim ~/.bashrc
```

#### **Framework Management**
```bash
# Oh My Zsh
omz update                    # Update framework
omz plugin list              # List available plugins

# Bash-it
bash-it show themes          # Show available themes
bash-it enable plugin git    # Enable plugins
```

### **Font Configuration**

#### **Windows Terminal (WSL2)**
1. Open Windows Terminal Settings (`Ctrl + ,`)
2. Navigate to your WSL profile
3. Set font face to a Nerd Font (e.g., "FiraCode Nerd Font")
4. Save and restart terminal

#### **VS Code**
1. Open Settings (`Ctrl + ,`)
2. Search for "terminal font"
3. Set "Terminal › Integrated: Font Family" to a Nerd Font
4. Restart VS Code

#### **JetBrains IDEs**
1. Go to Settings → Editor → Font
2. Select a Nerd Font from the dropdown
3. Apply and restart IDE

### **Backup Management**

The installer automatically creates backups, but you can also manage them manually:

```python
# List available backups
from lib.backup import BackupManager
backup = BackupManager()
backups = backup.list_backups()
print(backups)

# Restore from backup
backup.restore_backup(backups[0])
```

---

## 📂 Project Structure

```
simple-shell/
├── hybrid/                   # Main installer (recommended)
│   ├── install.sh           # Interactive shell frontend
│   ├── setup.py             # Python installation backend
│   ├── lib/                 # Python modules
│   │   ├── installer.py     # Main installer class
│   │   ├── platform.py      # Platform detection
│   │   ├── shell.py         # Shell management
│   │   ├── fonts.py         # Font installation
│   │   ├── backup.py        # Backup system
│   │   └── templates.py     # Configuration templates
│   └── README.md            # Detailed documentation
├── linux/                   # Linux-specific scripts
├── macos/                   # macOS-specific scripts  
├── deprecated/              # Legacy components
│   ├── .ansible/           # Old Ansible setup
│   ├── prototypes/          # Development prototypes
│   ├── wsl2/               # WSL2-specific scripts
│   └── install_custom_shell.sh  # Legacy installer
├── nerd_fonts/              # Font resources
├── p10k_templates/          # Powerlevel10k themes
├── starship_templates/      # Starship configurations
└── README.md               # This file
```

### **Recommended Usage**

The `hybrid/` directory contains the current, actively maintained installer. Other directories are kept for reference or platform-specific needs.

---

## 🔍 Troubleshooting

### **Python Not Found**
The installer will attempt to install Python automatically. If this fails:

**Ubuntu/Debian:**
```bash
sudo apt update && sudo apt install python3 python3-pip
```

**macOS:**
```bash
brew install python3
```

### **Font Issues**
If symbols don't display correctly:

1. **Verify Nerd Font Installation:**
   ```bash
   fc-list | grep -i nerd
   ```

2. **Configure Your Terminal:**
   - Set font to "FiraCode Nerd Font" or "JetBrains Mono Nerd Font"
   - Restart terminal application

3. **VS Code Terminal:**
   - Open Settings → Terminal → Font Family
   - Set to a Nerd Font name

### **Shell Not Changing**
If the default shell doesn't change:
```bash
chsh -s $(which zsh)  # or bash
```
Then restart your terminal.

### **Permission Issues**
Make scripts executable:
```bash
chmod +x hybrid/install.sh hybrid/setup.py
```

---

## 🤝 Contributing

This project follows a simple, maintainable architecture:

1. **Shell script handles UX** (user interaction, platform detection)
2. **Python handles logic** (installation, error handling, configuration)
3. **Modular classes** for easy testing and extension
4. **Clear separation** between frontend and backend

### **Development Setup**
```bash
cd hybrid
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt  # if available
```

### **Adding New Features**
- **Shells/Frameworks:** Extend `lib/shell.py`
- **Themes:** Add to `lib/templates.py`
- **Platforms:** Update `lib/platform.py`
- **Fonts:** Modify `lib/fonts.py`

---

## 🗂️ Migration from Legacy Setup

If you previously used the Ansible-based installer:

1. **Backup Current Setup:**
   ```bash
   cp ~/.zshrc ~/.zshrc.backup
   cp ~/.bashrc ~/.bashrc.backup
   ```

2. **Run New Installer:**
   ```bash
   cd hybrid
   ./install.sh
   ```

3. **The installer will:**
   - Automatically detect existing configurations
   - Create backups before changes
   - Preserve your customizations where possible

---

## 📄 License

MIT License - feel free to modify and distribute.

---

**Simple Shell Environment** - Making shell customization accessible to everyone! 🚀
