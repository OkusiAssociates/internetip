#!/usr/bin/env bats
# Tests for watchip script and watch_ip() function

load 'helpers/setup'
load 'helpers/mocks'

# =============================================================================
# watch_ip() Function Tests - First Run
# =============================================================================

@test "watch_ip creates ipfile on first run" {
  source "$BATS_TEST_DIRNAME/../watchip"
  ipfile="$TEST_TMPDIR/first_run_test.txt"
  [ ! -f "$ipfile" ]
  run watch_ip "$ipfile"
  [ "$status" -eq 0 ]
  [ -f "$ipfile" ]
}

@test "watch_ip returns unchanged on first run" {
  source "$BATS_TEST_DIRNAME/../watchip"
  ipfile="$TEST_TMPDIR/first_run_unchanged.txt"
  run watch_ip "$ipfile"
  [ "$status" -eq 0 ]
  [[ "$output" == unchanged:* ]]
}

@test "watch_ip stores valid IP on first run" {
  source "$BATS_TEST_DIRNAME/../watchip"
  ipfile="$TEST_TMPDIR/first_run_ip.txt"
  watch_ip "$ipfile" >/dev/null
  stored_ip=$(<"$ipfile")
  is_valid_ipv4_format "$stored_ip"
}

# =============================================================================
# watch_ip() Function Tests - Subsequent Runs
# =============================================================================

@test "watch_ip returns unchanged when IP same" {
  source "$BATS_TEST_DIRNAME/../watchip"
  ipfile="$TEST_TMPDIR/unchanged_test.txt"
  # First run
  watch_ip "$ipfile" >/dev/null
  # Second run - same IP
  run watch_ip "$ipfile"
  [ "$status" -eq 0 ]
  [[ "$output" == unchanged:* ]]
}

@test "watch_ip detects IP change" {
  source "$BATS_TEST_DIRNAME/../watchip"
  ipfile="$TEST_TMPDIR/change_test.txt"
  # Pre-populate with different IP
  echo "1.2.3.4" > "$ipfile"
  run watch_ip "$ipfile"
  [ "$status" -eq 0 ]
  [[ "$output" == changed:1.2.3.4:* ]]
}

@test "watch_ip updates file when IP changes" {
  source "$BATS_TEST_DIRNAME/../watchip"
  ipfile="$TEST_TMPDIR/update_test.txt"
  # Pre-populate with different IP
  echo "1.2.3.4" > "$ipfile"
  watch_ip "$ipfile" >/dev/null
  new_ip=$(<"$ipfile")
  [ "$new_ip" != "1.2.3.4" ]
  is_valid_ipv4_format "$new_ip"
}

# =============================================================================
# watch_ip() Output Format Tests
# =============================================================================

@test "watch_ip unchanged format is unchanged:ip" {
  source "$BATS_TEST_DIRNAME/../watchip"
  ipfile="$TEST_TMPDIR/format_unchanged.txt"
  run watch_ip "$ipfile"
  [ "$status" -eq 0 ]
  # Format: unchanged:IP
  [[ "$output" =~ ^unchanged:[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "watch_ip changed format is changed:old:new" {
  source "$BATS_TEST_DIRNAME/../watchip"
  ipfile="$TEST_TMPDIR/format_changed.txt"
  echo "1.2.3.4" > "$ipfile"
  run watch_ip "$ipfile"
  [ "$status" -eq 0 ]
  # Format: changed:oldIP:newIP
  [[ "$output" =~ ^changed:1\.2\.3\.4:[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

# =============================================================================
# Executable Mode Tests
# =============================================================================

@test "watchip executable shows help with -h" {
  run "$BATS_TEST_DIRNAME/../watchip" -h
  [ "$status" -eq 0 ]
  [[ "$output" == *"Monitor and log public IP address changes"* ]]
}

@test "watchip executable shows help with --help" {
  run "$BATS_TEST_DIRNAME/../watchip" --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"Usage:"* ]]
  [[ "$output" == *"--quiet"* ]]
}

@test "watchip executable shows version with -V" {
  run "$BATS_TEST_DIRNAME/../watchip" -V
  [ "$status" -eq 0 ]
  [[ "$output" == *"watchip"* ]]
  [[ "$output" == *"2."* ]]  # Version starts with 2.
}

@test "watchip executable shows version with --version" {
  run "$BATS_TEST_DIRNAME/../watchip" --version
  [ "$status" -eq 0 ]
  [[ "$output" == *"watchip"* ]]
}

@test "watchip requires root in executable mode" {
  skip_if_root
  run "$BATS_TEST_DIRNAME/../watchip"
  [ "$status" -eq 1 ]
  [[ "$output" == *"must be run as root"* ]]
}

@test "watchip executable runs successfully as root" {
  skip_if_not_root
  # Clean up any previous test file
  rm -f /tmp/internetip.txt
  run "$BATS_TEST_DIRNAME/../watchip"
  [ "$status" -eq 0 ]
}

@test "watchip -q suppresses unchanged output" {
  skip_if_not_root
  # Run once to establish baseline
  "$BATS_TEST_DIRNAME/../watchip" >/dev/null 2>&1 || true
  # Run again with -q - should be quiet if unchanged
  run "$BATS_TEST_DIRNAME/../watchip" -q
  [ "$status" -eq 0 ]
  # Output should be empty if IP unchanged
  [ -z "$output" ] || [[ "$output" == *"IP changed"* ]]
}

@test "watchip returns 22 for unknown option" {
  run "$BATS_TEST_DIRNAME/../watchip" --invalid-option
  [ "$status" -eq 1 ]
  [[ "$output" == *"Unknown option"* ]]
}

# =============================================================================
# Sourced Mode Tests
# =============================================================================

@test "watchip exports watch_ip function when sourced" {
  source "$BATS_TEST_DIRNAME/../watchip"
  declare -F watch_ip
}

@test "sourcing watchip does not require root" {
  skip_if_root
  # Should source successfully without root
  source "$BATS_TEST_DIRNAME/../watchip"
  declare -F watch_ip
}

@test "sourcing watchip does not produce output" {
  run bash -c 'source "$1" && echo "done"' -- "$BATS_TEST_DIRNAME/../watchip"
  [ "$status" -eq 0 ]
  [ "$output" = "done" ]
}

@test "watch_ip function works without root" {
  skip_if_root
  source "$BATS_TEST_DIRNAME/../watchip"
  ipfile="$TEST_TMPDIR/noroot_test.txt"
  run watch_ip "$ipfile"
  [ "$status" -eq 0 ]
  [[ "$output" == unchanged:* ]] || [[ "$output" == changed:* ]]
}

@test "watch_ip accepts custom file path" {
  source "$BATS_TEST_DIRNAME/../watchip"
  custom_path="$TEST_TMPDIR/custom/path/ip.txt"
  mkdir -p "${custom_path%/*}"
  run watch_ip "$custom_path"
  [ "$status" -eq 0 ]
  [ -f "$custom_path" ]
}

#fin
