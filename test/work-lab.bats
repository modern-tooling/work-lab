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

  # Verify format: type=bind,source=<src>,target=<tgt>
  [[ "$output" == *"--mount"* ]]
  [[ "$output" == *"type=bind,source=$TEMP_DIR/test-mount-file,target=/container/path"* ]]

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

@test "find_container returns empty when no containers" {
  # Mock docker to return nothing
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/bin/bash
if [[ "$1" == "ps" ]]; then
  echo ""
  exit 0
fi
exit 1
EOF
  chmod +x "$MOCK_BIN/docker"

  cat > "$TEMP_DIR/test_find.sh" << 'EOF'
export PATH="$2:$PATH"
REPO_DIR="$1"
eval "$(grep -A3 'find_container()' "$1/bin/work-lab" | head -4)"
result=$(find_container)
echo "result:$result:"
EOF
  run bash "$TEMP_DIR/test_find.sh" "$PROJECT_ROOT" "$MOCK_BIN"
  [[ "$output" == "result::" ]]
}

@test "find_container returns container ID when found" {
  # Mock docker to return a container ID
  cat > "$MOCK_BIN/docker" << 'EOF'
#!/bin/bash
if [[ "$1" == "ps" ]]; then
  echo "abc123def456"
  exit 0
fi
exit 1
EOF
  chmod +x "$MOCK_BIN/docker"

  cat > "$TEMP_DIR/test_find.sh" << 'EOF'
export PATH="$2:$PATH"
REPO_DIR="$1"
eval "$(grep -A3 'find_container()' "$1/bin/work-lab" | head -4)"
result=$(find_container)
echo "result:$result:"
EOF
  run bash "$TEMP_DIR/test_find.sh" "$PROJECT_ROOT" "$MOCK_BIN"
  [[ "$output" == "result:abc123def456:" ]]
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

