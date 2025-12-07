# Simple Shell Environment - Prototypes

This directory contains two prototype implementations for simplifying your shell environment setup, moving away from the Ansible-based approach to more streamlined solutions.

## 🎯 Goal

Simplify the installation process while maintaining functionality:
- **Reduce complexity**: Fewer dependencies and moving parts
- **Improve maintainability**: Cleaner, more focused code
- **Better user experience**: Simpler installation process
- **Platform support**: WSL2, Native Linux, macOS

## 📁 Prototypes Overview

### Option B: Python-Based Installer
**Location**: `python-installer/`

A pure Python implementation that handles everything in a single language.

**Advantages**:
- Single language (Python) for everything
- Rich standard library for file operations, networking, etc.
- Excellent cross-platform support
- Easy to test and debug
- Modular, object-oriented design

**Best for**: When you want modern, maintainable code and don't mind Python dependency

### Hybrid Approach: Shell + Python
**Location**: `hybrid-installer/`

Combines shell script entry point with Python backend for complex operations.

**Advantages**:
- Familiar shell script interface
- Python power for complex logic
- Progressive enhancement approach
- Best of both worlds

**Best for**: When you want shell script familiarity but need Python's capabilities

## 🚀 Quick Comparison

| Feature | Current Ansible | Python-Based | Hybrid | 
|---------|-----------------|--------------|--------|
| **Dependencies** | Ansible + Python | Python 3.6+ | Python 3.6+ |
| **Complexity** | High (multiple files) | Medium | Medium |
| **Entry Point** | Shell script | Python script | Shell script |
| **Maintainability** | Complex YAML | Good | Good |
| **User Familiarity** | Shell script | Python script | Shell script |
| **Cross-platform** | Good | Excellent | Excellent |
| **Error Handling** | Ansible-based | Comprehensive | Comprehensive |
| **Modularity** | Ansible roles | Python modules | Python modules |

## 🧪 What Gets Installed

Both prototypes install a simplified but complete shell environment:

### Core Components
- **Shell**: Zsh (primary choice)
- **Framework**: Oh My Zsh
- **Theme**: Powerlevel10k 
- **Fonts**: MesloLGS NF (P10k recommended)
- **Plugins**: autosuggestions, syntax-highlighting

### Removed Complexity
- Multiple shell support (Bash, Fish, Nushell) → Focus on Zsh
- Multiple theme options → Focus on Powerlevel10k
- Multiple font options → Focus on recommended P10k fonts
- Complex templating → Simple, comprehensive configurations

## 🏃 Quick Start

### Test Python-Based Installer
```bash
cd prototypes/python-installer
python3 install.py
```

### Test Hybrid Installer
```bash
cd prototypes/hybrid-installer
./install.sh
```

### Alternative Installation Methods
```bash
cd prototypes
./alternatives.sh --help
```

## 📋 Features Comparison

### ✅ Maintained Features
- Automatic backup of existing configurations
- Cross-platform support (WSL2, Linux, macOS)
- Font installation and management
- Comprehensive shell configuration
- Error handling and recovery
- User-friendly installation process

### 🎯 Simplified Features
- **Single shell focus**: Zsh only (most popular choice)
- **Single theme**: Powerlevel10k (widely adopted)
- **Essential plugins**: Core functionality only
- **Streamlined configuration**: Sensible defaults

### ❌ Removed Complexity
- Multiple shell support (Bash, Fish, Nushell)
- Multiple prompt frameworks (Spaceship, Zim, Prezto, etc.)
- Complex theme selection and templating
- Advanced customization options during installation

## 🏗️ Architecture

### Python-Based (`python-installer/`)
```
install.py                  # Main entry point
├── lib/
│   ├── platform.py        # Platform detection
│   ├── shell.py           # Oh My Zsh + P10k management  
│   ├── fonts.py           # Font installation
│   ├── backup.py          # Backup/restore
│   └── installer.py       # Base installer class
└── templates.py           # Configuration templates
```

### Hybrid (`hybrid-installer/`)
```
install.sh                 # Shell script entry point
├── setup.py               # Python backend
└── lib/                   # Shared Python modules
    ├── platform.py
    ├── shell.py
    ├── fonts.py
    ├── backup.py
    ├── templates.py
    └── installer.py
```

## 🔧 Alternative Installation Options

For environments without native Linux support:

### Docker-Based Installation
```bash
./alternatives.sh --docker
```
Uses Docker container for isolated installation

### Cloud Environment Support
```bash
./alternatives.sh --cloud
```
Optimized for GitHub Codespaces, GitPod, etc.

### WSL Setup Guide
```bash
./alternatives.sh --wsl-setup
```
Step-by-step WSL2 installation instructions

### Portable Installer
```bash
./alternatives.sh --portable
```
Creates a standalone installer script

### Manual Instructions
```bash
./alternatives.sh --manual
```
Step-by-step manual installation guide

## 💾 Backup System

Both prototypes include comprehensive backup functionality:

```python
# Automatic backups before installation
backup_dir = ~/.config/shell-backup-YYYYMMDD-HHMMSS/

# Backup contents
├── .zshrc              # Existing Zsh config
├── .p10k.zsh           # Existing P10k config  
├── oh-my-zsh/          # Complete Oh My Zsh directory
└── fonts/              # Existing custom fonts
```

## 🧪 Testing the Prototypes

### Prerequisites
- Python 3.6+ (for Python-based installer)
- Git (for cloning repositories)
- Internet connection (for downloads)

### Safe Testing
```bash
# Backup current setup first
cp ~/.zshrc ~/.zshrc.backup
cp ~/.p10k.zsh ~/.p10k.zsh.backup

# Test in Docker (safest)
./alternatives.sh --docker

# Test with backup (recommended)
cd prototypes/python-installer
python3 install.py
```

### Validation
```bash
# Check installation
zsh --version
echo $ZSH_THEME
p10k --version

# Verify fonts
fc-list | grep -i meslo
```

## 📊 Migration Path from Current Setup

### Phase 1: Evaluation (Current)
- [x] Create prototypes
- [x] Test core functionality
- [x] Document differences

### Phase 2: Testing
- [ ] Test on different platforms (WSL2, Ubuntu, macOS)
- [ ] Validate feature parity
- [ ] Performance comparison
- [ ] User acceptance testing

### Phase 3: Migration
- [ ] Parallel deployment
- [ ] Gradual feature migration  
- [ ] Documentation updates
- [ ] Old system deprecation

## 🤔 Recommendations

### Choose Python-Based If:
- You prefer modern, maintainable code
- Python dependency is acceptable
- You want the cleanest architecture
- You plan to extend functionality

### Choose Hybrid If:
- You want familiar shell script entry point
- You need both simplicity and power
- You want progressive enhancement
- Your users prefer shell script interfaces

### Stick with Ansible If:
- You need the full complexity of multiple shells/themes
- You're integrating with larger automation workflows
- Your team is heavily invested in Ansible knowledge
- You need enterprise-grade configuration management

## 🛣️ Next Steps

1. **Test both prototypes** in your environment
2. **Compare with current Ansible setup** for feature gaps
3. **Gather feedback** from potential users
4. **Choose implementation** based on your priorities
5. **Plan migration strategy** if moving forward

The prototypes demonstrate that significant simplification is possible while maintaining the core functionality that makes your shell environment setup valuable.