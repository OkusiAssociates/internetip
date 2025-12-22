#!/usr/bin/env bats
# Tests for internetip script and get_internet_ip() function

load 'helpers/setup'

# =============================================================================
# get_internet_ip() Function Tests
# =============================================================================

@test "get_internet_ip returns valid IP from network" {
  source "$BATS_TEST_DIRNAME/../internetip"
  run get_internet_ip
  [ "$status" -eq 0 ]
  # Verify output matches IPv4 format
  is_valid_ipv4_format "$output"
}

@test "get_internet_ip output has no trailing whitespace" {
  source "$BATS_TEST_DIRNAME/../internetip"
  run get_internet_ip
  [ "$status" -eq 0 ]
  # Check no trailing newlines or spaces
  [[ "$output" == "${output%% }" ]]
  [[ "$output" == "${output%%$'\n'}" ]]
}

@test "internetip alias works same as get_internet_ip" {
  source "$BATS_TEST_DIRNAME/../internetip"
  ip1=$(get_internet_ip)
  ip2=$(internetip)
  [ "$ip1" = "$ip2" ]
}

# =============================================================================
# valid_ip() Availability Tests (sourced from validip)
# =============================================================================

@test "internetip sources valid_ip function" {
  source "$BATS_TEST_DIRNAME/../internetip"
  declare -F valid_ip
}

@test "valid_ip works after sourcing internetip" {
  source "$BATS_TEST_DIRNAME/../internetip"
  run valid_ip "192.168.1.1"
  [ "$status" -eq 0 ]
}

# =============================================================================
# Executable Mode Tests
# =============================================================================

@test "internetip executable shows help with -h" {
  run "$BATS_TEST_DIRNAME/../internetip" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Fetch and display public internet IP"* ]]
}

@test "internetip executable shows help with --help" {
  run "$BATS_TEST_DIRNAME/../internetip" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"INTERNETIP_CALL_URL"* ]]
}

@test "internetip executable shows version with -V" {
  run "$BATS_TEST_DIRNAME/../internetip" -V
  [ "$status" -eq 0 ]
  [[ "$output" == *"internetip"* ]]
  [[ "$output" == *"2."* ]]  # Version starts with 2.
}

@test "internetip executable shows version with --version" {
  run "$BATS_TEST_DIRNAME/../internetip" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"internetip"* ]]
}

@test "internetip executable returns valid IP" {
  run "$BATS_TEST_DIRNAME/../internetip"
  [ "$status" -eq 0 ]
  is_valid_ipv4_format "$output"
}

@test "internetip executable returns 22 for unknown option" {
  run "$BATS_TEST_DIRNAME/../internetip" --invalid-option
  [ "$status" -eq 22 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "internetip executable returns 22 for unexpected argument" {
  run "$BATS_TEST_DIRNAME/../internetip" somearg
  [ "$status" -eq 22 ]
  [[ "$output" == *"Unexpected argument"* ]]
}

# =============================================================================
# Root Behavior Tests
# =============================================================================

@test "internetip caches IP to /tmp/GatewayIP when run as root" {
  skip_if_not_root
  rm -f /tmp/GatewayIP
  run "$BATS_TEST_DIRNAME/../internetip"
  [ "$status" -eq 0 ]
  [ -f /tmp/GatewayIP ]
  cached_ip=$(<"/tmp/GatewayIP")
  [ "$cached_ip" = "$output" ]
}

@test "internetip does not create /tmp/GatewayIP when non-root" {
  skip_if_root
  rm -f /tmp/GatewayIP
  run "$BATS_TEST_DIRNAME/../internetip"
  [ "$status" -eq 0 ]
  [ ! -f /tmp/GatewayIP ]
}

# =============================================================================
# Sourced Mode Tests
# =============================================================================

@test "internetip exports get_internet_ip function when sourced" {
  source "$BATS_TEST_DIRNAME/../internetip"
  declare -F get_internet_ip
}

@test "internetip exports internetip function when sourced" {
  source "$BATS_TEST_DIRNAME/../internetip"
  declare -F internetip
}

@test "sourcing internetip does not produce output" {
  run bash -c 'source "$1" && echo "done"' -- "$BATS_TEST_DIRNAME/../internetip"
  [ "$status" -eq 0 ]
  [ "$output" = "done" ]
}

@test "sourcing internetip does not fetch IP (no side effects)" {
  # Sourcing should be fast - no network call
  start=$(date +%s%N)
  source "$BATS_TEST_DIRNAME/../internetip"
  end=$(date +%s%N)
  elapsed=$(( (end - start) / 1000000 ))  # ms
  # Should complete in under 100ms (network call takes seconds)
  [ "$elapsed" -lt 100 ]
}

# =============================================================================
# Environment Variable Tests
# =============================================================================

@test "help shows INTERNETIP_CALL_URL documentation" {
  run "$BATS_TEST_DIRNAME/../internetip" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"INTERNETIP_CALL_URL"* ]]
  [[ "$output" == *"Callback URL"* ]]
}

#fin
