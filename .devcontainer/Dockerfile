# work-lab devcontainer
# Copyright (c) 2026 Ryan Snodgrass. MIT License.
# A container-based lab for humans and AI coding agents.

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install core tools via apt
RUN apt-get update && apt-get install -y --no-install-recommends \
    tmux \
    git \
    curl \
    jq \
    ripgrep \
    fzf \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

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

# Create minimal tmux config for vscode user
RUN mkdir -p /home/vscode && \
    cat > /home/vscode/.tmux.conf << 'EOF'
# work-lab tmux config
# Minimal, functional defaults.

# Enable mouse support
set -g mouse on

# Start window numbering at 1
set -g base-index 1
setw -g pane-base-index 1

# Simple status bar
set -g status-style 'bg=#333333 fg=#ffffff'
set -g status-left '[#S] '
set -g status-right '%H:%M'
set -g status-left-length 20

# Increase scrollback
set -g history-limit 10000

# Reduce escape delay (better for vim users)
set -sg escape-time 10

# Use 256 colors
set -g default-terminal "screen-256color"
EOF

# Ensure correct ownership
RUN chown -R vscode:vscode /home/vscode

USER vscode
WORKDIR /workspaces/work-lab
