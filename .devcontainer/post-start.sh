#!/usr/bin/env bash
# post-start.sh
# Copyright (c) 2026 Ryan Snodgrass. MIT License.
# Runs every time the devcontainer starts.

set -Eeuo pipefail
trap 'printf "Error at line %d: exit %d\n" "$LINENO" "$?" >&2' ERR

echo ""
echo "=========================================="
echo "  work-lab: post-start"
echo "=========================================="
echo ""

echo "Mounted directories:"
echo "  /workspaces/work-lab   <- this repo"
if [[ -d "/workspaces/project" ]]; then
  echo "  /workspaces/project    <- your project"
else
  echo "  /workspaces/project    <- (not mounted, run 'work-lab up' from a git repo)"
fi
echo ""

# Run user's post-start customizations if present
user_post_start="$HOME/.config/work-lab/post-start.sh"
if [[ -f "$user_post_start" ]]; then
  echo "Running $user_post_start..."
  # Run in separate shell so user script doesn't inherit strict mode
  if bash "$user_post_start"; then
    echo "  [ok] User post-start completed"
  else
    echo "  [warn] User post-start exited with error (continuing)"
  fi
  echo ""
fi

echo "Suggested next steps:"
echo "  1. Start a tmux session:  tmux new -s lab"
echo "  2. Navigate to project:   cd /workspaces/project"
echo "  3. Run claude:            claude"
echo ""
echo "=========================================="
