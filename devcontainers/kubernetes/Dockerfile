FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETOS
ARG TARGETARCH

RUN echo "Building for ${TARGETARCH}"

RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        bash-completion \
        ca-certificates \
        curl \
        git \
        gnupg \
        jq \
        less \
        sudo \
        unzip \
        wget && \
    rm -rf /var/lib/apt/lists/*

#
# kubectl
#
RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key \
    | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
    echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /" \
    > /etc/apt/sources.list.d/kubernetes.list && \
    apt-get update && \
    apt-get install -y kubectl

#
# Helm
#
RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

#
# Kind
#
RUN curl -Lo /usr/local/bin/kind \
    https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-${TARGETARCH} && \
    chmod +x /usr/local/bin/kind

RUN echo "source /etc/bash_completion" >> /etc/bash.bashrc

USER vscode
WORKDIR /workspaces