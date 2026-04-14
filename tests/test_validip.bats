#!/usr/bin/env bats
# Tests for validip script and valid_ip/valid_ip4/valid_ip6 functions

load 'helpers/setup'

# =============================================================================
# valid_ip() Function Tests - Valid IPv4
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
# valid_ip() Function Tests - Invalid IPv4
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

@test "valid_ip4 rejects leading-zero octets (010.0.0.1)" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip4 "010.0.0.1"
  [ "$status" -ne 0 ]
}

@test "valid_ip4 rejects 08.0.0.1 with no stderr noise" {
  source "$BATS_TEST_DIRNAME/../validip"
  run bash -c 'source "'"$BATS_TEST_DIRNAME"'/../validip"; valid_ip4 08.0.0.1 2>&1'
  [ "$status" -ne 0 ]
  [[ -z "$output" ]]
}

# =============================================================================
# valid_ip6() Function Tests - Valid IPv6
# =============================================================================

@test "valid_ip6 accepts loopback ::1" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "::1"
  [ "$status" -eq 0 ]
}

@test "valid_ip6 accepts all-zero ::" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "::"
  [ "$status" -eq 0 ]
}

@test "valid_ip6 accepts compressed 2001:db8::1" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "2001:db8::1"
  [ "$status" -eq 0 ]
}

@test "valid_ip6 accepts full 8-hextet form" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "2001:0db8:0000:0000:0000:0000:0000:0001"
  [ "$status" -eq 0 ]
}

@test "valid_ip6 accepts trailing compression 1::" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "1::"
  [ "$status" -eq 0 ]
}

@test "valid_ip6 accepts mid-compression 1::8" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "1::8"
  [ "$status" -eq 0 ]
}

@test "valid_ip6 accepts IPv4-mapped ::ffff:192.168.1.1" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "::ffff:192.168.1.1"
  [ "$status" -eq 0 ]
}

@test "valid_ip6 accepts IPv4-embedded 2001:db8::192.168.1.1" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "2001:db8::192.168.1.1"
  [ "$status" -eq 0 ]
}

@test "valid_ip6 accepts zone ID fe80::1%eth0" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "fe80::1%eth0"
  [ "$status" -eq 0 ]
}

@test "valid_ip6 accepts 7-hextet compression 1::2:3:4:5:6:7" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "1::2:3:4:5:6:7"
  [ "$status" -eq 0 ]
}

# =============================================================================
# valid_ip6() Function Tests - Invalid IPv6
# =============================================================================

@test "valid_ip6 rejects three consecutive colons 1:::2" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "1:::2"
  [ "$status" -eq 1 ]
}

@test "valid_ip6 rejects double compression 1::2::3" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "1::2::3"
  [ "$status" -eq 1 ]
}

@test "valid_ip6 rejects non-hex hextet g::1" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "g::1"
  [ "$status" -eq 1 ]
}

@test "valid_ip6 rejects oversized hextet 12345::1" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "12345::1"
  [ "$status" -eq 1 ]
}

@test "valid_ip6 rejects too many hextets (9 groups)" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "1:2:3:4:5:6:7:8:9"
  [ "$status" -eq 1 ]
}

@test "valid_ip6 rejects too few hextets without compression" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "1:2:3:4:5:6:7"
  [ "$status" -eq 1 ]
}

@test "valid_ip6 rejects compressed full-8 1:2:3:4:5:6:7::8" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "1:2:3:4:5:6:7::8"
  [ "$status" -eq 1 ]
}

@test "valid_ip6 rejects invalid IPv4 tail 2001:db8::1.2.3.256" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "2001:db8::1.2.3.256"
  [ "$status" -eq 1 ]
}

@test "valid_ip6 rejects bare IPv4 1.2.3.4" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "1.2.3.4"
  [ "$status" -eq 1 ]
}

@test "valid_ip6 rejects empty string" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 ""
  [ "$status" -eq 1 ]
}

# =============================================================================
# Family separation and dispatcher tests
# =============================================================================

@test "valid_ip4 rejects IPv6 address ::1" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip4 "::1"
  [ "$status" -eq 1 ]
}

@test "valid_ip6 rejects IPv4 address 192.168.1.1" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip6 "192.168.1.1"
  [ "$status" -eq 1 ]
}

@test "valid_ip dispatcher accepts IPv6 2001:db8::1" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip "2001:db8::1"
  [ "$status" -eq 0 ]
}

@test "valid_ip dispatcher accepts IPv4 10.0.0.1" {
  source "$BATS_TEST_DIRNAME/../validip"
  run valid_ip "10.0.0.1"
  [ "$status" -eq 0 ]
}

# =============================================================================
# Executable Mode Tests
# =============================================================================

@test "validip executable shows help with -h" {
  run "$BATS_TEST_DIRNAME/../validip" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"IPv4 and IPv6"* ]]
}

@test "validip executable shows help with --help" {
  run "$BATS_TEST_DIRNAME/../validip" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "validip executable shows help with trailing -h after IP" {
  run "$BATS_TEST_DIRNAME/../validip" "1.2.3.4" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "validip executable honors -- end-of-options sentinel" {
  run "$BATS_TEST_DIRNAME/../validip" -- "1.2.3.4"
  [ "$status" -eq 0 ]
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

@test "validip executable returns 0 for valid IPv4" {
  run "$BATS_TEST_DIRNAME/../validip" "10.0.0.1"
  [ "$status" -eq 0 ]
}

@test "validip executable returns 0 for valid IPv6" {
  run "$BATS_TEST_DIRNAME/../validip" "2001:db8::1"
  [ "$status" -eq 0 ]
}

@test "validip executable returns 0 for loopback ::1" {
  run "$BATS_TEST_DIRNAME/../validip" "::1"
  [ "$status" -eq 0 ]
}

@test "validip executable returns 1 for invalid IPv4" {
  run "$BATS_TEST_DIRNAME/../validip" "999.999.999.999"
  [ "$status" -eq 1 ]
}

@test "validip executable returns 1 for invalid IPv6" {
  run "$BATS_TEST_DIRNAME/../validip" "1:::2"
  [ "$status" -eq 1 ]
}

@test "validip executable returns 22 for unknown option" {
  run "$BATS_TEST_DIRNAME/../validip" --invalid-option
  [ "$status" -eq 22 ]
  [[ "$output" == *"Unknown option"* ]]
}

@test "validip executable returns 22 for missing argument" {
  run "$BATS_TEST_DIRNAME/../validip"
  [ "$status" -eq 22 ]
  [[ "$output" == *"Missing IP address"* ]]
}

# =============================================================================
# Sourced Mode Tests
# =============================================================================

@test "validip exports valid_ip function when sourced" {
  source "$BATS_TEST_DIRNAME/../validip"
  declare -F valid_ip
}

@test "validip exports valid_ip4 function when sourced" {
  source "$BATS_TEST_DIRNAME/../validip"
  declare -F valid_ip4
}

@test "validip exports valid_ip6 function when sourced" {
  source "$BATS_TEST_DIRNAME/../validip"
  declare -F valid_ip6
}

@test "sourcing validip does not produce output" {
  run bash -c 'source "$1" && echo "done"' -- "$BATS_TEST_DIRNAME/../validip"
  [ "$status" -eq 0 ]
  [ "$output" = "done" ]
}

#fin
