<!-- doc-audience: human, ai-editable -->
# Changelog

All notable changes to work-lab will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.7.1] - 2026-01-10

### Added

- **Unified `wl` command**: Works both on host AND inside the container
- **Context-aware help**: Host-only commands dimmed when inside container

### Changed

- **Claude authentication**: `.claude` mount changed to read-write for persistent login
- **Tmux status bar**: tmux2k-inspired design with Nerd Font icons and rounded window tabs
- **Help styling**: Consistent colors (command cyan, description white)

### Fixed

- **Welcome guide**: Now shows correctly in first tmux pane

## [0.7.0] - 2026-01-09

### Added

- **`wl mux [project]`**: Attach to any running work-lab by project name (not just current directory)
- **`wl ports`**: Show forwarded ports for work-lab and paired devcontainer
- **`wl prune`**: Clean up stopped work-lab containers (use `--all` for images too)
- **Session restore**: tmux layout persists across container rebuilds
  - `prefix + W` saves session layout to project's `.work-lab/` directory
  - `wl mux` auto-restores saved layout when creating new session

### Fixed

- **beads (bd)**: Install from pre-built binary release instead of npm/go

## [0.6.0] - 2026-01-09

### Added

- **`wl doctor --fix`**: Auto-fix detectable issues (stale containers, SSH tunnel setup, missing devcontainer CLI)
- **Stale container detection**: `wl doctor` finds orphaned containers from deleted/moved projects

### Removed

- **`wl upgrade`**: Use your package manager instead (`brew upgrade work-lab`)

## [0.5.0] - 2026-01-09

### Changed

- **Command rename**: `wl up` → `wl start` (clearer intent, `wl stop` unchanged)
- Clearer messaging: tips (`*`) show features, actions (`→`) tell you what to do next

### Added

- `wl doctor` now works inside container (shows container-specific diagnostics)
- Docker image availability check before `wl start`

### Fixed

- `wl ps` shows current project even when no containers running
- Works on stock macOS without coreutils
- Better error messages for config file issues

## [0.4.0] - 2026-01-09

### Fixed

- **Apple Silicon support**: Multi-architecture Docker builds (amd64 + arm64)
- **Better error messages**: Helpful hints for network failures and missing dependencies
- **Homebrew install**: Fixed "bind source path does not exist" error
- `wl ps` shows current project even when both containers stopped

### Changed

- **Faster startup**: Pre-built GHCR image eliminates network-dependent rebuilds
- **zsh and gh (GitHub CLI) included**: Baked into image, no runtime feature installs
- Docker image versioned independently from CLI (rebuilds only when Dockerfile changes)

## [0.3.0] - 2026-01-09

### Added

- **SSH tunneling to devcontainers**: Run commands in your project's devcontainer from work-lab
  - `wl dc <cmd>` runs commands in paired devcontainer
  - `Ctrl-b S` in tmux to SSH into devcontainer
  - Zero devcontainer config required (just enable sshd feature)
  - NO Docker socket in work-lab - maintains full isolation
- **`wl ps` tunnel status**: Shows `⚡` when tunnel ready, `~` when sshd detected
- **`wl shell <cmd>`**: Now supports running commands directly (not just interactive shell)
- `wl doctor` checks for `wl` alias and suggests setup if missing
- `openssh-client` added to container image

### Changed

- `wl dc` runs as proper user (not root) and auto-detects workspace directory
- `wl dc` from host auto-configures SSH tunnel for future use inside work-lab

### Security

- SSH tunneling uses shared filesystem approach instead of Docker socket
- No additional privileges required in work-lab container
- Full isolation maintained from host system

## [0.2.0] - 2026-01-09

### Added

- **Go 1.24 runtime**: Enables gastown AI agent orchestrator
- **Gastown (`gt`)**: AI coding agent orchestrator included
- Platform support note in README (Linux/macOS only)

### Changed

- **`wl ps` improved display**: Shows complete tree with status indicators
  - `●` running, `○` stopped
  - Both work-lab and devcontainer always shown in tree

### Fixed

- Mount format bug: devcontainer CLI requires `--mount=VALUE` (with equals sign)
- Auto-create `~/.config/work-lab` directory if missing

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

[0.7.1]: https://github.com/modern-tooling/work-lab/releases/tag/v0.7.1
[0.7.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.7.0
[0.6.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.6.0
[0.5.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.5.0
[0.4.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.4.0
[0.3.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.3.0
[0.2.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.2.0
[0.1.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.1.0
