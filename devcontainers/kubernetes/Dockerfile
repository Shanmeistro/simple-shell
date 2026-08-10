FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        apt-transport-https \
        ca-certificates \
        curl \
        docker.io \
        git \
        gnupg \
        jq \
        less \
        openssh-client \
        python3 \
        python3-pip \
        sudo \
        unzip \
        wget \
        zip \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg \
    && echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' > /etc/apt/sources.list.d/kubernetes.list \
    && apt-get update \
    && apt-get install -y --no-install-recommends kubectl \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash \
    && curl -Lo /usr/local/bin/kind https://kind.sigs.k8s.io/dl/v0.29.0/kind-linux-amd64 \
    && chmod +x /usr/local/bin/kind \
    && curl -Lo /tmp/k9s.tgz https://github.com/derailed/k9s/releases/download/v0.50.1/k9s_Linux_amd64.tar.gz \
    && tar -xzf /tmp/k9s.tgz -C /usr/local/bin k9s \
    && chmod +x /usr/local/bin/k9s

RUN python3 -m pip install --no-cache-dir --upgrade pip yq

RUN echo 'source /etc/bash_completion' >> /etc/bash.bashrc

USER vscode
WORKDIR /workspaces
