# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/) (optional, but good to know).

## [0.1.4] - 2025-12-07

### Added

- **🖥️ Platform-Specific Configuration Scripts**:
  - **Linux Platform** (`linux/`): Complete development environment setup for Debian-based distributions
    - Interactive `bootstrap.sh` with shell and tool selection
    - Core package installation via apt with modern CLI tools (exa, bat, ripgrep, fd, fzf)
    - Enhanced Zsh setup with Oh My Zsh + Powerlevel10k + useful plugins
    - Enhanced Bash setup with Bash-it framework + Starship prompt
    - Docker Engine installation with Docker Compose and container tools
    - Kubernetes ecosystem: kubectl, Helm, k9s, kubectx/kubens
    - Node.js with multiple package managers (npm, yarn, pnpm)

  - **macOS Platform** (`macos/`): Comprehensive setup for macOS 11-15 with Apple Silicon support
    - Architecture-aware installation (Intel x86_64 and Apple Silicon ARM64)
    - Homebrew-based package management with Cask support
    - Xcode Command Line Tools automatic installation
    - Enhanced shell environments with Nerd Fonts integration
    - Docker Desktop with additional container utilities
    - macOS-specific aliases and system integration features

- **🌟 Optional Development Environment Installers**:
  - **Python**: pyenv + poetry + scientific packages (pandas, numpy, matplotlib)
  - **Go**: Latest Go + comprehensive development toolchain
  - **Rust**: rustup + cargo ecosystem + modern CLI replacements
  - **Java**: SDKMAN! + multiple JDK versions (11, 17, 21 LTS) + build tools

- **🛠️ Platform-Specific Helper Systems**:
  - Linux: Distribution detection, package management functions, dependency handling
  - macOS: Version compatibility checking, Homebrew architecture detection, app installation

- **📚 Comprehensive Documentation**:
  - Platform-specific README files with usage examples and troubleshooting
  - System requirements and compatibility matrices
  - Post-installation configuration guides
  - Architecture-specific notes for Apple Silicon vs Intel Macs

### Changed

- **🔧 Updated Root-Level Tool Manager**:
  - Enhanced `manage_optional_tools.sh` with restored security tools support
  - Added essential DevOps security tools: nmap, nikto, hydra, sqlmap, john, hashcat, wireshark-cli
  - Improved cross-platform compatibility with Linux and macOS platform scripts

- **📁 Repository Structure Enhancement**:
  - Organized platform-specific scripts in dedicated `linux/` and `macos/` folders
  - Consistent script structure across all platforms (bootstrap → core → shell → optional)
  - Unified naming conventions and executable permissions

### Technical Improvements

- **🔄 Cross-Platform Consistency**: Same installation flow as existing WSL2 setup
- **🎯 Architecture Support**: Native Apple Silicon support with Intel compatibility
- **📦 Package Management**: Platform-appropriate package managers (apt, Homebrew, SDKMAN!, pyenv, nvm, rustup)
- **🧪 Version Management**: Multiple language versions with easy switching capabilities
- **🛡️ Error Handling**: Comprehensive error checking and rollback capabilities

### Platform Support Matrix

| Feature | Linux (Debian) | macOS 11-15 | WSL2 |
|---------|----------------|-------------|------|
| Shell Enhancement | ✅ Zsh + Bash | ✅ Zsh + Bash | ✅ Zsh + Bash |
| Docker | ✅ Engine | ✅ Desktop | ✅ Engine |
| Node.js | ✅ nvm | ✅ nvm | ✅ nvm |
| Python | ✅ pyenv | ✅ pyenv | ✅ pyenv |
| Go | ✅ Official | ✅ Homebrew | ✅ Official |
| Rust | ✅ rustup | ✅ rustup | ✅ rustup |
| Java | ✅ SDKMAN! | ✅ SDKMAN! | ✅ SDKMAN! |
| Kubernetes | ✅ kubectl | ✅ kubectl | ✅ kubectl |

### Security Tools Restoration

- **Rationale**: Restored security tools in `manage_optional_tools.sh` based on DevOps engineer requirements
- **Tools Added**: nmap (network scanning), nikto (web vulnerability scanner), hydra (password cracking), sqlmap (SQL injection), john (password cracking), hashcat (password recovery), wireshark-cli (network analysis)
- **Installation**: Clean installation without complex dependencies or manual configuration

### Developer Experience

