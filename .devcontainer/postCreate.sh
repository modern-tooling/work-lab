#!/usr/bin/env bash
# postCreate.sh
# Runs after the devcontainer is created. Verifies tools and prints a welcome message.

set -e

echo ""
echo "=========================================="
echo "  work-lab environment ready"
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

echo "Mounted directories:"
echo "  /workspaces/work-lab   <- this repo"
if [ -d "/workspaces/projects" ]; then
  echo "  /workspaces/projects   <- your projects"
else
  echo "  /workspaces/projects   <- (not mounted, see README)"
fi
echo ""

echo "Suggested next steps:"
echo "  1. Start a tmux session:  tmux new -s lab"
echo "  2. Navigate to a project: cd /workspaces/projects/your-project"
echo "  3. Run claude:            claude"
echo ""
echo "=========================================="
