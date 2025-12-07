# Simple Shell Environment - Hybrid Installer Prototype

A hybrid installer combining the simplicity of shell scripts for system detection with the power of Python for installation logic.

## Features

- **Shell Script Frontend**: Easy-to-understand entry point with system detection
- **Python Backend**: Robust installation logic with error handling
- **Platform Detection**: Automatic detection of WSL2, Linux, and macOS
- **Dependency Management**: Automatic installation of required system packages
- **Smart Backup**: Comprehensive backup and restore functionality
- **Alternative Methods**: Support for Docker, cloud environments, and manual installation

## Quick Start

```bash
# Run the hybrid installer
./install.sh

# Check system requirements only
./install.sh --check-only

# Skip dependency installation
./install.sh --skip-deps

# Force installation despite warnings
./install.sh --force

# Show help
./install.sh --help
```

## Architecture

```
hybrid-installer/
├── install.sh              # Shell script frontend (entry point)
├── setup.py                # Python backend (main logic)
├── lib/                    # Shared Python modules
│   ├── platform.py         # Platform detection
│   ├── shell.py            # Shell configuration
│   ├── fonts.py            # Font management
│   ├── backup.py           # Backup functionality
│   ├── templates.py        # Configuration templates
│   └── installer.py        # Base installer class
└── README.md               # This file
```

## How It Works

### Shell Script Frontend (`install.sh`)

The shell script handles:
- **Initial platform detection**
- **System dependency installation**
- **Python availability checking**
- **User interaction and option parsing**
- **Error handling for system-level operations**

### Python Backend (`setup.py`)

The Python backend handles:
- **Complex installation logic**
- **Configuration file generation**
- **Font management**
- **Backup and restore operations**
- **Detailed error reporting**

## Installation Flow

1. **Shell Script Entry**: `install.sh` starts and detects the platform
2. **System Preparation**: Installs required packages (zsh, git, python3)
3. **Python Check**: Verifies Python 3.6+ availability
4. **Backend Handoff**: Transfers control to `setup.py`
5. **Installation Logic**: Python handles the complex installation steps
6. **Completion**: Shell script provides final user instructions

## Supported Platforms

| Platform | Shell Detection | Python Backend | Status |
|----------|-----------------|----------------|--------|
| WSL2 Ubuntu | ✅ | ✅ | Full support |
| Native Linux | ✅ | ✅ | Full support |
| macOS | ✅ | ✅ | Full support |
| Docker | ✅ | ✅ | Via alternatives |
| Cloud IDEs | ✅ | ✅ | Via alternatives |

## Alternative Installation Methods

When the standard environment isn't available:

```bash
# Show alternative installation options
../alternatives.sh

# Docker-based installation
../alternatives.sh --docker

# Cloud environment setup
../alternatives.sh --cloud

# WSL setup instructions
../alternatives.sh --wsl-setup

# Create portable installer
../alternatives.sh --portable

# Manual installation steps
../alternatives.sh --manual
```

## Command Line Options

### Shell Script Options

```bash
./install.sh [OPTIONS]

-c, --check-only        Only check system requirements
-s, --skip-deps         Skip system dependency installation  
-f, --force             Force installation despite warnings
-h, --help              Show help information
--alternatives          Show alternative installation methods
```

### Python Backend Options

```bash
python3 setup.py [OPTIONS]

--continue-on-error     Continue installation if steps fail
--docker-mode           Run in Docker container mode
--cloud-mode           Run in cloud environment mode
-v, --verbose          Enable verbose output
```

## Example Usage Scenarios

### Standard Installation
```bash
# Full automatic installation
./install.sh
```

### Development/Testing
```bash
# Check what would be installed
./install.sh --check-only

# Install without changing system packages
./install.sh --skip-deps
```

### Troubleshooting
```bash
# Force installation and continue on errors
./install.sh --force
python3 setup.py --continue-on-error --verbose
```

### Cloud Environments
```bash
# GitHub Codespaces, GitPod, etc.
../alternatives.sh --cloud
```

### Docker Development
```bash
# Install in isolated Docker container
../alternatives.sh --docker
```

## Advantages of Hybrid Approach

### Shell Script Benefits
- **Universal**: Works on any Unix-like system
- **Simple**: Easy to understand and debug
- **Fast**: Quick system detection and setup
- **Familiar**: Developers comfortable with shell scripts

### Python Backend Benefits
- **Robust**: Better error handling and recovery
- **Maintainable**: Modular, testable code
- **Cross-platform**: Better Windows/WSL support
- **Rich functionality**: Complex operations made simple

### Combined Strengths
- **Best of both worlds**: Simple entry point + powerful backend
- **Progressive enhancement**: Falls back gracefully
- **User-friendly**: Clear error messages and guidance
- **Flexible**: Multiple installation paths

## Migration Strategy

For migrating from your current Ansible setup:

1. **Parallel Development**: Run both systems during transition
2. **Component Migration**: Move one Ansible role at a time
3. **Feature Parity**: Ensure all current features work
4. **User Testing**: Test with different environments
5. **Gradual Rollout**: Deploy to subset of users first

## Customization

### Adding New Platforms

1. **Shell Script**: Add detection logic to `detect_platform()` function
2. **Python Backend**: Extend `PlatformDetector` class
3. **Testing**: Verify both components work together

### Adding New Features

1. **Shell Script**: Add command-line options as needed
2. **Python Backend**: Implement logic in appropriate modules
3. **Integration**: Ensure parameters passed correctly

### Configuration Templates

Modify templates in `lib/templates.py`:
- **Shell configurations**: .zshrc, .p10k.zsh
- **Alternative installers**: Portable scripts
- **Platform-specific**: Custom configurations

## Troubleshooting

### Common Issues

**Python not found**:
```bash
# Install Python first
./install.sh --check-only
```

**Permission denied**:
```bash
# Make scripts executable
chmod +x install.sh setup.py
```

**Package manager issues**:
```bash
# Skip system dependencies
./install.sh --skip-deps
```

### Debug Mode

```bash
# Verbose shell script
bash -x install.sh

# Verbose Python backend
python3 setup.py --verbose
```

## Comparison with Pure Approaches

| Aspect | Pure Shell | Pure Python | Hybrid |
|--------|------------|-------------|---------|
| Platform Detection | Good | Excellent | Excellent |
| Error Handling | Basic | Excellent | Excellent |
| User Experience | Simple | Complex | Simple |
| Maintainability | Hard | Easy | Medium |
| Dependencies | None | Python | Python |
| Debugging | Hard | Easy | Medium |
| Universality | High | Medium | High |

## Future Enhancements

- **GUI Support**: Add optional GUI installer
- **Configuration Wizard**: Interactive configuration setup
- **Plugin System**: Allow third-party extensions
- **Remote Installation**: Install on remote systems
- **Containerization**: Full Docker integration

This hybrid approach gives you the simplicity users expect with the power and reliability you need for maintaining a complex shell environment setup.