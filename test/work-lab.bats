#!/usr/bin/env bats
# work-lab tests
# Run with: bats test/

# Setup - load the script functions without executing main
setup() {
  # Get the directory of this test file
  TEST_DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  PROJECT_ROOT="$(dirname "$TEST_DIR")"

  # Source style library for color variables
  source "$PROJECT_ROOT/lib/style.sh"

  # Create temp directory for test fixtures
  export TEMP_DIR="$(mktemp -d)"

  # Mock HOME for config tests
  export ORIGINAL_HOME="$HOME"
  export HOME="$TEMP_DIR"
  mkdir -p "$HOME/.config/work-lab"
}

teardown() {
  # Cleanup temp directory
  rm -rf "$TEMP_DIR"
  export HOME="$ORIGINAL_HOME"
}

# ─────────────────────────────────────────────────────────────────────────────
# Command parsing tests
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

@test "--help flag works" {
  run "$PROJECT_ROOT/bin/work-lab" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Commands:"* ]]
}

@test "unknown command shows error" {
  run "$PROJECT_ROOT/bin/work-lab" notacommand
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown command: notacommand"* ]]
}

@test "no command shows usage and exits non-zero" {
  run "$PROJECT_ROOT/bin/work-lab"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Commands:"* ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# dc command tests
# ─────────────────────────────────────────────────────────────────────────────

@test "dc without arguments shows usage" {
  run "$PROJECT_ROOT/bin/work-lab" dc
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage: work-lab dc"* ]]
  [[ "$output" == *"Examples:"* ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# Style library tests
# ─────────────────────────────────────────────────────────────────────────────

@test "style.sh exports color variables" {
  source "$PROJECT_ROOT/lib/style.sh"
  # Variables should be defined (may be empty if no color support)
  [ -n "${C_PRIMARY+x}" ]
  [ -n "${C_RESET+x}" ]
  [ -n "${C_PASS+x}" ]
  [ -n "${C_FAIL+x}" ]
}

@test "style.sh exports icon variables" {
  source "$PROJECT_ROOT/lib/style.sh"
  [ "$ICON_PASS" = "✓" ]
  [ "$ICON_FAIL" = "✖" ]
  [ "$ICON_WARN" = "⚠" ]
  [ "$ICON_ARROW" = "→" ]
}

@test "status_ok outputs checkmark" {
  source "$PROJECT_ROOT/lib/style.sh"
  run status_ok "test message"
  [[ "$output" == *"✓"* ]]
  [[ "$output" == *"test message"* ]]
}

@test "status_fail outputs X mark" {
  source "$PROJECT_ROOT/lib/style.sh"
  run status_fail "error message"
  [[ "$output" == *"✖"* ]]
  [[ "$output" == *"error message"* ]]
}

@test "hint outputs arrow" {
  source "$PROJECT_ROOT/lib/style.sh"
  run hint "suggestion"
  [[ "$output" == *"→"* ]]
  [[ "$output" == *"suggestion"* ]]
}

@test "tip outputs [tip] prefix" {
  source "$PROJECT_ROOT/lib/style.sh"
  run tip "advanced tip"
  [[ "$output" == *"[tip]"* ]]
  [[ "$output" == *"advanced tip"* ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# Configuration tests
# ─────────────────────────────────────────────────────────────────────────────

@test "uses default image when no config" {
  run "$PROJECT_ROOT/bin/work-lab" doctor
  [[ "$output" == *"ghcr.io/modern-tooling/work-lab:latest"* ]]
}

@test "sources user config file when present" {
  echo 'export WORK_LAB_IMAGE="custom-image:v1"' > "$HOME/.config/work-lab/config"
  run "$PROJECT_ROOT/bin/work-lab" doctor
  [[ "$output" == *"custom-image:v1"* ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# release-notes output tests
# ─────────────────────────────────────────────────────────────────────────────

@test "release-notes shows current version" {
  run "$PROJECT_ROOT/bin/work-lab" release-notes
  [ "$status" -eq 0 ]
  [[ "$output" == *"current"* ]]
}

# ─────────────────────────────────────────────────────────────────────────────
# Inside-container detection tests
# ─────────────────────────────────────────────────────────────────────────────

@test "is_inside_container returns false on host" {
  # Source the script in a way that gives us access to functions
  source <(grep -A5 'is_inside_container()' "$PROJECT_ROOT/bin/work-lab" | head -6)
  run is_inside_container
  [ "$status" -ne 0 ]  # Should return false (non-zero) on host
}

@test "is_inside_container returns true when WORK_LAB_CONTAINER=1" {
  source <(grep -A5 'is_inside_container()' "$PROJECT_ROOT/bin/work-lab" | head -6)
  export WORK_LAB_CONTAINER=1
  run is_inside_container
  [ "$status" -eq 0 ]  # Should return true (zero) when env var set
}
