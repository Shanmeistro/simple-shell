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
    - [Lab guide](#lab-guide)
      - [1) Build local lab images](#1-build-local-lab-images)
      - [2) Run labs with Docker Compose](#2-run-labs-with-docker-compose)
      - [3) Run a single lab container directly](#3-run-a-single-lab-container-directly)
      - [4) Publish images to GitHub Container Registry](#4-publish-images-to-github-container-registry)
      - [5) Use the labs in VS Code](#5-use-the-labs-in-vs-code)
    - [Lab workflow diagrams](#lab-workflow-diagrams)
    - [CI workflow for Dev Container builds](#ci-workflow-for-dev-container-builds)
    - [Image workflow diagrams](#image-workflow-diagrams)
    - [CI workflow for Dev Container builds](#ci-workflow-for-dev-container-builds-1)
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

The repository now includes reusable VS Code Dev Container definitions and lab images for three lab environments:

- Kubernetes lab: [devcontainers/kubernetes](devcontainers/kubernetes)
- Ansible Automation Platform lab: [devcontainers/ansible-aap](devcontainers/ansible-aap)
- RHEL lab: [devcontainers/rhel-lab](devcontainers/rhel-lab)

### Lab guide

These labs are intended for local development, testing, and CI image publishing.

#### 1) Build local lab images

Use the helper scripts to build lab images locally:

```bash
./labs/create.sh           # build all lab images
./labs/create.sh kubernetes
./labs/create.sh ansible-aap
./labs/create.sh rhel-lab
```

Each lab image is built from its own `devcontainers/<name>/Dockerfile`.

#### 2) Run labs with Docker Compose

This repository includes `compose.yaml` configured with build contexts for each lab.

```bash
docker compose up --build -d
```

To start a single lab service:

```bash
docker compose up --build -d kubernetes
```

To stop and remove the containers:

```bash
docker compose down
```

#### 3) Run a single lab container directly

```bash
docker run --rm -it \
  -v "$PWD":/workspaces/simple-shell \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -w /workspaces/simple-shell \
  ghcr.io/shanmeistro/simple-shell-kubernetes:latest /bin/bash
```

If you only want to run a built local image instead of GHCR, replace the image with the locally tagged name.

#### 4) Publish images to GitHub Container Registry

Build and tag the image:

```bash
docker build -t ghcr.io/shanmeistro/simple-shell-kubernetes:latest \
  -f devcontainers/kubernetes/Dockerfile devcontainers/kubernetes
```

Log in to GHCR and push:

```bash
docker login ghcr.io

docker push ghcr.io/shanmeistro/simple-shell-kubernetes:latest
```

Repeat for each lab image:

```bash
docker build -t ghcr.io/shanmeistro/simple-shell-ansible-aap:latest -f devcontainers/ansible-aap/Dockerfile devcontainers/ansible-aap

docker build -t ghcr.io/shanmeistro/simple-shell-rhel-lab:latest -f devcontainers/rhel-lab/Dockerfile devcontainers/rhel-lab
```

Multi-arch publish example:

```bash
docker buildx build --platform linux/amd64,linux/arm64 --push \
  -t ghcr.io/shanmeistro/simple-shell-kubernetes:latest \
  -t ghcr.io/shanmeistro/simple-shell-kubernetes:v1.0.0 \
  -t ghcr.io/shanmeistro/simple-shell-kubernetes:${GITHUB_SHA} \
  -f devcontainers/kubernetes/Dockerfile devcontainers/kubernetes
```

#### 5) Use the labs in VS Code

Open the repository in VS Code and choose "Reopen in Container" for one of the dev container definitions:

- `devcontainers/kubernetes`
- `devcontainers/ansible-aap`
- `devcontainers/rhel-lab`

These definitions are designed to mount the repository and give you an interactive development shell.

### Lab workflow diagrams

Beginner path:

```text
[devcontainers/<name>/Dockerfile] --> docker build --> [local image]
[local image] --> docker run --> [interactive lab container]
```

Intermediate path:

```text
[devcontainers/<name>/Dockerfile] --> docker compose up --build --> [local images]
[local images] --> [running lab containers]
```

Expert path:

```text
[GitHub Actions] --buildx--> [GHCR tags: latest, vN, SHA]
[GHCR tags] --> docker pull / docker compose up --> [production-like lab containers]
```

### CI workflow for Dev Container builds

### Image workflow diagrams

Beginner path:

```text
[devcontainers/kubernetes/Dockerfile] --> docker build --> [local image]
[local image] --> docker run --> [container shell]
```

Intermediate path:

```text
[devcontainers/* folders] --> docker compose up --build --> [local images]
[local images] --> [running containers]
```

Expert path:

```text
[GitHub Actions] --buildx--> [GHCR tags: latest, vN, SHA]
[GHCR tags] --> docker pull / docker compose up --> [production-like containers]
```

### CI workflow for Dev Container builds

This project includes a GitHub Actions workflow in `.github/workflows/build-devcontainers.yml` that builds and pushes container images to GHCR.

- On `push` to `main`, only the container definitions changed in `devcontainers/<name>/` are built.
- On manual workflow dispatch, set the `container` input to a comma-separated list of container names to build.
- If `container` is blank during manual dispatch, the workflow builds only the changed containers.
- Use `all` as the input value to build every container.

Examples:

- `azure`
- `azure,devops`
- `all`

If you want to build only changed containers from a manual run, leave the input empty.

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

