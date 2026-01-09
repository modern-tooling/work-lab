#!/usr/bin/env bash
# install.sh
# Copyright (c) 2026 Ryan Snodgrass. MIT License.
# One-liner installer for work-lab
#
# Usage:
#   curl -fsSL https://raw.githubusercontent.com/modern-tooling/work-lab/main/install.sh | bash

set -e

INSTALL_DIR="${WORK_LAB_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/work-lab}"
CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/work-lab"
REPO_URL="https://github.com/modern-tooling/work-lab.git"
GHCR_IMAGE="ghcr.io/modern-tooling/work-lab:latest"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[info]${NC} $1"; }
success() { echo -e "${GREEN}[ok]${NC} $1"; }
error() { echo -e "${RED}[error]${NC} $1"; exit 1; }

echo ""
echo "========================================"
echo "  work-lab installer"
echo "========================================"
echo ""

# Check dependencies
command -v git &> /dev/null || error "git is required but not installed"
command -v docker &> /dev/null || error "docker is required but not installed"

# Clone or update repo
if [ -d "$INSTALL_DIR" ]; then
  info "Updating existing installation at $INSTALL_DIR..."
  git -C "$INSTALL_DIR" pull --quiet
  success "Updated to latest version"
else
  info "Cloning work-lab to $INSTALL_DIR..."
  git clone --quiet "$REPO_URL" "$INSTALL_DIR"
  success "Cloned work-lab"
fi

# Create config directory
if [ ! -d "$CONFIG_DIR" ]; then
  info "Creating config directory at $CONFIG_DIR..."
  mkdir -p "$CONFIG_DIR"
  success "Created $CONFIG_DIR"
else
  success "Config directory exists: $CONFIG_DIR"
fi

# Pull pre-built image (optional, speeds up first run)
info "Pulling pre-built image from GHCR (this may take a moment)..."
if docker pull "$GHCR_IMAGE" &> /dev/null; then
  success "Pulled $GHCR_IMAGE"
else
  info "Could not pull image (will build locally on first run)"
fi

# Create symlink in ~/.local/bin (XDG standard for user executables)
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"
if [ -L "$LOCAL_BIN/work-lab" ] || [ -e "$LOCAL_BIN/work-lab" ]; then
  rm -f "$LOCAL_BIN/work-lab"
fi
ln -s "$INSTALL_DIR/bin/work-lab" "$LOCAL_BIN/work-lab"
success "Symlinked to $LOCAL_BIN/work-lab"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
  info "~/.local/bin is not in your PATH"
  info "Add this to your shell profile (~/.bashrc or ~/.zshrc):"
  info "  export PATH=\"\$PATH:$LOCAL_BIN\""
else
  success "~/.local/bin is already in PATH"
fi

# Check if devcontainer CLI is installed
if command -v devcontainer &> /dev/null; then
  success "devcontainer CLI is installed"
else
  info "devcontainer CLI not found"
  info "Install with: npm install -g @devcontainers/cli"
fi

echo ""
echo "========================================"
echo "  Installation complete!"
echo "========================================"
echo ""
echo "Quick start:"
echo ""
echo "  work-lab version  # Verify installation"
echo "  work-lab doctor   # Check your environment"
echo "  work-lab up       # Start the container"
echo "  work-lab tmux     # Attach to tmux session"
echo ""
