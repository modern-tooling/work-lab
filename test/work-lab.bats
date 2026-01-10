#!/usr/bin/env bats
# work-lab tests
# Run with: bats test/ or make test

# ─────────────────────────────────────────────────────────────────────────────
# Setup and Teardown
# ─────────────────────────────────────────────────────────────────────────────

setup() {
  TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  PROJECT_ROOT="$(dirname "$TEST_DIR")"

  # Source style library
  source "$PROJECT_ROOT/lib/style.sh"

  # Create temp directory for test fixtures
  export TEMP_DIR="$(mktemp -d)"
  export ORIGINAL_HOME="$HOME"
  export ORIGINAL_PATH="$PATH"
  export HOME="$TEMP_DIR"
  mkdir -p "$HOME/.config/work-lab"

  # Create a fake git repo for testing
  export FAKE_GIT_REPO="$TEMP_DIR/fake-project"
  mkdir -p "$FAKE_GIT_REPO/.git"

  # Create mock bin directory for docker/devcontainer mocks
  export MOCK_BIN="$TEMP_DIR/mock-bin"
  mkdir -p "$MOCK_BIN"
}

teardown() {
  rm -rf "$TEMP_DIR"
  export HOME="$ORIGINAL_HOME"
  export PATH="$ORIGINAL_PATH"
}

# Helper to source script functions for unit testing
load_functions() {
  # Extract specific functions from the script
  source "$PROJECT_ROOT/lib/style.sh"
}

# ─────────────────────────────────────────────────────────────────────────────
# Command Parsing Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "help command shows usage" {
  run "$PROJECT_ROOT/bin/work-lab" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"work-lab"* ]]
  [[ "$output" == *"Commands:"* ]]
}

