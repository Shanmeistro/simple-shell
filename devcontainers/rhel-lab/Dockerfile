FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bind9-utils \
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

RUN python3 -m pip install --no-cache-dir --upgrade pip \
    && python3 -m pip install --no-cache-dir ansible ansible-core yamllint pytest

RUN echo 'export PS1="\\u@rhel-lab:\\w\\$ "' >> /home/vscode/.bashrc

USER vscode
WORKDIR /workspaces
