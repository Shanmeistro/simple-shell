# simple-shell

A minimal, focused Bash environment installer for Debian-based Linux systems with added macOS support and reusable Dev Container lab environments for Kubernetes, Ansible Automation Platform, and RHEL-based lab work.

---

## Table of Contents

- [simple-shell](#simple-shell)
  - [Table of Contents](#table-of-contents)
  - [Quick Start](#quick-start)
  - [What Gets Installed](#what-gets-installed)
    - [Core Packages](#core-packages)
    - [Bash Configuration (`dotfiles/.bashrc`)](#bash-configuration-dotfilesbashrc)
  - [Platform Support](#platform-support)
  - [Project Structure](#project-structure)
  - [Dev Container Labs](#dev-container-labs)
  - [Optional Tools](#optional-tools)
  - [Troubleshooting](#troubleshooting)
  - [Roadmap](#roadmap)
    - [Zsh Support](#zsh-support)
    - [macOS Compatibility](#macos-compatibility)
    - [General](#general)

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
| macOS | Supported via Homebrew-based bootstrap |

> macOS support is available through the top-level installer and the macOS helper scripts.

---

## Project Structure

```
simple-shell/
├── linux/
│   ├── bootstrap.sh               # Main Linux bootstrap entry point
│   ├── install-core.sh            # Core apt packages
│   ├── install-bash.sh            # Deploys .bashrc and Bash helpers
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
├── macos/
│   ├── scripts/
│   │   ├── bootstrap.sh           # Homebrew-based macOS bootstrap
│   │   ├── helper.sh              # Shared Homebrew helpers
│   │   └── manage_optional_tools.sh
│   └── packages.txt               # Brew packages for macOS
├── devcontainers/
│   ├── kubernetes/
│   │   ├── Dockerfile
│   │   └── devcontainer.json
│   ├── ansible-aap/
│   │   ├── Dockerfile
│   │   └── devcontainer.json
│   └── rhel-lab/
│       ├── Dockerfile
│       └── devcontainer.json
├── labs/
│   ├── create.sh                  # Build lab containers
│   └── destroy.sh                 # Remove lab container images
├── dotfiles/
│   └── .bashrc                    # Source Bash configuration
└── install.sh                     # Top-level OS-aware installer
```

---

## Dev Container Labs

The repository now includes reusable VS Code Dev Container definitions for lab-style environments:

- Kubernetes lab: [devcontainers/kubernetes](devcontainers/kubernetes)
- Ansible Automation Platform lab: [devcontainers/ansible-aap](devcontainers/ansible-aap)
- RHEL lab: [devcontainers/rhel-lab](devcontainers/rhel-lab)

Build or remove the local lab images with:

```bash
./labs/create.sh
./labs/create.sh kubernetes
./labs/destroy.sh
./labs/destroy.sh rhel-lab
```

You can also launch the lab containers through Docker Compose:

```bash
docker compose up -d kubernetes

docker compose up -d ansible-aap
docker compose up -d rhel-lab
```

Open the repository in VS Code and use the Dev Containers extension to reopen the folder in the appropriate container.

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
- Homebrew-based bootstrap for macOS is available via the top-level installer
- Core package installation and optional tool management are supported
- Additional macOS-specific workflow polish is still being improved

### General
- `configure_ssh.sh` improvements (key generation, agent config)
- Further Dev Container polish and shared lab templates
- CI smoke tests for Ubuntu LTS and Debian stable
- Custom profile setups to replicate environements with lab simulation

