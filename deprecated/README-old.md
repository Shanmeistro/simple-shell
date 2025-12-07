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

### Shells
- **Bash** - Reliable and well-documented (Starship only)
- **Zsh** - Feature-rich with excellent tab completion (All frameworks)
- **Fish** - User-friendly with smart autosuggestions (Starship, Oh My Posh)
- **Nushell** - Modern shell with structured data support (Starship, Oh My Posh)

### Prompt Frameworks
- **Oh My Zsh + Powerlevel10k** - Feature-rich Zsh framework with beautiful prompts
- **Oh My Posh** - Cross-shell prompt engine with modern themes
- **Starship** - Fast, cross-shell prompt (minimal setup, blazing fast)
- **Spaceship** - Minimalistic Zsh prompt with clean design
- **Zim** - Modular Zsh framework with fast startup
- **Prezto** - Zsh configuration framework with sane defaults

---

## 🛠️ Prerequisites

**Supported Operating Systems:**
- Ubuntu 20.04 or higher
- macOS (with Homebrew recommended)
- WSL2 with Ubuntu

**System Requirements:**
- Git (for cloning repository)
- Sudo privileges (for package installation)
- Internet connection (for downloads)

**Note:** The installer will automatically check for and install Ansible if not present.

---

## ⚙️ Quick Start

Follow these simple steps to set up your awesome development environment:

### 1. Clone and Enter Repository

```bash
git clone https://github.com/Shanmeistro/simple-shell.git or git@github.com:Shanmeistro/simple-shell.git
cd simple-shell
```

### 2. Run the Installer after making the script executable

```bash
chmod +x install_custom_shell.sh

./install_custom_shell.sh
```

### 3. Follow Interactive Setup

The installer will:

- ✅ Check and install Ansible if needed
- 🔍 Detect existing shell configurations
- 🐚 Help you choose your preferred shell
- 🎨 Guide you through framework selection
- 🔤 Recommend and install appropriate Nerd Fonts
- 🛠️ Optionally configure development tools
- ⚡ Deploy your custom environment

### 4. Apply Changes

After installation:

```bash
# For Bash
source ~/.bashrc

# For Zsh
exec zsh

# For Fish
exec fish

# For Nushell
nu
```

---

## 🎨 Font Management

**Automatic Font Recommendations**

The installer automatically recommends fonts based on your chosen framework:

- **Powerlevel10k:** MesloLGS, Hack, FiraCode, CascadiaCode
- **Starship:** JetBrainsMono, FiraCode, CascadiaCode, Hack
- **Oh My Posh:** CascadiaCode, JetBrainsMono, FiraCode, Hack
- **Others:** JetBrainsMono, FiraCode, CascadiaCode

**Managing Font Management**

```bash
# Interactive font management
./manage_fonts.sh

# Install specific fonts
./manage_fonts.sh install CascadiaCode FiraCode

# List available fonts
./manage_fonts.sh list

# Check installation status
./manage_fonts.sh status
```

**Terminal Configuration**

After font installation, configure your terminal:

**Linux (GNOME Terminal):**
Preferences → Profiles → Text
Enable "Custom font"
Select a Nerd Font

**macOS (Terminal/iTerm2):**
Preferences → Profiles → Text/Font
Choose a Nerd Font

**Windows/WSL:**
Windows Terminal Settings
Profiles → Appearance → Font face
Select a Nerd Font

---

## 💻 Advanced Usage

**Dry Run (Test Mode)**

See what changes would be made without applying them:

```bash
./install_custom_shell.sh --check
```

**Direct Ansible Execution**

For advanced users who want more control:

```bash
# Run specific roles
ansible-playbook ansible/custom_dev_env.yml \
  --ask-become-pass \
  --tags "shell,fonts" \
  --extra-vars "preferred_shell=/usr/bin/zsh prompt_framework=starship"

# Available tags: common, shell, fonts, sysadmin-tools, devtools
```

**Setup Modes**

The installer detects existing configurations and offers:

- **New Install** - Fresh installation on clean system
- **Update Mode** - Modify existing setup (with backup)
- **Clean Install** - Replace existing setup (with backup)

---

## 🔧 Optional Tools

Manage additional development tools separately:

```bash
./manage_optional_tools.sh
```

**Available Tools:**

- **DevOps:** Docker, Kubernetes, Terraform, AWS CLI
- **Languages:** Python tools, Node.js, package managers
- **Utilities:** tmux, ripgrep, jq, and more

---

## 📂 Project Structure

