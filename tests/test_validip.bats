#!/usr/bin/env bats
# Tests for validip script and valid_ip() function

load 'helpers/setup'

# =============================================================================
# valid_ip() Function Tests - Valid IPs
# =============================================================================

@test "valid_ip accepts standard private IP 192.168.1.1" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip "192.168.1.1"
  [ "$status" -eq 0 ]
}

@test "valid_ip accepts minimum IP 0.0.0.0" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip "0.0.0.0"
  [ "$status" -eq 0 ]
}

@test "valid_ip accepts maximum IP 255.255.255.255" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip "255.255.255.255"
  [ "$status" -eq 0 ]
}

@test "valid_ip accepts localhost 127.0.0.1" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip "127.0.0.1"
  [ "$status" -eq 0 ]
}

@test "valid_ip accepts public IP 8.8.8.8" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip "8.8.8.8"
  [ "$status" -eq 0 ]
}

# =============================================================================
# valid_ip() Function Tests - Invalid IPs
# =============================================================================

@test "valid_ip rejects octet > 255 (256.1.1.1)" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip "256.1.1.1"
  [ "$status" -eq 1 ]
}

@test "valid_ip rejects empty string" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip ""
  [ "$status" -eq 1 ]
}

@test "valid_ip rejects non-numeric (abc.def.ghi.jkl)" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip "abc.def.ghi.jkl"
  [ "$status" -eq 1 ]
}

@test "valid_ip rejects too few octets (192.168.1)" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip "192.168.1"
  [ "$status" -eq 1 ]
}

@test "valid_ip rejects too many octets (192.168.1.1.1)" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip "192.168.1.1.1"
  [ "$status" -eq 1 ]
}

@test "valid_ip rejects negative numbers (-1.0.0.0)" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip "-1.0.0.0"
  [ "$status" -eq 1 ]
}

# =============================================================================
# Executable Mode Tests
# =============================================================================

@test "validip executable shows help with -h" {
  run "$BATS_TEST_DIRNAME/../validip" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Validate IPv4 address format"* ]]
}

@test "validip executable shows help with --help" {
  run "$BATS_TEST_DIRNAME/../validip" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "validip executable shows version with -V" {
  run "$BATS_TEST_DIRNAME/../validip" -V
  [ "$status" -eq 0 ]
  [[ "$output" == *"validip"* ]]
  [[ "$output" == *"1."* ]]  # Version starts with 1.
}

@test "validip executable shows version with --version" {
  run "$BATS_TEST_DIRNAME/../validip" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"validip"* ]]
}

@test "validip executable returns 0 for valid IP" {
  run "$BATS_TEST_DIRNAME/../validip" "10.0.0.1"
  [ "$status" -eq 0 ]
}

@test "validip executable returns 1 for invalid IP" {
  run "$BATS_TEST_DIRNAME/../validip" "999.999.999.999"
  [ "$status" -eq 1 ]
}

@test "validip executable returns 22 for unknown option" {
  run "$BATS_TEST_DIRNAME/../validip" --invalid-option
  [ "$status" -eq 22 ]
  [[ "$output" == *"Unknown option"* ]]
}

# =============================================================================
# Sourced Mode Tests
# =============================================================================

@test "validip exports valid_ip function when sourced" {
  source "$BATS_TEST_DIRNAME/../validip"
  declare -F valid_ip
}

@test "sourcing validip does not produce output" {
  run bash -c 'source "$1" && echo "done"' -- "$BATS_TEST_DIRNAME/../validip"
  [ "$status" -eq 0 ]
  [ "$output" = "done" ]
}

#fin
