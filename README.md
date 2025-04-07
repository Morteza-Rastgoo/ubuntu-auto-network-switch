# Ubuntu Auto Network Switch

A bash script that automatically manages and switches between USB and Ethernet network interfaces to maintain internet connectivity. The script monitors both interfaces and automatically switches to the working one when connectivity issues are detected.

## Features

- Automatic switching between USB (usb0) and Ethernet (eth0) interfaces
- Continuous monitoring of network connectivity
- Automatic gateway configuration
- Detailed logging of all network switching events
- Configurable ping target and check interval

## Prerequisites

- Ubuntu/Linux system
- Root privileges (for network interface management)
- Required tools: `ip`, `dhclient`, `ping`

## Installation

1. Clone or download this repository:
   ```bash
   git clone https://github.com/yourusername/ubuntu-auto-network-switch.git
   cd ubuntu-auto-network-switch
   ```

2. Make the script executable:
   ```bash
   chmod +x ubuntu-auto-network-switch.sh
   ```

## Configuration

Edit the script to customize these variables at the beginning:

```bash
USB_IF="usb0"      # USB network interface name
ETH_IF="eth0"      # Ethernet interface name
PING_TARGET="8.8.8.8"  # IP address to ping for connectivity check
INTERVAL=10         # Check interval in seconds
LOGFILE="/var/log/net-switcher.log"  # Log file location
```

## Usage

Run the script with root privileges:

```bash
sudo ./ubuntu-auto-network-switch.sh
```

The script will:
1. Monitor both network interfaces continuously
2. Switch to USB interface if it has internet connectivity
3. Switch to Ethernet interface if USB is down and Ethernet has connectivity
4. Keep both interfaces up if neither has connectivity
5. Log all events to the specified log file

## Logging

All network switching events are logged to `/var/log/net-switcher.log` with timestamps. You can monitor the log in real-time using:

```bash
tail -f /var/log/net-switcher.log
```

## Troubleshooting

1. If the script fails to switch interfaces:
   - Verify interface names match your system
   - Ensure you have root privileges
   - Check the log file for error messages

2. If connectivity checks fail:
   - Verify the PING_TARGET is accessible
   - Check physical network connections
   - Verify network interface configurations

## License

This project is open source and available under the MIT License.