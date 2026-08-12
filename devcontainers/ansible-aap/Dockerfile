FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        curl \
        docker.io \
        git \
        gnupg \
        jq \
        less \
        openssh-client \
        python3 \
        python3-pip \
        python3-venv \
        sudo \
        unzip \
        wget \
        zip \
    && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --no-cache-dir --break-system-packages ansible ansible-core ansible-lint yamllint pytest

# The ansible-lint package is installed via pip. The previous install script
# URL is no longer valid, so it is omitted to keep this image build stable.
USER vscode
WORKDIR /workspaces
