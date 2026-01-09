#!/usr/bin/env bash
# post-create.sh
# Copyright (c) 2026 Ryan Snodgrass. MIT License.
# Runs once after the devcontainer is created.

set -e

echo ""
echo "=========================================="
echo "  work-lab: post-create"
echo "=========================================="
echo ""

# Verify installed tools
echo "Installed tools:"
echo "  tmux:    $(tmux -V)"
echo "  node:    $(node --version)"
echo "  npm:     $(npm --version)"
echo "  gastown: $(gastown --version 2>/dev/null || echo 'installed')"
echo "  beads:   $(beads --version 2>/dev/null || echo 'installed')"
echo "  claude:  $(claude --version 2>/dev/null || echo 'installed')"
echo ""

# Source user's post-create customizations if present
USER_POST_CREATE="$HOME/.config/work-lab/post-create.sh"
if [ -f "$USER_POST_CREATE" ]; then
  echo "Sourcing $USER_POST_CREATE..."
  source "$USER_POST_CREATE"
  echo ""
fi

echo "=========================================="
