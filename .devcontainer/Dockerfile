# work-lab devcontainer
# Copyright (c) 2026 Ryan Snodgrass. MIT License.
# A container-based lab for humans and AI coding agents.

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Create worklab user (replacing default vscode user)
RUN useradd -m -s /bin/bash worklab && \
    usermod -aG sudo worklab && \
    echo "worklab ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/worklab

# Install core tools via apt
RUN apt-get update && apt-get install -y --no-install-recommends \
    # Terminal & shell
    tmux \
    tree \
    zsh \
    # Version control
    git \
    gh \
    # Text & data processing (Claude Code favorites)
    jq \
    ripgrep \
    fzf \
    fd-find \
    bat \
    # Network tools
    curl \
    nmap \
    net-tools \
    iputils-ping \
    dnsutils \
    ca-certificates \
    openssh-client \
    # System monitoring
    htop \
    # Build tools
    make \
    && rm -rf /var/lib/apt/lists/* \
    # Create symlinks for tools with different names on Ubuntu
    && ln -sf /usr/bin/batcat /usr/bin/bat \
    && ln -sf /usr/bin/fdfind /usr/bin/fd

# Install Node.js LTS via NodeSource
# Using NodeSource distribution for a stable, well-maintained LTS version.
# This is the recommended approach for getting recent Node.js on Ubuntu.
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y nodejs \
    && rm -rf /var/lib/apt/lists/*

# Install global npm packages
# - @anthropic-ai/claude-code: official claude CLI
RUN npm install -g @anthropic-ai/claude-code

# Install Go (required for gastown)
# gastown requires Go >= 1.24.2
# Detect architecture and download appropriate binary
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://go.dev/dl/go1.24.11.linux-${ARCH}.tar.gz" | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Install beads (bd) from pre-built binary
# https://github.com/steveyegge/beads/releases
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://github.com/steveyegge/beads/releases/download/v0.46.0/beads_0.46.0_linux_${ARCH}.tar.gz" | tar -xzf - -C /tmp && \
    mv /tmp/bd /usr/local/bin/bd && \
    chmod +x /usr/local/bin/bd

# Install gastown (gt) - AI coding agent orchestrator
# Requires Go 1.24+ and tmux (all installed above)
ENV GOPATH=/home/worklab/go
ENV PATH="${PATH}:/home/worklab/go/bin"
RUN mkdir -p /home/worklab/go && chown worklab:worklab /home/worklab/go
USER worklab
RUN go install github.com/steveyegge/gastown/cmd/gt@latest
USER root

# Copy worklab user configs (context is repo root)
COPY .devcontainer/home/ /home/worklab/
RUN chown -R worklab:worklab /home/worklab

# Install work-lab CLI from GitHub (works inside container too)
# Pulls latest from main branch at build time
RUN mkdir -p /opt/work-lab/bin /opt/work-lab/lib && \
    curl -fsSL https://raw.githubusercontent.com/modern-tooling/work-lab/main/bin/work-lab -o /opt/work-lab/bin/work-lab && \
    curl -fsSL https://raw.githubusercontent.com/modern-tooling/work-lab/main/lib/style.sh -o /opt/work-lab/lib/style.sh && \
    chmod +x /opt/work-lab/bin/work-lab && \
    sed -i 's|readonly REPO_DIR=.*|readonly REPO_DIR="/opt/work-lab"|' /opt/work-lab/bin/work-lab && \
    ln -sf /opt/work-lab/bin/work-lab /home/worklab/bin/work-lab

# Copy post-create and post-start scripts
COPY .devcontainer/post-create.sh .devcontainer/post-start.sh /opt/work-lab/
RUN chmod +x /opt/work-lab/*.sh

USER worklab
WORKDIR /workspaces/project
