#!/usr/bin/env bash
# tunnel-test.sh
# Integration tests for work-lab SSH tunnel functionality
#
# Prerequisites:
# - Docker running
# - work-lab CLI installed or available at bin/work-lab
#
# Usage:
#   ./test/integration/tunnel-test.sh
#
# This script creates a temporary test project with a devcontainer that has
# sshd enabled, then tests the SSH tunnel functionality.

set -Eeuo pipefail

# colors
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly RESET='\033[0m'

# find script location
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WORK_LAB="$PROJECT_ROOT/bin/work-lab"

# test state
TEST_PROJECT=""
CLEANUP_NEEDED=false
TESTS_RUN=0
TESTS_PASSED=0
TESTS_FAILED=0

log_info() { printf "${CYAN}[INFO]${RESET} %s\n" "$1"; }
log_pass() { printf "${GREEN}[PASS]${RESET} %s\n" "$1"; }
log_fail() { printf "${RED}[FAIL]${RESET} %s\n" "$1"; }
log_warn() { printf "${YELLOW}[WARN]${RESET} %s\n" "$1"; }

cleanup() {
  if [[ "$CLEANUP_NEEDED" == "true" ]] && [[ -n "$TEST_PROJECT" ]]; then
    log_info "Cleaning up test environment..."

    # stop test containers
    cd "$TEST_PROJECT" 2>/dev/null || true
    "$WORK_LAB" stop 2>/dev/null || true

    # remove test devcontainer
    local dc_name="test-tunnel-devcontainer"
    docker stop "$dc_name" 2>/dev/null || true
    docker rm "$dc_name" 2>/dev/null || true

    # remove shared network
    docker network rm work-lab-tunnel 2>/dev/null || true

    # remove test project directory
    if [[ -d "$TEST_PROJECT" ]]; then
      rm -rf "$TEST_PROJECT"
    fi

    log_info "Cleanup complete"
  fi
}
trap cleanup EXIT

