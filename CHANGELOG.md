<!-- doc-audience: human, ai-editable -->
# Changelog

All notable changes to work-lab will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

- Multi-architecture Docker builds (amd64 + arm64 for Apple Silicon)
- Go download now detects architecture instead of hardcoding amd64
- `wl up` error handling shows helpful messages for network failures
- `wl ps` shows current project even when both containers stopped
- Homebrew install: fixed "bind source path does not exist" error
- Post-create/post-start scripts now use absolute paths in image

### Changed

- Use pre-built GHCR image instead of building from Dockerfile
- Added CI workflow for Docker build testing
- Baked zsh and gh (GitHub CLI) into image - no runtime feature installs
- Removed devcontainer features to eliminate network-dependent rebuilds
- Startup message now says "Starting work-lab container..."
- Docker image versioned independently from CLI (rebuilds only when Dockerfile changes)

## [0.3.0] - 2026-01-09

### Added

- **SSH tunneling to devcontainers**: Run commands in project devcontainer from work-lab
  - `wl dc <cmd>` works from inside work-lab via SSH tunnel
  - `prefix + S` in tmux to SSH into devcontainer
  - Zero devcontainer config required (just enable sshd feature)
  - Host orchestrates setup via `wl mux`/`wl shell` (lazy initialization)
  - NO Docker socket in work-lab - maintains full isolation
- `wl ps` shows tunnel status: `⚡` = ready, `~` = sshd detected (run `wl mux`)
- `wl doctor` checks for `wl` alias and suggests setup if missing
- `wl doctor` detects SSH tunnel configuration in sidecar mode
- New documentation: `docs/ssh-tunneling.md`
- Integration test script: `test/integration/tunnel-test.sh`
- `openssh-client` added to container image

### Changed

- `wl shell <cmd>` now supports running commands directly (not just interactive shell)
- `wl dc` now runs as proper user (not root) and auto-detects workspace directory
- `wl dc` from host now auto-configures SSH tunnel for future use inside work-lab
- Container discovery (`find_container`) checks actual mount paths instead of labels
- README updated with clearer value proposition and sidecar mode examples
- No longer auto-modifies .gitignore (user controls their own files)

### Security

- SSH tunneling uses shared filesystem approach instead of Docker socket
- No additional privileges required in work-lab container
- Maintains full isolation from host system

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

[0.4.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.4.0
[0.3.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.3.0
[0.2.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.2.0
[0.1.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.1.0
