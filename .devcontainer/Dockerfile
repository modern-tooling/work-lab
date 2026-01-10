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
# - beads: task management
# - @anthropic-ai/claude-code: official claude CLI
RUN npm install -g \
    beads \
    @anthropic-ai/claude-code

# Install Go (required for gastown)
# gastown requires Go >= 1.24.2
# Detect architecture and download appropriate binary
RUN ARCH=$(dpkg --print-architecture) && \
    curl -fsSL "https://go.dev/dl/go1.24.11.linux-${ARCH}.tar.gz" | tar -C /usr/local -xzf - && \
    ln -s /usr/local/go/bin/go /usr/local/bin/go && \
    ln -s /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Install gastown (AI coding agent orchestrator)
# Requires Go 1.24+, beads, and tmux (all installed above)
ENV GOPATH=/home/worklab/go
ENV PATH="${PATH}:/home/worklab/go/bin"
RUN mkdir -p /home/worklab/go && chown worklab:worklab /home/worklab/go
USER worklab
RUN go install github.com/steveyegge/gastown/cmd/gt@latest
USER root

# Copy worklab user configs
COPY home/ /home/worklab/
RUN chown -R worklab:worklab /home/worklab

# Copy post-create and post-start scripts to fixed location
COPY post-create.sh post-start.sh /opt/work-lab/
RUN chmod +x /opt/work-lab/*.sh

USER worklab
WORKDIR /workspaces/project
