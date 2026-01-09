<!-- doc-audience: human, ai-editable -->
# Changelog

All notable changes to work-lab will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-01-09

### Added

- Initial release
- Container-based lab for humans and AI coding agents
- Two usage modes: Standalone and Sidecar
- `work-lab` CLI helper script with commands:
  - `up` - Start the devcontainer
  - `shell` - Attach interactive shell
  - `tmux` - Attach to tmux session
  - `stop` - Stop the container
  - `doctor` - Check environment and configuration
  - `version` - Show version information
- XDG-compliant configuration at `~/.config/work-lab/`
- User customization hooks:
  - `post-create.sh` - Runs once after container creation
  - `post-start.sh` - Runs every time container starts
- Pre-built Docker image on GHCR
- Multiple installation methods:
  - Homebrew (recommended)
  - curl one-liner
  - GitHub Template
  - Manual clone
- Installed tools: tmux, git, curl, jq, ripgrep, fzf, Node.js 22 LTS, Claude CLI, Gastown, Beads

[0.1.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.1.0
