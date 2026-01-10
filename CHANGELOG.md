<!-- doc-audience: human, ai-editable -->
# Changelog

All notable changes to work-lab will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.10.0] - 2026-01-10

### Added

- **tmux 3.5a**: Built from source for better clipboard and image support
- **Clipboard integration**: `set-clipboard on` enables OSC 52 (copy to system clipboard)
- **Image passthrough**: `allow-passthrough on` enables image protocols in tmux
- **`claude-dsp` alias**: Shortcut for `claude --dangerously-skip-permissions`

### Changed

- **Terminal environment**: Container now exports `LANG`, `LC_ALL`, `TERM`, `COLORTERM` for proper Unicode and color detection

## [0.9.0] - 2026-01-10

### Fixed

- **Devcontainer detection**: Now correctly finds paired devcontainer when work-lab is also running
- **tmux status bar**: Simplified config, no longer requires Nerd Fonts
- **`wl start` auto-update**: Rebuilds container if newer image is locally available
- **`wl doctor` fast check**: Compares running container vs pulled image (instant, no network)

## [0.8.0] - 2026-01-10

### Added

- **`wl dc --status`**: Check paired devcontainer connection status at a glance
- **Tree view in `wl start`**: Shows container status matching `wl ps` for visual continuity
- **Devcontainer ports display**: Shows `forwardPorts` in `wl start` and `wl dc --status`
- **Gold tmux tabs for devcontainer sessions**: `[dc]` windows clearly distinguished from regular tabs

### Changed

- **`wl start` cleaner output**: Removed banner, redundant path info; shows activity first
- **`wl doctor --fix` auto-rebuild**: Rebuilds container after pulling new image (if no tmux session attached)
- **tmux status bar**: `⚡dc` when connected, `⚠ dc` when devcontainer exists but unreachable
- **tmux scripts use full paths**: Fixes status bar not displaying on some systems

### Fixed

- **tmux status scripts**: Now work reliably (use `$HOME/bin/` paths instead of relying on PATH)
- **JSONC parsing**: Port extraction handles `//` comments in devcontainer.json

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

[0.10.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.10.0
[0.9.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.9.0
[0.8.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.8.0
[0.7.1]: https://github.com/modern-tooling/work-lab/releases/tag/v0.7.1
[0.7.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.7.0
[0.6.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.6.0
[0.5.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.5.0
[0.4.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.4.0
[0.3.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.3.0
[0.2.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.2.0
[0.1.0]: https://github.com/modern-tooling/work-lab/releases/tag/v0.1.0
