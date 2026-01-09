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
    # Version control
    git \
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
# - gastown: steveyegge's tool
# - beads: task management
# - @anthropic-ai/claude-code: official claude CLI
RUN npm install -g \
    gastown \
    beads \
    @anthropic-ai/claude-code

# Copy worklab user configs
COPY home/ /home/worklab/
RUN chown -R worklab:worklab /home/worklab

USER worklab
WORKDIR /workspaces/work-lab