- **🚀 Quick Start**: Single command bootstrap for complete environment setup
- **🎨 Customizable**: Modular scripts allowing selective installation
- **🔍 Debugging**: Detailed logging and error reporting for troubleshooting
- **📖 Documentation**: Platform-specific guides with examples and best practices

## [0.1.3] - 2025-10-07

### Added

- **🐚 Multi-Shell Support**:
  - Added Fish shell support with Starship and Oh My Posh integration
  - Added Nushell support with modern structured data capabilities
  - Enhanced Bash support with improved Starship configuration
  - Maintained comprehensive Zsh support with all framework options

- **🎨 Expanded Prompt Framework Support**:
  - **Oh My Posh**: Cross-shell prompt engine with JSON theme configuration
  - **Spaceship**: Minimalistic Zsh prompt with clean design and Git integration
  - **Zim**: Fast, modular Zsh framework with optimized startup times
  - **Prezto**: Comprehensive Zsh configuration framework with extensive modules
  - Maintained existing Starship and Powerlevel10k support

- **🔤 Framework-Aware Font Management**:
  - Smart font recommendations based on selected prompt framework
  - Powerlevel10k optimized fonts: MesloLGS, Hack, FiraCode, CascadiaCode
  - Starship optimized fonts: JetBrainsMono, FiraCode, CascadiaCode, Hack
  - Oh My Posh optimized fonts: CascadiaCode, JetBrainsMono, FiraCode, Hack
  - Automatic font configuration notices and setup instructions

- **🛡️ Enhanced Safety and Backup System**:
  - Comprehensive configuration backup before any changes
  - Support for three installation modes: new, update, and clean install
  - Detection of existing shell configurations (Zsh, Bash, Fish, Nushell)
  - Automatic backup of Oh My Zsh, Powerlevel10k, and Starship configurations
  - Timestamped backup directories for easy recovery

- **📝 Complete Template System**:
  - Dedicated Jinja2 templates for each shell/framework combination
  - `zshrc-p10k.j2`, `zshrc-starship.j2`, `zshrc-omp.j2`, `zshrc-spaceship.j2`
  - `bashrc-starship.j2` for enhanced Bash configuration
  - `fish-starship.fish.j2`, `fish-oh-my-posh.fish.j2` for Fish shell
  - `nushell-starship.nu.j2`, `nushell-oh-my-posh.nu.j2` for Nushell
  - `font-setup-notice.md.j2` for framework-specific font guidance

### Changed

- **🚀 Completely Rewritten Installation Script**:
  - Interactive shell selection with detailed descriptions of each shell's benefits
  - Framework selection based on shell compatibility matrix
  - Automatic Ansible installation with OS detection (Ubuntu 20.04+, macOS)
  - Removed support for older package managers (yum, dnf, pacman) for simplified maintenance
  - Enhanced user experience with color-coded output and progress indicators

- **⚙️ Advanced Ansible Role Architecture**:
  - Completely restructured shell role with multi-framework support
  - Enhanced fonts role with framework-aware recommendations
  - Smart plugin management for different shell configurations
  - Cross-platform installation logic for shells and frameworks
  - Improved error handling and conditional task execution

- **🔧 Streamlined Configuration Management**:
  - Updated `group_vars/all.yml` with new framework options and templates
  - Added backup configuration variables and setup mode support
  - Enhanced font configuration with recommendation mappings
  - Simplified variable structure for easier customization

### Technical Improvements

- **🔄 Idempotent Operations**: All tasks are safe to run multiple times
- **🎯 Conditional Logic**: Smart framework installation based on shell choice
- **📦 Modular Design**: Clear separation between shell, framework, and plugin management
- **🧪 Enhanced Testing**: Improved test script for development and validation
- **📋 Better Documentation**: Comprehensive inline documentation and user guides

### Framework-Specific Features

- **Oh My Zsh + Powerlevel10k**: Enhanced plugin management and theme configuration
- **Starship**: Cross-shell configuration with template support
- **Oh My Posh**: Theme management and cross-shell compatibility
- **Spaceship**: Zsh-specific optimizations and customization options
- **Zim**: Fast startup configuration and module management
- **Prezto**: Comprehensive module system and configuration linking

### Platform Support

- **Ubuntu 20.04+**: Full support with apt package management
- **macOS**: Homebrew integration for all tools and shells
- **WSL2**: Tested compatibility with Windows Subsystem for Linux
- **Removed**: Legacy Linux distributions for focused maintenance

### Developer Experience

