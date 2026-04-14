# internetip

Bash toolkit for public IP address management. Detect your internet-facing IP, validate addresses, monitor for changes, and notify remote servers - ideal for dynamic DNS, server monitoring, and automated IP registration.

## Scripts

| Script | Version | Purpose | Exported Functions |
|--------|---------|---------|--------------------|
| `internetip` | 2.3.0 | Fetch and display public IP | `get_internet_ip` |
| `validip` | 1.2.0 | Validate IPv4 and IPv6 address format | `valid_ip`, `valid_ip4`, `valid_ip6` |
| `watchip` | 2.1.0 | Monitor for IP changes | `watch_ip` |

All scripts follow the [BASH-CODING-STANDARD](https://github.com/Open-Technology-Foundation/bash-coding-standard) and support dual-purpose usage (executable or sourceable as a module).

## Installation

```bash
# Clone
git clone https://github.com/OkusiAssociates/internetip.git
cd internetip

# Install via Makefile (BCS1212-compliant)
sudo make install              # Installs to /usr/local/bin + /etc/bash_completion.d
sudo make install PREFIX=/usr  # Or any standard prefix
sudo make uninstall            # Remove everything installed

# Or via the internetip script's built-in installer
sudo ./internetip install      # Symlinks scripts, installs bash completion
sudo internetip update         # Git pull + reinstall
sudo internetip uninstall      # Remove from /usr/local/bin

make help                      # Show all Makefile targets and variables
make test                      # Run the bats suite
make lint                      # Run shellcheck on all scripts
```

Both mechanisms install the three scripts to `$(BINDIR)` and three per-script completion files to `$(COMPDIR)`. The Makefile follows BCS1212: standard targets (`install`/`uninstall`/`check`/`test`/`help`) with overridable `PREFIX`/`BINDIR`/`MANDIR`/`COMPDIR`/`DESTDIR`.

Key difference between the two installers: `make install` copies scripts with `install(1)` (standard packaging behavior — supports `DESTDIR` for staged installs). `./internetip install` creates symlinks from the repo into `/usr/local/bin` (stays in sync when you `git pull` or `internetip update`). Use the script installer for development, the Makefile for packaging.

## Usage

### internetip

```bash
internetip              # Display current public IP
internetip -s           # Fetch IP and call callback URL
internetip -q           # Quiet mode (suppress info messages)
internetip -v           # Verbose mode
internetip -sv          # Combined options
internetip showurl      # Show current URL configuration
internetip -h           # Show help

# Administration (requires root)
sudo internetip install              # Install to /usr/local/bin
sudo internetip update               # Git pull + reinstall
sudo internetip uninstall            # Remove from /usr/local/bin
sudo internetip seturl               # Configure callback URL interactively
sudo internetip seturl='https://example.com?host=HOSTNAME&ip=GATEWAY_IP'
sudo internetip unseturl             # Remove URL configuration
```

**Commands:**

| Command | Description |
|---------|-------------|
| `install` | Install scripts to /usr/local/bin (requires root) |
| `update` | Git pull and reinstall (requires root) |
| `uninstall` | Remove scripts from /usr/local/bin (requires root) |
| `seturl [URL]` | Configure system-wide callback URL (requires root) |
| `showurl` | Show current callback URL configuration |
| `unseturl` | Remove system-wide URL configuration (requires root) |

**Options:**

| Option | Description |
|--------|-------------|
| `-s, -c, --call-url` | Call callback URL after fetching IP |
| `-v, --verbose` | Increase verbosity |
| `-q, --quiet` | Suppress informational output |
| `-h, --help` | Display help |
| `-V, --version` | Display version |

Long options (`--install`, `--set-url`, etc.) are also supported.

**URL Configuration:**

The callback URL supports template variables expanded at runtime. The `$` prefix is optional (`HOSTNAME` works the same as `$HOSTNAME`):

| Variable | Description | Example |
|----------|-------------|---------|
| `HOSTNAME` | System hostname | `webserver01` |
| `GATEWAY_IP` | Fetched public IP | `203.0.113.45` |
| `WIFI` | Active Wi-Fi SSID (via `iwgetid`/`nmcli`, falls back to `HOSTNAME`) | `MyNetwork` |
| `SCRIPT_NAME` | Script name | `internetip` |
| `VERSION` | Script version | `2.3.0` |

```bash
# Configure system-wide (writes to /etc/profile.d/ and systemd)
sudo internetip seturl
# Enter: https://example.com/ip.php?host=HOSTNAME&ip=GATEWAY_IP

# Or pass URL directly
sudo internetip seturl='https://example.com/ip.php?host=HOSTNAME&ip=GATEWAY_IP'

# View current configuration
internetip showurl

# Remove configuration
sudo internetip unseturl
```

**Tip:** When passing URLs through SSH or remote execution tools, use `%26` instead of `&` to prevent shell interpretation:
```bash
# Local execution (& works fine)
sudo internetip seturl='https://example.com?host=HOSTNAME&ip=GATEWAY_IP'

# Remote execution via SSH/scripts (use %26)
ssh host "internetip seturl='https://example.com?host=HOSTNAME%26ip=GATEWAY_IP'"
```
The server decodes `%26` back to `&` automatically.

**Environment Variables:**

| Variable | Description | Default |
|----------|-------------|---------|
| `INTERNETIP_CALL_URL` | Callback URL template | *(none)* |
| `INTERNETIP_PROFILE` | Profile file for URL config | `/etc/profile.d/internetip.sh` |
| `GATEWAY_IP_FILE` | Cached IP file | `/tmp/GatewayIP` |

When run as root, caches result to `GATEWAY_IP_FILE`.

All HTTP requests use curl with automatic retry (3 attempts, 5-second delay) for resilience against transient network errors. Callback URLs are fetched with full TLS certificate verification.

**Exit Codes** (BCS0602 canonical):

| Code | Name | Meaning |
|------|------|---------|
| `0`  | SUCCESS      | IP retrieved (and callback invoked if requested) |
| `3`  | ERR_NOENT    | Script file missing / unreadable path |
| `13` | ERR_ACCESS   | Operation requires root |
| `18` | ERR_NODEP    | `validip` dependency unreachable |
| `19` | ERR_CONFIG   | `INTERNETIP_CALL_URL` not configured |
| `21` | ERR_STATE    | Not a git repository (during `update`) |
| `22` | ERR_INVAL    | Unknown option or unexpected argument |
| `23` | ERR_NETWORK  | IP fetch failed, callback failed, or `git pull` failed |

**Output icons:** Messages use status icons for clarity: ◉ info, ▲ warn, ✓ success, ✗ error.

### validip

Validates both IPv4 and IPv6 addresses. Script mode auto-detects the family by the presence of `:` (IPv6) vs `.` (IPv4).

```bash
# IPv4
validip 192.168.1.1             && echo valid || echo invalid
validip 256.1.1.1               && echo valid || echo invalid

# IPv6
validip ::1                     && echo valid || echo invalid
validip 2001:db8::1             && echo valid || echo invalid
validip ::ffff:192.168.1.1      && echo valid || echo invalid  # IPv4-mapped
validip fe80::1%eth0            && echo valid || echo invalid  # zone ID

validip -h                      # Show help
```

**Supported IPv6 forms:** full 8-hextet, zero-compression (`::`), IPv4-mapped (`::ffff:1.2.3.4`), IPv4-embedded (`2001:db8::1.2.3.4`), and zone IDs (`fe80::1%eth0`).

**Exported functions when sourced:**

| Function | Accepts |
|----------|---------|
| `valid_ip <ip>` | IPv4 or IPv6 (auto-dispatched by presence of `:`) |
| `valid_ip4 <ip>` | IPv4 only |
| `valid_ip6 <ip>` | IPv6 only |

**Exit Codes:** 0 = valid, 1 = invalid, 22 = missing argument or invalid option

### watchip

```bash
watchip                 # Check for IP change
watchip -q              # Quiet mode (for cron)
watchip --log           # Display log file contents
```

**Options:**

| Option | Description |
|--------|-------------|
| `-l, --log` | Display log file contents |
| `-q, --quiet` | Suppress output when IP unchanged |
| `-h, --help` | Display help |
| `-V, --version` | Display version |

**Environment Variables:**

| Variable | Description | Default |
|----------|-------------|---------|
| `LOGFILE` | Log file path | `/var/log/watchip.log` (falls back to `~/.watchip.log`) |
| `IPFILE` | IP tracking file | `/tmp/watchip.txt` |

Logs state changes (initial IP, IP changes) to `LOGFILE`. When run as root, also logs to syslog (`local0.notice`). Argument-parsing errors are written to stderr only — they do not pollute the operational log. Typical cron entry:

```cron
*/5 * * * * /usr/local/bin/watchip -q
```

**Exit Codes** (BCS0602 canonical):

| Code | Name | Meaning |
|------|------|---------|
| `0`  | SUCCESS      | IP checked (initial, changed, or unchanged) |
| `18` | ERR_NODEP    | `internetip` dependency unreachable |
| `22` | ERR_INVAL    | Unknown option or unexpected argument |
| `23` | ERR_NETWORK  | Failed to fetch or validate current IP |

## Module Usage

All scripts can be sourced to use their functions directly:

```bash
# Fetch public IP
source internetip
ip=$(get_internet_ip)
echo "Current IP: $ip"

# Validate IP address
source validip
if valid_ip "$ip"; then
    echo "Valid"
fi

# Monitor for changes
source watchip
result=$(watch_ip /tmp/myapp_ip.txt)
case $result in
    initial:*)   echo "First run: ${result#initial:}" ;;
    changed:*)   echo "IP changed!" ;;
    unchanged:*) echo "IP unchanged" ;;
esac
```

## Architecture

```
watchip ──sources──> internetip ──sources──> validip
   │                     │                      │
   └─ watch_ip()         └─ get_internet_ip()   └─ valid_ip()
```

## Dependencies

| Dependency | Used By | Purpose |
|------------|---------|---------|
| `curl` | internetip | HTTP requests to ipecho.net (with retry logic) |
| `iwgetid` or `nmcli` | internetip | Resolve `$WIFI` template variable (optional; falls back to `HOSTNAME`) |
| `logger` | watchip | Syslog integration |
| Bash 5.0+ | All | Shell interpreter (uses `${var@Q}`, `printf '%(fmt)T'`, `declare -n`) |
| `bats-core` | tests | Test framework (optional) |

## Testing

A comprehensive test suite using [bats-core](https://github.com/bats-core/bats-core) (Bash Automated Testing System).

### Running Tests

```bash
make test                   # Via Makefile (calls bats tests/)
./run_tests.sh              # Run as user (skips root tests)
./run_tests.sh -a           # Run all including root tests
./run_tests.sh -v           # Verbose TAP output

# Or directly with bats
bats tests/                 # All tests
bats tests/test_validip.bats  # Single test file
sudo bats tests/            # Root-required tests
```

### Test Coverage

| Test File | Tests | Coverage |
|-----------|-------|----------|
| `test_validip.bats` | 54 | IPv4 + IPv6 validation, family dispatch, leading-zero rejection, CLI options, `--` sentinel, sourcing |
| `test_internetip.bats` | 56 | Network fetch, caching, verbose/quiet, install/update/uninstall, URL config, canonical exit codes |
| `test_watchip.bats` | 30 | Change detection, logging, file ops, argparse-no-log-pollution |

**Total: 140 tests** covering:
- Valid/invalid IPv4 and IPv6 formats
- IPv6 zero-compression, zone IDs, IPv4-mapped/embedded
- Executable mode (options, exit codes)
- Sourced mode (function exports, no side effects)
- Root vs non-root behavior
- Install/update/uninstall operations
- URL configuration (seturl, showurl, unseturl)
- Template variable expansion
- Real network calls to ipecho.net

### Test Structure

```
tests/
├── helpers/
│   ├── setup.bash      # Common setup/teardown
│   └── mocks.bash      # Mock logger function
├── test_validip.bats
├── test_internetip.bats
└── test_watchip.bats
```

## Files

| File | Description |
|------|-------------|
| `internetip` | Main IP detection script |
| `validip` | IP validation module |
| `watchip` | IP monitoring daemon |
| `internetip.bash_completion` | Tab completion for `internetip` |
| `validip.bash_completion` | Tab completion for `validip` |
| `watchip.bash_completion` | Tab completion for `watchip` |
| `Makefile` | BCS1212-compliant install/uninstall/test/lint/check |
| `run_tests.sh` | Test runner script (bats wrapper with colour output) |
| `tests/` | bats-core test suite |

## License

GPL-3.0

#fin
