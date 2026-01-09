# work-lab Makefile

.PHONY: test test-verbose lint help

# Default target
help:
	@echo "work-lab development commands"
	@echo ""
	@echo "  make test          Run all tests"
	@echo "  make test-verbose  Run tests with verbose output"
	@echo "  make lint          Run shellcheck linter"
	@echo ""

# Run tests
test:
	@bats test/

# Run tests with verbose output
test-verbose:
	@bats --verbose-run test/

# Lint shell scripts
lint:
	@shellcheck bin/work-lab lib/style.sh .devcontainer/*.sh || true
