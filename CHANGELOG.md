<!-- doc-audience: human, ai-editable -->
# Changelog

All notable changes to work-lab will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-01-09

### Added

- Go 1.24 runtime for gastown
- Gastown (`gt`) AI coding agent orchestrator via `go install`
- Platform support note in README (Linux/macOS only)
- Beads-style versioning: `0.<release>.0` with patch slot reserved
- Require human confirmation before releasing (in AGENTS.md)

### Changed

- `wl ps` now shows complete tree for each project:
  - Stopped containers shown with unfilled circle (○) indicator
  - Running containers shown with filled circle (●) indicator
  - Both work-lab and devcontainer always shown in tree
- Updated README examples to use `gt` command for gastown

### Fixed

- Mount format bug: devcontainer CLI requires `--mount=VALUE` (with equals sign)
- Auto-create `~/.config/work-lab` directory in `wl up` if missing

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

[0.2.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.2.0
[0.1.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.1.0
