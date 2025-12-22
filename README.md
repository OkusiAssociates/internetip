# internetip

A Bash utility toolkit for detecting, validating, and monitoring public IP addresses.

## Scripts

| Script | Purpose |
|--------|---------|
| `internetip` | Fetch and display public IP address |
| `validip` | Validate IPv4 address format |
| `watchip` | Monitor for IP changes, log via syslog |

All scripts follow the [BASH-CODING-STANDARD](https://github.com/Open-Technology-Foundation/bash-coding-standard) and support dual-purpose usage (executable or sourceable as a module).

## Installation

```bash
# Symlink to /usr/local/bin
sudo ln -s "$(pwd)/internetip" /usr/local/bin/
sudo ln -s "$(pwd)/validip" /usr/local/bin/
sudo ln -s "$(pwd)/watchip" /usr/local/bin/

# Enable bash completion
echo "source $(pwd)/internetip.bash_completion" >> ~/.bashrc
```

## Usage

### internetip

```bash
internetip              # Display current public IP
internetip -s           # Store IP to remote ips.okusi server
internetip -V           # Show version
internetip -h           # Show help
```

When run as root, caches result to `/tmp/GatewayIP`.

### validip

```bash
validip 192.168.1.1 && echo valid || echo invalid
validip 999.1.1.1 && echo valid || echo invalid
```

### watchip

```bash
sudo watchip            # Check for IP change
sudo watchip -q         # Quiet mode (for cron)
```

Logs IP changes to syslog (`local0.notice`). Typical cron entry:

```cron
*/5 * * * * /usr/local/bin/watchip -q
```

## Module Usage

All scripts can be sourced to use their functions directly:

```bash
source internetip
ip=$(get_internet_ip)
echo "Current IP: $ip"

source validip
if valid_ip "$ip"; then
    echo "Valid"
fi

source watchip
result=$(watch_ip /tmp/myapp_ip.txt)
# Returns: "changed:oldip:newip" or "unchanged:ip"
```

## Dependencies

- `wget` - HTTP requests
- `logger` - Syslog integration (watchip)
- `timeout` - Request timeouts
- Bash 4.0+

## Files

| File | Description |
|------|-------------|
| `internetip` | Main IP detection script |
| `validip` | IP validation module |
| `watchip` | IP monitoring daemon |
| `internetip.bash_completion` | Tab completion support |

## License

MIT

#fin