assert_eq() {
  local expected="$1"
  local actual="$2"
  local msg="$3"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$expected" == "$actual" ]]; then
    log_pass "$msg"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    log_fail "$msg (expected: '$expected', got: '$actual')"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_file_exists() {
  local file="$1"
  local msg="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ -f "$file" ]]; then
    log_pass "$msg"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    log_fail "$msg (file not found: $file)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

assert_command_succeeds() {
  local cmd="$1"
  local msg="$2"
  TESTS_RUN=$((TESTS_RUN + 1))
  if eval "$cmd" >/dev/null 2>&1; then
    log_pass "$msg"
    TESTS_PASSED=$((TESTS_PASSED + 1))
    return 0
  else
    log_fail "$msg (command failed: $cmd)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
    return 1
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Prerequisites
# ─────────────────────────────────────────────────────────────────────────────

check_prerequisites() {
  log_info "Checking prerequisites..."

  if ! command -v docker &>/dev/null; then
    log_fail "Docker not found"
    exit 1
  fi

  if ! docker info &>/dev/null; then
    log_fail "Docker not running"
    exit 1
  fi

  if [[ ! -x "$WORK_LAB" ]]; then
    log_fail "work-lab CLI not found at $WORK_LAB"
    exit 1
  fi

  log_pass "Prerequisites OK"
}

# ─────────────────────────────────────────────────────────────────────────────
# Setup
# ─────────────────────────────────────────────────────────────────────────────

setup_test_project() {
  log_info "Creating test project with sshd-enabled devcontainer..."

  # create temp directory
  TEST_PROJECT="$(mktemp -d)/test-tunnel-project"
  mkdir -p "$TEST_PROJECT"
  CLEANUP_NEEDED=true

  # initialize git repo (required by work-lab)
  cd "$TEST_PROJECT"
  git init -q
  git config user.email "test@example.com"
  git config user.name "Test"
  echo "# Test Project" > README.md
  git add README.md
  git commit -q -m "Initial commit"

  # create devcontainer config with sshd feature
  mkdir -p .devcontainer
  cat > .devcontainer/devcontainer.json << 'EOF'
{
  "name": "test-tunnel-devcontainer",
  "image": "mcr.microsoft.com/devcontainers/base:ubuntu",
  "features": {
    "ghcr.io/devcontainers/features/sshd:1": {}
  },
  "runArgs": ["--name", "test-tunnel-devcontainer"]
}
EOF

  log_pass "Test project created at $TEST_PROJECT"
}

start_test_devcontainer() {
  log_info "Starting test devcontainer (this may take a minute)..."

  cd "$TEST_PROJECT"

  # use devcontainer CLI if available, otherwise docker run
  if command -v devcontainer &>/dev/null; then
    devcontainer up --workspace-folder "$TEST_PROJECT" 2>&1 | tail -5
  else
    # fallback: direct docker run with sshd
    docker run -d \
      --name test-tunnel-devcontainer \
      --label "devcontainer.local_folder=$TEST_PROJECT" \
      -v "$TEST_PROJECT:/workspaces/test-tunnel-project" \
      mcr.microsoft.com/devcontainers/base:ubuntu \
      sleep infinity

    # install and start sshd manually
    docker exec test-tunnel-devcontainer bash -c "
      apt-get update -qq && apt-get install -qq -y openssh-server >/dev/null 2>&1
      mkdir -p /run/sshd
      /usr/sbin/sshd
    "
  fi

  # wait for container to be ready
  sleep 2

  # verify container is running
  if docker ps --format '{{.Names}}' | grep -q 'test-tunnel-devcontainer'; then
    log_pass "Test devcontainer started"
  else
    log_fail "Test devcontainer failed to start"
    exit 1
  fi
}

start_work_lab() {
  log_info "Starting work-lab container..."

  cd "$TEST_PROJECT"
  "$WORK_LAB" up 2>&1 | tail -5

  # wait for container
  sleep 2

  if "$WORK_LAB" ps 2>&1 | grep -q 'work-lab'; then
    log_pass "work-lab container started"
  else
    log_fail "work-lab container failed to start"
    exit 1
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Tests
# ─────────────────────────────────────────────────────────────────────────────

test_tunnel_setup() {
  log_info "Testing SSH tunnel setup..."

  cd "$TEST_PROJECT"

  # trigger tunnel setup via shell command (runs ensure_ssh_tunnel on host)
  "$WORK_LAB" shell echo "trigger tunnel setup" 2>&1 || true

  # give it a moment
  sleep 1
}

test_worklab_dir_created() {
  log_info "Testing .work-lab directory creation..."

  assert_file_exists "$TEST_PROJECT/.work-lab/ssh-key" \
    "SSH private key created"

  assert_file_exists "$TEST_PROJECT/.work-lab/ssh-key.pub" \
    "SSH public key created"

  assert_file_exists "$TEST_PROJECT/.work-lab/ip" \
    "Devcontainer IP file created"

  assert_file_exists "$TEST_PROJECT/.work-lab/user" \
    "SSH user file created"
}

test_ssh_key_permissions() {
  log_info "Testing SSH key permissions..."

  local key_perms
  key_perms=$(stat -f "%OLp" "$TEST_PROJECT/.work-lab/ssh-key" 2>/dev/null || \
              stat -c "%a" "$TEST_PROJECT/.work-lab/ssh-key" 2>/dev/null)

  assert_eq "600" "$key_perms" "Private key has 600 permissions"
}

test_ip_file_content() {
  log_info "Testing IP file content..."

  local ip_content
  ip_content=$(cat "$TEST_PROJECT/.work-lab/ip" 2>/dev/null | tr -d '[:space:]')

  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$ip_content" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    log_pass "IP file contains valid IP address: $ip_content"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_fail "IP file does not contain valid IP (got: '$ip_content')"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

test_shared_network_created() {
  log_info "Testing shared Docker network..."

  TESTS_RUN=$((TESTS_RUN + 1))
  if docker network ls --format '{{.Name}}' | grep -q 'work-lab-tunnel'; then
    log_pass "work-lab-tunnel network exists"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_fail "work-lab-tunnel network not found"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

test_containers_on_shared_network() {
  log_info "Testing containers connected to shared network..."

  local network_containers
  network_containers=$(docker network inspect work-lab-tunnel \
    --format '{{range .Containers}}{{.Name}} {{end}}' 2>/dev/null)

  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$network_containers" == *"test-tunnel-devcontainer"* ]]; then
    log_pass "Devcontainer connected to work-lab-tunnel network"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_fail "Devcontainer not on work-lab-tunnel network"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

test_authorized_keys_injected() {
  log_info "Testing authorized_keys injection..."

  local auth_keys
  auth_keys=$(docker exec test-tunnel-devcontainer cat ~/.ssh/authorized_keys 2>/dev/null || echo "")

  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$auth_keys" == *"work-lab-tunnel"* ]]; then
    log_pass "Public key injected into devcontainer authorized_keys"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_fail "Public key not found in devcontainer authorized_keys"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

test_ssh_connectivity() {
  log_info "Testing SSH connectivity from work-lab..."

  cd "$TEST_PROJECT"

  # run dc-ssh --check from inside work-lab
  local check_result
  check_result=$("$WORK_LAB" shell "dc-ssh --check" 2>&1 && echo "OK" || echo "FAIL")

  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$check_result" == *"OK"* ]]; then
    log_pass "dc-ssh --check reports tunnel available"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_warn "dc-ssh --check failed (may be expected if sshd not fully ready)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

test_ssh_command_execution() {
  log_info "Testing SSH command execution..."

  cd "$TEST_PROJECT"

  # run a simple command via SSH tunnel
  local cmd_result
  cmd_result=$("$WORK_LAB" shell "dc-ssh whoami" 2>&1 || echo "FAIL")

  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ "$cmd_result" != *"FAIL"* ]] && [[ -n "$cmd_result" ]]; then
    log_pass "SSH command execution works (user: $(echo "$cmd_result" | tail -1))"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_warn "SSH command execution failed (may need sshd fully configured)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

test_gitignore_not_modified() {
  log_info "Testing .gitignore not auto-modified..."

  TESTS_RUN=$((TESTS_RUN + 1))
  if [[ ! -f "$TEST_PROJECT/.gitignore" ]] || \
     ! grep -q '.work-lab' "$TEST_PROJECT/.gitignore" 2>/dev/null; then
    log_pass ".gitignore not auto-modified with .work-lab"
    TESTS_PASSED=$((TESTS_PASSED + 1))
  else
    log_fail ".gitignore was auto-modified (should not happen)"
    TESTS_FAILED=$((TESTS_FAILED + 1))
  fi
}

# ─────────────────────────────────────────────────────────────────────────────
# Main
# ─────────────────────────────────────────────────────────────────────────────

print_summary() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════════"
  printf "  Tests: %d | " "$TESTS_RUN"
  printf "${GREEN}Passed: %d${RESET} | " "$TESTS_PASSED"
  printf "${RED}Failed: %d${RESET}\n" "$TESTS_FAILED"
  echo "═══════════════════════════════════════════════════════════════════"

  if [[ "$TESTS_FAILED" -gt 0 ]]; then
    exit 1
  fi
}

main() {
  echo ""
  echo "═══════════════════════════════════════════════════════════════════"
  echo "  work-lab SSH Tunnel Integration Tests"
  echo "═══════════════════════════════════════════════════════════════════"
  echo ""

  check_prerequisites

  echo ""
  echo "─────────────────────────────────────────────────────────────────"
  echo "  Setup"
  echo "─────────────────────────────────────────────────────────────────"

  setup_test_project
  start_test_devcontainer
  start_work_lab

  echo ""
  echo "─────────────────────────────────────────────────────────────────"
  echo "  Tests"
  echo "─────────────────────────────────────────────────────────────────"

  test_tunnel_setup
  test_worklab_dir_created
  test_ssh_key_permissions
  test_ip_file_content
  test_shared_network_created
  test_containers_on_shared_network
  test_authorized_keys_injected
  test_gitignore_not_modified
  test_ssh_connectivity
  test_ssh_command_execution

  print_summary
}

main "$@"
