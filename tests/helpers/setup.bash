#!/usr/bin/env bash
# Common test setup and teardown for bats tests

# Get the project root directory
PROJECT_ROOT="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
export PROJECT_ROOT

# Temp directory for test files
TEST_TMPDIR="${BATS_TMPDIR:-/tmp}/internetip_tests_$$"
export TEST_TMPDIR

# Setup function - runs before each test
setup() {
  mkdir -p "$TEST_TMPDIR"
  # Clean any previous test artifacts
  rm -f "$TEST_TMPDIR"/*
}

# Teardown function - runs after each test
teardown() {
  # Clean up temp files
  rm -rf "$TEST_TMPDIR"
  # Remove any test IP files we created
  rm -f /tmp/test_*.txt
}

# Helper: Check if running as root
is_root() {
  ((EUID == 0))
}

# Helper: Skip test if not root
skip_if_not_root() {
  is_root || skip "Test requires root privileges"
  return 0
}

# Helper: Skip test if root (for testing non-root behavior)
skip_if_root() {
  is_root && skip "Test requires non-root user"
  return 0
}

# Helper: Verify output matches IPv4 pattern
is_valid_ipv4_format() {
  local ip="$1"
  [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]
}

#fin
