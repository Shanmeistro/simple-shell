# Linux Setup

Scripts for setting up a Bash development environment on Debian-based Linux distributions (Ubuntu, Debian, Pop!_OS, Kali, Raspberry Pi OS, WSL2, and other `apt`-based distros).

---

## Quick Start

```bash
cd simple-shell/linux
./bootstrap.sh
```

The bootstrap will:
1. Back up your existing `~/.bashrc`
2. Detect and validate your distribution
3. Update and upgrade system packages
4. Install core packages
5. Deploy the Bash configuration from `dotfiles/.bashrc`
6. Prompt to optionally install Docker and Node.js

---

## Scripts

### Core

| Script | Description |
|--------|-------------|
| `bootstrap.sh` | Main entry point — runs the full setup in order |
| `install-core.sh` | Installs essential apt packages (git, curl, vim, jq, tmux, etc.) |
| `install-bash.sh` | Deploys `dotfiles/.bashrc` to `~/.bashrc` |
| `scripts/helpers.sh` | Shared functions: print helpers, distro detection, package management, `.bashrc` backup |

### Optional

| Script | Description |
|--------|-------------|
| `install-docker.sh` | Docker Engine + Docker Compose (stops and removes any existing install first) |
| `install-kubernetes.sh` | kubectl, Helm, k9s, kubectx/kubens (stops and removes any existing install first) |
| `install-node.sh` | Node.js via nvm |
| `optional-installers/install-go.sh` | Go (latest, via official binary) |
| `optional-installers/install-rust.sh` | Rust via rustup |
| `optional-installers/install-java.sh` | Java via SDKMAN! |
| `optional-installers/install-python.sh` | Python via pyenv + poetry |
| `optional-installers/install-terraform.sh` | Terraform via HashiCorp apt repo (stops and removes any existing install first) |

---

## System Requirements

- **OS**: Debian-based distribution with `apt` (Ubuntu 20.04+, Debian 11+, WSL2, etc.)
- **Architecture**: x86_64
- **Privileges**: `sudo` access required
- **Network**: Internet connection for package downloads

---

## Post-Installation

```bash
source ~/.bashrc
```

To restore a previous Bash config, timestamped backups are saved to:
```
~/.config/simple-shell/backups/
```

---

## Troubleshooting

**Permission denied on scripts**
```bash
chmod +x *.sh optional-installers/*.sh
```

**Running from wrong directory**
All scripts must be run from within `linux/` as they source `./scripts/helpers.sh` by relative path:
```bash
cd simple-shell/linux
./bootstrap.sh
```

**Unsupported distribution**
If your distro is not on the supported list, the installer will warn you and ask whether to continue. It will work on any system with `apt` available.