```tree
simple-shell/
├── install_custom_shell.sh     # Main installer script
├── test_playbook.sh            # Development testing
├── manage_fonts.sh             # Font management
├── manage_optional_tools.sh    # Optional tools
├── ansible/
│   ├── custom_dev_env.yml      # Main playbook
│   ├── group_vars/
│   │   └── all.yml             # Configuration variables
│   └── roles/
│       ├── common/             # Basic system setup
│       ├── shell/              # Shell and prompt configuration
│       ├── fonts/              # Font management
│       ├── devtools/           # Development tools
│       └── sysadmin-tools/     # System utilities
├── starship_templates/         # Starship configurations
├── p10k_templates/            # Powerlevel10k configurations
└── nerd_fonts/                # Font collection
```

---

## ⚙️ Customization

**Configuration Variables**

Edit `all.yml` to customize:

```yaml
# Shell preferences
preferred_shell: "/usr/bin/zsh"
prompt_framework: "starship"

# Font configuration
nerd_fonts_to_install:
  - CascadiaCode
  - FiraCode
  - JetBrainsMono

# Template selection
starship_template: "tokyo-night"
p10k_template: "p10k-rainbow"

# Tool installation flags
install_docker: true
install_terraform: true
python_versions: ["3.8", "3.11"]
```

Adding New Templates

**Starship Templates:**
1. Add `.toml` files to starship_templates
2. Reference in `all.yml` as starship_template

**Powerlevel10k Templates:**
1. Add `.zsh` files to p10k_templates
2. Reference in `all.yml` as p10k_template

**Framework-Specific Configuration**

Each shell/framework combination uses dedicated templates:

- `zshrc-p10k.j2` - Zsh + Powerlevel10k
- `zshrc-starship.j2` - Zsh + Starship
- `fish-starship.fish.j2` - Fish + Starship
- `nushell-starship.nu.j2` - Nushell + Starship

---

## 🔍 Troubleshooting

Common Issues

**Ansible Not Found:**

```bash
# The installer will offer to install Ansible automatically
# Or install manually:
sudo apt update && sudo apt install ansible  # Ubuntu
brew install ansible                         # macOS
```

**Permission Errors:**

```bash
# Ensure scripts are executable
chmod +x install_custom_shell.sh
chmod +x manage_fonts.sh
chmod +x manage_optional_tools.sh
```

**Font Issues:**

```bash
# Check font installation
fc-list | grep -i nerd  # Linux
# Font Book app          # macOS

# Refresh font cache
fc-cache -f -v          # Linux
# Restart terminal       # macOS
```

**Shell Not Switching:**

```bash
# Set default shell manually
chsh -s /usr/bin/zsh    # For Zsh
chsh -s /usr/bin/fish   # For Fish

# Or restart terminal and run
exec zsh                # Start Zsh
exec fish               # Start Fish
```

**Debug Mode**

For development and troubleshooting:

```bash
# Test ansible syntax
ansible-playbook ansible/custom_dev_env.yml --syntax-check

# Run in check mode with verbosity
ansible-playbook ansible/custom_dev_env.yml --check -vv

# Test specific roles
./test_playbook.sh
```

**Log Files**

Check these locations for detailed logs:

- nerd-fonts-manager.log - Font installation logs
- `~/.config_backups/` - Configuration backups
- Ansible output during installation

**🛡️ Safety Features**

- **Automatic Backups:** All existing configurations are backed up before changes
- **Dry Run Mode:** Test installations without making changes
- **Idempotent Operations:** Safe to run multiple times
- **Rollback Support:** Backup configurations can be easily restored
- **Smart Detection:** Avoids overwriting existing setups without permission

**🧪 Testing**

For developers and contributors:

```bash
# Quick syntax and dry-run test
./test_playbook.sh

# Test specific configurations
ansible-playbook ansible/custom_dev_env.yml \
  --check \
  --extra-vars "preferred_shell=/usr/bin/zsh prompt_framework=starship"
```

---

## 🤝 Contributing

Contributions are welcome! Areas for improvement:

- **New Shell Support:** Add support for additional shells
- **Framework Integration:** New prompt frameworks or themes
- **Platform Support:** Additional operating systems
- **Template Improvements:** Better default configurations
- **Documentation:** Usage examples and guides

Development Setup

```bash
# Clone and create development environment
git clone <your-fork>
cd simple-shell

# Create Python virtual environment for testing
python3 -m venv .venv
source .venv/bin/activate
pip install ansible

# Run tests
./test_playbook.sh
```

---

## 📄 License

This project is open source. Feel free to use, modify, and distribute according to your needs.

---

## 🙏 Acknowledgments

- **Starship:** - The minimal, blazing-fast prompt
- **Powerlevel10k** - A fast reimplementation of Powerlevel9k
- **Oh My Posh** - A prompt theme engine for any shell
- **Nerd Fonts** - Iconic font aggregator and patcher
- **Fish Shell** - A smart and user-friendly command line shell
- **Nushell** - A new type of shell

---

Created with ❤️ by Shanmeistro - 2025

*Making beautiful, functional development environments accessible to everyone!*