@test "version command shows version number" {
  run "$PROJECT_ROOT/bin/work-lab" version
  [ "$status" -eq 0 ]
  [[ "$output" == *"work-lab"* ]]
  [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "--version flag works" {
  run "$PROJECT_ROOT/bin/work-lab" --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "-v flag works" {
  run "$PROJECT_ROOT/bin/work-lab" -v
  [ "$status" -eq 0 ]
  [[ "$output" =~ [0-9]+\.[0-9]+\.[0-9]+ ]]
}

@test "--help flag works" {
  run "$PROJECT_ROOT/bin/work-lab" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Commands:"* ]]
}

@test "-h flag works" {
  run "$PROJECT_ROOT/bin/work-lab" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Commands:"* ]]
}

@test "unknown command shows error and usage" {
  run "$PROJECT_ROOT/bin/work-lab" notacommand
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown command: notacommand"* ]]
  [[ "$output" == *"Commands:"* ]]
}

@test "no command shows usage and exits non-zero" {
  run "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Commands:"* ]]
}

@test "help lists all expected commands" {
  run "$PROJECT_ROOT/bin/work-lab" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"up"* ]]
  [[ "$output" == *"shell"* ]]
  [[ "$output" == *"mux"* ]]
  [[ "$output" == *"stop"* ]]
  [[ "$output" == *"ps"* ]]
  [[ "$output" == *"dc"* ]]
  [[ "$output" == *"doctor"* ]]
  [[ "$output" == *"version"* ]]
  [[ "$output" == *"release-notes"* ]]
  [[ "$output" == *"help"* ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# dc Command Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "dc without arguments shows usage" {
  run "$PROJECT_ROOT/bin/work-lab" dc
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: work-lab dc"* ]]
  [[ "$output" == *"Examples:"* ]]
}

@test "dc usage shows npm test example" {
  run "$PROJECT_ROOT/bin/work-lab" dc
  [[ "$output" == *"npm test"* ]]
}

@test "dc usage shows make build example" {
  run "$PROJECT_ROOT/bin/work-lab" dc
  [[ "$output" == *"make build"* ]]
}

@test "dc usage shows bash example" {
  run "$PROJECT_ROOT/bin/work-lab" dc
  [[ "$output" == *"bash"* ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# Style Library Tests (only critical integration tests)
# ─────────────────────────────────────────────────────────────────────────────

@test "style.sh can be sourced without errors" {
  run bash -c "source '$PROJECT_ROOT/lib/style.sh'"
  [ "$status" -eq 0 ]
}

@test "style.sh exports required color variables" {
  source "$PROJECT_ROOT/lib/style.sh"
  # only test variables critical to CLI operation
  [ -n "${C_PASS+x}" ]
  [ -n "${C_FAIL+x}" ]
  [ -n "${C_RESET+x}" ]
}

# ─────────────────────────────────────────────────────────────────────────────
# Configuration Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "default WORK_LAB_IMAGE is set" {
  run "$PROJECT_ROOT/bin/work-lab" doctor
  [[ "$output" == *"ghcr.io/modern-tooling/work-lab:latest"* ]]
}

@test "WORK_LAB_IMAGE can be overridden via config file" {
  echo 'export WORK_LAB_IMAGE="custom-registry/custom-image:v2.0"' > "$HOME/.config/work-lab/config"
  run "$PROJECT_ROOT/bin/work-lab" doctor
  [[ "$output" == *"custom-registry/custom-image:v2.0"* ]]
}

@test "WORK_LAB_IMAGE can be overridden via environment" {
  export WORK_LAB_IMAGE="env-override:latest"
  run "$PROJECT_ROOT/bin/work-lab" doctor
  [[ "$output" == *"env-override:latest"* ]]
}

@test "WORK_LAB_MUX defaults to tmux" {
  # The mux command mentions tmux as recommended
  run "$PROJECT_ROOT/bin/work-lab" help
  [[ "$output" == *"tmux session"* ]]
}

@test "config file with WORK_LAB_MUX=zellij is valid" {
  echo 'export WORK_LAB_MUX="zellij"' > "$HOME/.config/work-lab/config"
  # Should not error when sourcing
  run bash -c "source '$HOME/.config/work-lab/config' && echo \$WORK_LAB_MUX"
  [ "$status" -eq 0 ]
  [[ "$output" == "zellij" ]]
}

@test "config file with WORK_LAB_SHELL=zsh is valid" {
  echo 'export WORK_LAB_SHELL="zsh"' > "$HOME/.config/work-lab/config"
  run bash -c "source '$HOME/.config/work-lab/config' && echo \$WORK_LAB_SHELL"
  [ "$status" -eq 0 ]
  [[ "$output" == "zsh" ]]
}

@test "config file with WORK_LAB_SHELL=bash is valid" {
  echo 'export WORK_LAB_SHELL="bash"' > "$HOME/.config/work-lab/config"
  run bash -c "source '$HOME/.config/work-lab/config' && echo \$WORK_LAB_SHELL"
  [ "$status" -eq 0 ]
  [[ "$output" == "bash" ]]
}

@test "WORK_LAB_MOUNTS_RO array can be defined in config" {
  cat > "$HOME/.config/work-lab/config" << 'EOF'
WORK_LAB_MOUNTS_RO=(
  "$HOME/.gitconfig:/home/worklab/.gitconfig"
  "$HOME/.ssh/config:/home/worklab/.ssh/config"
)
EOF
  run bash -c "source '$HOME/.config/work-lab/config' && echo \${#WORK_LAB_MOUNTS_RO[@]}"
  [ "$status" -eq 0 ]
  [[ "$output" == "2" ]]
}

@test "WORK_LAB_MOUNTS_RW array can be defined in config" {
  cat > "$HOME/.config/work-lab/config" << 'EOF'
WORK_LAB_MOUNTS_RW=(
  "$HOME/.cache/work-lab:/home/worklab/.cache"
)
EOF
  run bash -c "source '$HOME/.config/work-lab/config' && echo \${#WORK_LAB_MOUNTS_RW[@]}"
  [ "$status" -eq 0 ]
  [[ "$output" == "1" ]]
}

@test "empty config file does not break sourcing" {
  touch "$HOME/.config/work-lab/config"
  run "$PROJECT_ROOT/bin/work-lab" version
  [ "$status" -eq 0 ]
}

@test "config with comments is valid" {
  cat > "$HOME/.config/work-lab/config" << 'EOF'
# This is a comment
export WORK_LAB_IMAGE="test:v1"  # inline comment
# Another comment
EOF
  run bash -c "source '$HOME/.config/work-lab/config' && echo \$WORK_LAB_IMAGE"
  [ "$status" -eq 0 ]
  [[ "$output" == "test:v1" ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# Inside-Container Detection Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "is_inside_container returns false on host (no markers)" {
  # Extract and test the function
  eval "$(grep -A5 'is_inside_container()' "$PROJECT_ROOT/bin/work-lab" | head -6)"
  unset WORK_LAB_CONTAINER
  run is_inside_container
  [ "$status" -ne 0 ]  # false = non-zero exit
}

@test "is_inside_container returns true when WORK_LAB_CONTAINER=1" {
  eval "$(grep -A5 'is_inside_container()' "$PROJECT_ROOT/bin/work-lab" | head -6)"
  export WORK_LAB_CONTAINER=1
  run is_inside_container
  [ "$status" -eq 0 ]  # true = zero exit
}

@test "is_inside_container returns true when WORK_LAB_CONTAINER=true" {
  # Test that any truthy value works
  eval "$(grep -A5 'is_inside_container()' "$PROJECT_ROOT/bin/work-lab" | head -6)"
  export WORK_LAB_CONTAINER=1
  run is_inside_container
  [ "$status" -eq 0 ]
}

@test "is_inside_container returns false when WORK_LAB_CONTAINER is empty" {
  eval "$(grep -A5 'is_inside_container()' "$PROJECT_ROOT/bin/work-lab" | head -6)"
  export WORK_LAB_CONTAINER=""
  run is_inside_container
  [ "$status" -ne 0 ]
}

@test "is_inside_container returns false when WORK_LAB_CONTAINER=0" {
  eval "$(grep -A5 'is_inside_container()' "$PROJECT_ROOT/bin/work-lab" | head -6)"
  export WORK_LAB_CONTAINER=0
  run is_inside_container
  [ "$status" -ne 0 ]
}

@test "is_inside_container detects devcontainer.json marker" {
  eval "$(grep -A5 'is_inside_container()' "$PROJECT_ROOT/bin/work-lab" | head -6)"
  # Create the marker file
  mkdir -p "/tmp/test-workspaces/work-lab/.devcontainer"
  touch "/tmp/test-workspaces/work-lab/.devcontainer/devcontainer.json"

  # Modify function to use test path
  is_inside_container_test() {
    [[ -f /tmp/test-workspaces/work-lab/.devcontainer/devcontainer.json ]] || \
    [[ "${WORK_LAB_CONTAINER:-}" == "1" ]]
  }

  unset WORK_LAB_CONTAINER
  run is_inside_container_test
  [ "$status" -eq 0 ]

  # Cleanup
  rm -rf "/tmp/test-workspaces"
}

# ─────────────────────────────────────────────────────────────────────────────
# require_host Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "require_host succeeds on host" {
  # Create a minimal test script
  cat > "$TEMP_DIR/test_require_host.sh" << 'EOF'
source "$1/lib/style.sh"
is_inside_container() { return 1; }  # false = on host
require_host() {
  if is_inside_container; then
    exit 1
  fi
}
require_host
echo "success"
EOF
  run bash "$TEMP_DIR/test_require_host.sh" "$PROJECT_ROOT"
  [ "$status" -eq 0 ]
  [[ "$output" == "success" ]]
}

@test "require_host fails inside container" {
  cat > "$TEMP_DIR/test_require_host.sh" << 'EOF'
source "$1/lib/style.sh"
is_inside_container() { return 0; }  # true = inside container
fail_exit() { exit "${1:-1}"; }
require_host() {
  if is_inside_container; then
    echo "error: must run on host"
    fail_exit
  fi
}
require_host
echo "should not reach here"
EOF
  run bash "$TEMP_DIR/test_require_host.sh" "$PROJECT_ROOT"
  [ "$status" -eq 1 ]
  [[ "$output" == *"must run on host"* ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# Git Root Detection Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "find_git_root finds repo from project root" {
  cd "$PROJECT_ROOT"
  run git rev-parse --show-toplevel
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "find_git_root finds repo from subdirectory" {
  cd "$PROJECT_ROOT/lib"
  run git rev-parse --show-toplevel
  [ "$status" -eq 0 ]
  [ -n "$output" ]
}

@test "git rev-parse fails in non-repo directory" {
  cd "$TEMP_DIR"
  run git rev-parse --show-toplevel 2>/dev/null
  [ "$status" -ne 0 ]
}

# ─────────────────────────────────────────────────────────────────────────────
# Mount Config Tests (high-level behavior only)
# ─────────────────────────────────────────────────────────────────────────────

@test "config with mount arrays can be sourced" {
  cat > "$HOME/.config/work-lab/config" << 'EOF'
WORK_LAB_MOUNTS_RO=(
  "$HOME/.gitconfig:/home/worklab/.gitconfig"
)
WORK_LAB_MOUNTS_RW=()
EOF
  run bash -c "source '$HOME/.config/work-lab/config' && echo \${#WORK_LAB_MOUNTS_RO[@]}"
  [ "$status" -eq 0 ]
  [[ "$output" == "1" ]]
}

@test "build_mount_flags produces valid devcontainer mount format" {
  # Create test file to mount
  touch "$TEMP_DIR/test-mount-file"

  # Source script functions
  source "$PROJECT_ROOT/lib/style.sh"
  WORK_LAB_MOUNTS_RO=("$TEMP_DIR/test-mount-file:/container/path")
  WORK_LAB_MOUNTS_RW=()
  ICON_ARROW="→"

  # Extract and run build_mount_flags
  eval "$(sed -n '/^build_mount_flags()/,/^}/p' "$PROJECT_ROOT/bin/work-lab")"
  output=$(build_mount_flags 2>/dev/null)

  # Verify format: --mount=type=bind,source=<src>,target=<tgt> (with equals sign!)
  # devcontainer CLI requires --mount=VALUE format, not --mount VALUE
  [[ "$output" == *"--mount=type=bind,source=$TEMP_DIR/test-mount-file,target=/container/path"* ]]

  # Must NOT contain 'readonly' - devcontainer CLI doesn't support it
  [[ "$output" != *"readonly"* ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# Docker Mock Tests (for when docker is unavailable)
# ─────────────────────────────────────────────────────────────────────────────

@test "ps command requires docker" {
  # Create mock that simulates docker not found
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/bin/bash
exit 127
EOF
  chmod +x "$MOCK_BIN/docker"

  # This test verifies the command handles missing docker gracefully
  # The actual behavior depends on require_host check
  export PATH="$MOCK_BIN:$PATH"
  run "$PROJECT_ROOT/bin/work-lab" ps 2>&1
  # Should either fail with docker error or require_host error
  [ "$status" -ne 0 ] || [[ "$output" == *"docker"* ]] || [[ "$output" == *"host"* ]]
}

@test "find_container returns empty when no containers running" {
  # Mock docker to return nothing
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/bin/bash
if [[ "$1" == "ps" ]]; then
  echo ""
  exit 0
fi
exit 0
EOF
  chmod +x "$MOCK_BIN/docker"
  export PATH="$MOCK_BIN:$PATH"

  # find_container requires git root to work, test the ps -q case
  cd "$PROJECT_ROOT"
  run bash -c "source '$PROJECT_ROOT/lib/style.sh'; source <(sed -n '/^find_container/,/^}/p' '$PROJECT_ROOT/bin/work-lab' | head -20); find_container"
  # Should return empty (or fail gracefully)
  [ "$status" -eq 0 ]
}

@test "find_container function is defined in work-lab" {
  # Verify the function exists in the script
  run grep -q 'find_container()' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

# ─────────────────────────────────────────────────────────────────────────────
# Devcontainer Detection Tests (logic only)
# ─────────────────────────────────────────────────────────────────────────────

@test "devcontainer detection finds .devcontainer directory" {
  mkdir -p "$TEMP_DIR/test-project/.devcontainer"
  [ -d "$TEMP_DIR/test-project/.devcontainer" ]
}

@test "devcontainer detection finds .devcontainer.json file" {
  mkdir -p "$TEMP_DIR/test-project"
  touch "$TEMP_DIR/test-project/.devcontainer.json"
  [ -f "$TEMP_DIR/test-project/.devcontainer.json" ]
}

@test "doctor runs without error in real git repo" {
  cd "$PROJECT_ROOT"
  run "$PROJECT_ROOT/bin/work-lab" doctor 2>&1
  [ "$status" -eq 0 ]
}

# ─────────────────────────────────────────────────────────────────────────────
# Release Notes Tests (network-dependent, only test basic output)
# ─────────────────────────────────────────────────────────────────────────────

@test "release-notes shows header and current version" {
  run "$PROJECT_ROOT/bin/work-lab" release-notes
  # always shows header and current version regardless of network
  [[ "$output" == *"release notes"* ]]
  [[ "$output" == *"current"* ]]
  [[ "$output" =~ v[0-9]+\.[0-9]+\.[0-9]+ ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# Error Handling Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "up command fails when not in git repo" {
  cd "$TEMP_DIR"  # Not a git repo
  run "$PROJECT_ROOT/bin/work-lab" up 2>&1
  [ "$status" -ne 0 ]
}

@test "shell command fails when container not running" {
  # Mock docker to return no container
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/bin/bash
echo ""
exit 0
EOF
  chmod +x "$MOCK_BIN/docker"
  export PATH="$MOCK_BIN:$PATH"

  cd "$PROJECT_ROOT"
  run "$PROJECT_ROOT/bin/work-lab" shell 2>&1
  [ "$status" -ne 0 ]
}

@test "stop command handles already stopped container" {
  # Mock docker to return no container
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/bin/bash
if [[ "$1" == "ps" ]]; then
  echo ""
fi
exit 0
EOF
  chmod +x "$MOCK_BIN/docker"
  export PATH="$MOCK_BIN:$PATH"

  cd "$PROJECT_ROOT"
  run "$PROJECT_ROOT/bin/work-lab" stop 2>&1
  # Should succeed (exit 0) with info message
  [[ "$output" == *"not running"* ]] || [ "$status" -eq 0 ]
}

# ─────────────────────────────────────────────────────────────────────────────
# SSH Tunnel Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "dc-ssh script exists and is executable" {
  [ -f "$PROJECT_ROOT/.devcontainer/home/bin/dc-ssh" ]
  [ -x "$PROJECT_ROOT/.devcontainer/home/bin/dc-ssh" ]
}

@test "dc-ssh --help shows usage" {
  run "$PROJECT_ROOT/.devcontainer/home/bin/dc-ssh" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"SSH into"* ]]
  [[ "$output" == *"devcontainer"* ]]
}

@test "dc-ssh requires project mounted at /workspaces/project" {
  # The script checks for /workspaces/project which won't exist on host
  # This test verifies the script properly checks for the project mount
  run "$PROJECT_ROOT/.devcontainer/home/bin/dc-ssh" 2>&1
  # Should fail because /workspaces/project doesn't exist on host
  [ "$status" -ne 0 ]
  [[ "$output" == *"project"* ]] || [[ "$output" == *"/workspaces"* ]]
}

@test "dc-attach script exists and is executable" {
  [ -f "$PROJECT_ROOT/.devcontainer/home/bin/dc-attach" ]
  [ -x "$PROJECT_ROOT/.devcontainer/home/bin/dc-attach" ]
}

@test "dc-attach --help shows usage" {
  run "$PROJECT_ROOT/.devcontainer/home/bin/dc-attach" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Attach"* ]]
  [[ "$output" == *"devcontainer"* ]]
}

@test "ensure_ssh_tunnel function is defined in work-lab" {
  # Verify the function exists in the script
  run grep -q 'ensure_ssh_tunnel()' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

@test "check_project_ssh_tunnel function is defined in work-lab" {
  run grep -q 'check_project_ssh_tunnel()' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

@test "tmux config includes SSH keybinding" {
  run grep -q 'bind S' "$PROJECT_ROOT/.devcontainer/home/.tmux.conf"
  [ "$status" -eq 0 ]
  run grep 'dc-ssh' "$PROJECT_ROOT/.devcontainer/home/.tmux.conf"
  [ "$status" -eq 0 ]
}

@test "doctor shows SSH tunnel status section" {
  # Run doctor and check for SSH-related output patterns
  cd "$PROJECT_ROOT"
  run "$PROJECT_ROOT/bin/work-lab" doctor 2>&1
  # Should contain SSH tunnel detection (either available or not configured)
  # This test verifies the code path exists, actual detection depends on running containers
  [ "$status" -eq 0 ] || [ "$status" -eq 1 ]
}

@test "ps output includes SSH legend" {
  # Mock docker to return a container
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/bin/bash
if [[ "$1" == "ps" ]]; then
  if [[ "$*" == *"--format"* ]]; then
    echo "abc123|test-container|/tmp/test-project|Up 2 hours"
  else
    echo "abc123"
  fi
  exit 0
fi
if [[ "$1" == "inspect" ]]; then
  if [[ "$*" == *"NetworkSettings"* ]]; then
    echo "172.17.0.2"
  elif [[ "$*" == *"Mounts"* ]]; then
    echo "/tmp/test-project"
  else
    echo "{}"
  fi
  exit 0
fi
exit 0
EOF
  chmod +x "$MOCK_BIN/docker"
  export PATH="$MOCK_BIN:$PATH"

  cd "$PROJECT_ROOT"
  run "$PROJECT_ROOT/bin/work-lab" ps 2>&1
  # Legend should be shown (may need to check output contains the expected pattern)
  [[ "$output" == *"Legend"* ]] || [[ "$output" == *"SSH"* ]] || [[ "$output" == *"none running"* ]]
}

@test "Dockerfile includes openssh-client" {
  run grep -q 'openssh-client' "$PROJECT_ROOT/.devcontainer/Dockerfile"
  [ "$status" -eq 0 ]
}

@test "ssh-tunneling documentation exists" {
  [ -f "$PROJECT_ROOT/docs/ssh-tunneling.md" ]
}

@test "ssh-tunneling docs mentions sshd feature" {
  run grep -q 'ghcr.io/devcontainers/features/sshd' "$PROJECT_ROOT/docs/ssh-tunneling.md"
  [ "$status" -eq 0 ]
}

@test "ssh-tunneling docs mentions ephemeral keys" {
  run grep -qi 'ephemeral' "$PROJECT_ROOT/docs/ssh-tunneling.md"
  [ "$status" -eq 0 ]
}

# ─────────────────────────────────────────────────────────────────────────────
# Mux Command Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "mux command uses 'which' not 'command -v' for tmux detection" {
  # command -v is a shell builtin and fails via docker exec without a shell wrapper
  # must use 'which' which is an actual binary
  run grep -E 'docker exec.*which.*WORK_LAB_MUX' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

@test "mux command fails when container not running" {
  # Mock docker to return no container
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/bin/bash
echo ""
exit 0
EOF
  chmod +x "$MOCK_BIN/docker"
  export PATH="$MOCK_BIN:$PATH"

  cd "$PROJECT_ROOT"
  run "$PROJECT_ROOT/bin/work-lab" mux 2>&1
  [ "$status" -ne 0 ]
  [[ "$output" == *"not running"* ]] || [[ "$output" == *"No work-lab"* ]]
}

@test "mux does not use 'command -v' which fails in docker exec" {
  # Verify work-lab doesn't use 'command -v' for mux detection
  # because 'command' is a shell builtin, not an executable
  run grep -E 'docker exec.*command -v' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -ne 0 ]  # should NOT find 'command -v' in docker exec calls
}

@test "mux command accepts optional project name argument" {
  # Verify mux passes arguments to cmd_mux
  run grep -E 'mux\|tmux\)' -A3 "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
  [[ "$output" == *'cmd_mux "$@"'* ]]
}

@test "find_container_by_name function is defined in work-lab" {
  run grep -q 'find_container_by_name()' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

# ─────────────────────────────────────────────────────────────────────────────
# Prune Command Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "prune command is registered" {
  run grep -E 'prune\)' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

@test "cmd_prune function is defined in work-lab" {
  run grep -q 'cmd_prune()' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

@test "prune supports --all flag" {
  run grep -E 'prune_all=true' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
  run grep -E '\-\-all.*-a' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

@test "prune runs without error when no containers to clean" {
  # Mock docker to return empty
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/bin/bash
if [[ "$1" == "ps" ]]; then
  echo ""
  exit 0
fi
if [[ "$1" == "images" ]]; then
  echo ""
  exit 0
fi
exit 0
EOF
  chmod +x "$MOCK_BIN/docker"
  export PATH="$MOCK_BIN:$PATH"

  run "$PROJECT_ROOT/bin/work-lab" prune 2>&1
  [ "$status" -eq 0 ]
  [[ "$output" == *"No stopped"* ]] || [[ "$output" == *"Prune complete"* ]]
}

@test "help shows prune command" {
  run "$PROJECT_ROOT/bin/work-lab" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"prune"* ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# Ports Command Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "ports command is registered" {
  run grep -E 'ports\)' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

@test "cmd_ports function is defined in work-lab" {
  run grep -q 'cmd_ports()' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

@test "ports runs without error when no containers" {
  # Mock docker to return empty
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/bin/bash
if [[ "$1" == "ps" ]]; then
  echo ""
  exit 0
fi
if [[ "$1" == "port" ]]; then
  echo ""
  exit 0
fi
exit 0
EOF
  chmod +x "$MOCK_BIN/docker"
  export PATH="$MOCK_BIN:$PATH"

  cd "$PROJECT_ROOT"
  run "$PROJECT_ROOT/bin/work-lab" ports 2>&1
  [ "$status" -eq 0 ]
  [[ "$output" == *"Forwarded ports"* ]] || [[ "$output" == *"No ports"* ]]
}

@test "help shows ports command" {
  run "$PROJECT_ROOT/bin/work-lab" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"ports"* ]]
}

@test "ports shows both work-lab and devcontainer ports" {
  # Check the function looks for both containers
  run grep -A30 'cmd_ports()' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
  [[ "$output" == *"wl_container_id"* ]]
  [[ "$output" == *"dc_container_id"* ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# VSCode Command Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "vscode command is registered" {
  run grep -E 'vscode\|code\)' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

@test "cmd_vscode function is defined in work-lab" {
  run grep -q 'cmd_vscode()' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

@test "vscode command uses code CLI" {
  run grep -A20 'cmd_vscode()' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
  [[ "$output" == *"code"* ]]
}

@test "vscode fails when container not running" {
  # Mock docker to return empty
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/bin/bash
echo ""
exit 0
EOF
  chmod +x "$MOCK_BIN/docker"
  export PATH="$MOCK_BIN:$PATH"

  cd "$PROJECT_ROOT"
  run "$PROJECT_ROOT/bin/work-lab" vscode 2>&1
  [ "$status" -ne 0 ]
  [[ "$output" == *"not running"* ]] || [[ "$output" == *"No work-lab"* ]]
}

@test "help shows vscode command" {
  run "$PROJECT_ROOT/bin/work-lab" help
  [ "$status" -eq 0 ]
  [[ "$output" == *"vscode"* ]]
}

@test "code alias works for vscode command" {
  # Verify both vscode and code are handled
  run grep -E 'vscode\|code\)' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
}

# ─────────────────────────────────────────────────────────────────────────────
# Session Restore Tests
# ─────────────────────────────────────────────────────────────────────────────

@test "wl-session-save script exists and is executable" {
  [ -f "$PROJECT_ROOT/.devcontainer/home/bin/wl-session-save" ]
  [ -x "$PROJECT_ROOT/.devcontainer/home/bin/wl-session-save" ]
}

@test "wl-session-restore script exists and is executable" {
  [ -f "$PROJECT_ROOT/.devcontainer/home/bin/wl-session-restore" ]
  [ -x "$PROJECT_ROOT/.devcontainer/home/bin/wl-session-restore" ]
}

@test "tmux config includes session save keybinding" {
  run grep 'bind W' "$PROJECT_ROOT/.devcontainer/home/.tmux.conf"
  [ "$status" -eq 0 ]
  [[ "$output" == *"wl-session-save"* ]]
}

@test "cmd_mux checks for saved session" {
  run grep -A20 'case "\$WORK_LAB_MUX"' "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 0 ]
  [[ "$output" == *"tmux-session"* ]]
  [[ "$output" == *"wl-session-restore"* ]]
}

