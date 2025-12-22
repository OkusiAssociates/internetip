#!/usr/bin/env bash
# Mock functions for testing

# File to capture logger output
MOCK_LOGGER_FILE="${TEST_TMPDIR:-/tmp}/mock_logger_output.txt"
export MOCK_LOGGER_FILE

# Mock logger - captures syslog calls for verification
mock_logger() {
  logger() {
    echo "LOGGER: $*" >> "$MOCK_LOGGER_FILE"
  }
  export -f logger
}

# Restore real logger
restore_logger() {
  unset -f logger
}

# Get captured logger output
get_logger_output() {
  [[ -f $MOCK_LOGGER_FILE ]] && cat "$MOCK_LOGGER_FILE"
}

# Clear logger output
clear_logger_output() {
  : > "$MOCK_LOGGER_FILE"
}

# Assert logger was called with pattern
assert_logger_contains() {
  local pattern="$1"
  grep -q "$pattern" "$MOCK_LOGGER_FILE"
}

#fin
