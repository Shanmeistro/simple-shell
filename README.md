# simple-shell

A minimal, focused Bash environment installer for Debian-based Linux systems. One command gets you a consistent, clean shell setup across any compatible machine.

---

## Table of Contents

- [Quick Start](#quick-start)
- [What Gets Installed](#what-gets-installed)
- [Platform Support](#platform-support)
- [Project Structure](#project-structure)
- [Optional Tools](#optional-tools)
- [Troubleshooting](#troubleshooting)
- [Roadmap](#roadmap)

---

## Quick Start

```bash
git clone https://github.com/Shanmeistro/simple-shell.git
cd simple-shell/linux
./bootstrap.sh
```

After installation, apply config to your current session:

```bash
source ~/.bashrc
```

---

## What Gets Installed

### Core Packages
Installed via `apt` on first run:

| Category | Packages |
|----------|----------|
| Build tools | `build-essential`, `make` |
| Network | `curl`, `wget`, `net-tools`, `dnsutils` |
| Version control | `git`, `gh` |
| Editors | `vim`, `nano` |
| Utilities | `htop`, `tree`, `tmux`, `rsync`, `jq` |
| Archives | `zip`, `unzip`, `p7zip-full` |
| Security | `ca-certificates`, `gnupg` |

### Bash Configuration (`dotfiles/.bashrc`)

Deployed directly to `~/.bashrc`:

- Sane history settings (`HISTSIZE=10000`, deduplication, append mode)
- Useful `shopt` options (`cdspell`, `dirspell`, `globstar`, `checkwinsize`)
- `bash-completion` integration
- SSH agent auto-start
- Git, Docker, Kubernetes, and navigation aliases
- NVM lazy-loader
- kubectl completion (when available)
- Clean color prompt: `user@host:dir $`

A timestamped backup of any existing `.bashrc` is saved to `~/.config/simple-shell/backups/` before deployment.

---

## Platform Support

| Distribution | Status |
|--------------|--------|
| Ubuntu 20.04+ | Supported |
| Debian 11+ | Supported |
| Pop!_OS | Supported |
| Linux Mint | Supported |
| Kali Linux | Supported |
| Raspberry Pi OS | Supported |
| WSL2 (Ubuntu / Debian) | Supported |
| Other Debian-based | Prompted to continue |

> macOS is not supported in this release. See [Roadmap](#roadmap).

---

## Project Structure

```
simple-shell/
├── linux/
│   ├── bootstrap.sh               # Main entry point
│   ├── install-core.sh            # Core apt packages
│   ├── install-bash.sh            # Deploys .bashrc, sets up bash-completion
│   ├── install-docker.sh          # Docker Engine + Compose
│   ├── install-kubernetes.sh      # kubectl, Helm, k9s, kubectx
│   ├── install-node.sh            # Node.js via nvm
│   ├── scripts/
│   │   └── helpers.sh             # Shared functions, distro detection
│   └── optional-installers/
│       ├── install-go.sh
│       ├── install-java.sh
│       ├── install-python.sh
│       ├── install-rust.sh
│       └── install-terraform.sh
└── dotfiles/
    └── .bashrc                    # Source Bash configuration
```

---

## Optional Tools

Run any of these independently after the initial bootstrap:

```bash
# Container tools
./install-docker.sh

# Kubernetes toolchain (kubectl, Helm, k9s, kubectx/kubens)
./install-kubernetes.sh

# Node.js via nvm
./install-node.sh

# Language runtimes
./optional-installers/install-go.sh
./optional-installers/install-rust.sh
./optional-installers/install-java.sh
./optional-installers/install-python.sh

# Infrastructure
./optional-installers/install-terraform.sh
```

---

## Troubleshooting

**`source ./scripts/helpers.sh: No such file or directory`**
Run scripts from within the `linux/` directory:
```bash
cd simple-shell/linux
./bootstrap.sh
```

**Unsupported distribution warning**
The installer checks for Debian-based distros. If you see this, ensure `apt` is available and proceed when prompted.

**Restoring a previous `.bashrc`**
Backups are saved with timestamps under `~/.config/simple-shell/backups/`. Copy the desired backup back to `~/.bashrc`.

---

## Roadmap

This project is intentionally minimal. Planned expansions:

### Zsh Support
- `install-zsh.sh` alongside `install-bash.sh` — user's choice at bootstrap
- Oh My Zsh with a curated plugin set (autosuggestions, syntax-highlighting, git)
- Powerlevel10k theme configuration
- Shared `dotfiles/.zshrc` maintained in parity with `.bashrc`

### macOS Compatibility
- `macos/bootstrap.sh` re-introduced using Homebrew as the package manager
- Feature parity with the Linux installer for core packages and Bash config
- Separate optional installers for macOS-specific tooling (Xcode CLT, mas-cli)
- Apple Silicon and Intel support maintained

### General
- `configure_ssh.sh` improvements (key generation, agent config)
- `manage_optional_tools.sh` interactive menu for post-install additions
- CI smoke tests for Ubuntu LTS and Debian stable

