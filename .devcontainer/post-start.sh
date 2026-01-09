#!/usr/bin/env bash
# post-start.sh
# Copyright (c) 2026 Ryan Snodgrass. MIT License.
# Runs every time the devcontainer starts.

set -Eeuo pipefail

echo ""
echo "=========================================="
echo "  work-lab: post-start"
echo "=========================================="
echo ""

echo "Mounted directories:"
echo "  /workspaces/work-lab   <- this repo"
if [[ -d "/workspaces/projects" ]]; then
  echo "  /workspaces/projects   <- your projects"
else
  echo "  /workspaces/projects   <- (not mounted, see README)"
fi
echo ""

# Source user's post-start customizations if present
user_post_start="$HOME/.config/work-lab/post-start.sh"
if [[ -f "$user_post_start" ]]; then
  echo "Sourcing $user_post_start..."
  # shellcheck source=/dev/null
  source "$user_post_start"
  echo ""
fi

echo "Suggested next steps:"
echo "  1. Start a tmux session:  tmux new -s lab"
echo "  2. Navigate to a project: cd /workspaces/projects/your-project"
echo "  3. Run claude:            claude"
echo ""
echo "=========================================="
