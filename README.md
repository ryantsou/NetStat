# NetStat

Bash scripts for network statistics monitoring and analysis.

## Description

NetStat is a collection of Bash scripts designed to help you monitor and analyze network statistics on Linux systems. This tool provides real-time information about network interfaces, packet statistics, bandwidth usage, and connection states.

## Author

Riantsoa RAJHONSON

## Requirements

- Linux operating system (Ubuntu, Debian, CentOS, RHEL, etc.)
- Bash shell (version 4.0 or higher)
- Root or sudo privileges for certain network operations
- Basic network utilities:
  - `ifconfig` or `ip` command
  - `netstat` or `ss` command
  - `awk`, `sed`, `grep`

## Installation

1. Clone this repository:
   ```bash
   git clone https://github.com/ryantsou/NetStat.git
   cd NetStat
   ```

2. Make the script executable:
   ```bash
   chmod +x network-stats.sh
   ```

3. (Optional) Move to system PATH:
   ```bash
   sudo cp network-stats.sh /usr/local/bin/network-stats
   ```

## Usage

Basic usage:
```bash
./network-stats.sh [OPTIONS]
```

With sudo privileges (recommended for full functionality):
```bash
sudo ./network-stats.sh [OPTIONS]
```

## Options

- `-i, --interface <name>` : Specify network interface (e.g., eth0, wlan0)
- `-s, --stats` : Display detailed packet statistics
- `-c, --connections` : Show active network connections
- `-b, --bandwidth` : Monitor bandwidth usage
- `-a, --all` : Display all available information
- `-h, --help` : Show help message
- `-v, --version` : Display version information

## Examples

### Display statistics for a specific interface:
```bash
./network-stats.sh -i eth0
```

### Show all network connections:
```bash
sudo ./network-stats.sh --connections
```

### Monitor bandwidth usage:
```bash
./network-stats.sh --bandwidth
```

### Display all available information:
```bash
sudo ./network-stats.sh --all
```

### Get help:
```bash
./network-stats.sh --help
```

## Features

- Real-time network interface monitoring
- Packet statistics (sent/received, errors, drops)
- Active connection tracking
- Bandwidth usage analysis
- Support for multiple network interfaces
- Easy-to-read formatted output

## Troubleshooting

- **Permission denied**: Run the script with sudo privileges
- **Command not found**: Ensure required utilities are installed
- **Interface not found**: Check available interfaces with `ip link show` or `ifconfig -a`

## License

No license specified.

## Contributing

Feel free to submit issues, fork the repository, and create pull requests for any improvements.

---

**Author**: Riantsoa RAJHONSON