- **Enhanced Test Suite**: Comprehensive dry-run testing capabilities
- **Better Error Messages**: Clear troubleshooting guidance and log information
- **Modular Templates**: Easy addition of new shell/framework combinations
- **Configuration Validation**: Ansible syntax checking and variable validation

## [0.1.2] - 2025-10-05

### Added

- **Comprehensive Nerd Fonts Management System**:
  - New standalone [manage_fonts.sh](http://_vscodecontentref_/5) script with full cross-platform support (Linux, macOS, Windows, WSL)
  - Interactive and command-line interfaces for font installation/uninstallation
  - Support for multiple font selection and bulk operations
  - Automatic font cache refresh and backup functionality
  - WSL integration for dual Linux/Windows font installation
  - Ansible integration with proper JSON output mode

- **Enhanced Font Collection**:
  - Added JetBrains Mono, Hack, Source Code Pro, Ubuntu Mono, DejaVu Sans Mono, and Inconsolata Nerd Fonts
  - Organized font variants (Regular, Mono, Proportional) with clear labeling
  - Font recommendations optimized for Powerlevel10k and Starship configurations

- **Improved Shell Installation Experience**:
  - Enhanced font installation option as second menu item in main installer
  - Better font family selection with descriptions and installation status
  - Post-installation guidance with terminal configuration instructions
  - Cross-platform font directory detection and management

- **Advanced Font Management Features**:
  - Font backup system with timestamp-based versioning
  - Safe uninstallation with confirmation prompts
  - Font status reporting and system information display
  - Comprehensive logging for troubleshooting

### Changed

- **Enhanced [install_custom_shell.sh](http://_vscodecontentref_/6)**:
  - Restructured main menu to prominently feature font installation
  - Improved font selection UI with better status indicators
  - Added support for multiple font installation modes
  - Better error handling and user feedback

- **Ansible Integration**:
  - Added dedicated font management role with configurable font lists
  - Support for selective font installation via group variables
  - Proper task tagging for font-specific operations

### Technical Improvements

- Cross-platform font directory management
- Improved detection of WSL environments
- Better font cache management across different operating systems
- Enhanced logging and debugging capabilities
- Modular design allowing standalone or integrated usage

## [0.1.1] - 2025-07-28

### Added

- Enhanced [manage_optional_tools.sh](http://_vscodecontentref_/7) with:
  - Custom Docker and Terraform install/uninstall functions using official repository steps.
  - Options to check if a tool is installed, check its version, and update it (apt-get only).
  - Improved menu-driven interface for tool management.
- Added helper functions for version and update checks.
- Provided guidance and review for [.tmux.conf](http://_vscodecontentref_/8) to help new users, including color scheme troubleshooting and minimal config recommendations.

### Changed

- Refactored [manage_optional_tools.sh](http://_vscodecontentref_/9) to integrate advanced tool management and user feedback.
- Updated [.tmux.conf](http://_vscodecontentref_/10) recommendations for better usability and default color scheme restoration.

### Fixed

- Addressed issues with overly bright tmux color schemes by clarifying which config lines to comment/remove for defaults.

## [0.1.0] - 2025-05-05

### Added

- Initial Ansible setup with roles for common utilities, shell configuration, sysadmin tools, and dev tools.
- Interactive [install_custom_shell.sh](http://_vscodecontentref_/11) script for initial setup and shell/prompt selection.
- [manage_optional_tools.sh](http://_vscodecontentref_/12) script for managing additional tools.
- Basic `tmux` configuration (see `tmux.conf`).
- Support for Bash and Zsh shells.
- Support for Starship and Powerlevel10k prompt frameworks.
- Installation of essential DevOps, Full Stack, and AI/ML development tools.
- Tagging added to Ansible roles for selective execution.

### Removed

- Removed Jinja2 templates for initial simplicity. These may be reintroduced later.
- Removed the `manage_packages.py` script.
- Removed the `dotfiles` folder (except for the `tmux.conf`).

### Changed

- Simplified the `group_vars/all.yml` to focus on core configurations.
- Streamlined the Ansible roles for clarity and error handling.
- Updated [README.md](http://_vscodecontentref_/13) to reflect the current setup.

---

## [Unreleased] - Future

### Planned

- Windows native support (PowerShell integration)
- Additional shell support (elvish, xonsh)
- Cloud development environment templates
- Container-based development setups
- Plugin system for custom extensions

---

**Note:** This project follows semantic versioning. Major version changes indicate breaking changes, minor versions add new features, and patch versions include bug fixes and improvements.
