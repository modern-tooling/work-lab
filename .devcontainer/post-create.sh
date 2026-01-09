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

# ─────────────────────────────────────────────────────────────────────────────
# Automatic shell detection
# ─────────────────────────────────────────────────────────────────────────────
# work-lab tries to match your host shell so you feel at home:
#
# Priority order:
#   1. WORK_LAB_SHELL in ~/.config/work-lab/config (explicit override)
#   2. HOST_SHELL env var (passed from host via devcontainer.json remoteEnv)
#   3. Default to bash
#
# If you use zsh on your Mac, work-lab will use zsh inside the container.
# To override, add to ~/.config/work-lab/config:
#   export WORK_LAB_SHELL="bash"  # or "zsh"
# ─────────────────────────────────────────────────────────────────────────────
preferred_shell="bash"

# Source user config for WORK_LAB_SHELL override
user_config="$HOME/.config/work-lab/config"
if [[ -f "$user_config" ]]; then
  # shellcheck source=/dev/null
  source "$user_config"
fi

# Check for explicit override, then detect from host
if [[ -n "${WORK_LAB_SHELL:-}" ]]; then
  preferred_shell="$WORK_LAB_SHELL"
  echo "Shell: $preferred_shell (from WORK_LAB_SHELL)"
elif [[ "${HOST_SHELL:-}" == *"zsh"* ]]; then
  preferred_shell="zsh"
  echo "Shell: zsh (detected from host)"
else
  echo "Shell: bash (default)"
fi

# Change login shell if zsh preferred
if [[ "$preferred_shell" == "zsh" ]] && command -v zsh &>/dev/null; then
  sudo chsh -s "$(which zsh)" "$(whoami)" 2>/dev/null || true
fi
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
