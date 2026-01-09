#!/usr/bin/env bash
# post-create.sh
# Copyright (c) 2026 Ryan Snodgrass. MIT License.
# Runs once after the devcontainer is created.

set -Eeuo pipefail
trap 'printf "Error at line %d: exit %d\n" "$LINENO" "$?" >&2' ERR

echo ""
echo "=========================================="
echo "  work-lab: post-create"
echo "=========================================="
echo ""

# Verify installed tools
echo "Installed tools:"
echo "  tmux:    $(tmux -V 2>/dev/null || echo 'not found')"
echo "  node:    $(node --version 2>/dev/null || echo 'not found')"
echo "  npm:     $(npm --version 2>/dev/null || echo 'not found')"
echo "  gastown: $(gastown --version 2>/dev/null || echo 'installed')"
echo "  beads:   $(beads --version 2>/dev/null || echo 'installed')"
echo "  claude:  $(claude --version 2>/dev/null || echo 'installed')"
echo ""

# Run user's post-create customizations if present
user_post_create="$HOME/.config/work-lab/post-create.sh"
if [[ -f "$user_post_create" ]]; then
  echo "Running $user_post_create..."
  # Run in separate shell so user script doesn't inherit strict mode
  if bash "$user_post_create"; then
    echo "  [ok] User post-create completed"
  else
    echo "  [warn] User post-create exited with error (continuing)"
  fi
  echo ""
fi

echo "=========================================="
