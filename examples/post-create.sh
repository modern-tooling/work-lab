#!/usr/bin/env bash
# Example post-create.sh
# Copyright (c) 2026 Ryan Snodgrass. MIT License.
# Copy to ~/.config/work-lab/post-create.sh
# Runs once after the devcontainer is created.

set -Eeuo pipefail

# Install additional coding agents
# npm install -g opencode
# npm install -g aider

# Install additional tools
# pip install --user some-tool

echo "Custom post-create complete"
