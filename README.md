# Ubuntu Auto Network Switch

A bash script that prioritizes USB network connectivity while providing automatic failover to Ethernet. The script maintains a constant connection by prioritizing the USB interface (usb0) and only switches to Ethernet (eth0) when USB connectivity fails. When USB connectivity is restored, it automatically switches back to USB and disables the Ethernet interface.

## Features

- Prioritized USB (usb0) network interface connection
- Automatic failover to Ethernet (eth0) when USB connectivity fails
- Automatic switching back to USB when connectivity is restored
- Ethernet interface management (enabling/disabling as needed)
- Continuous connectivity monitoring
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

2. Make the scripts executable:
   ```bash
   chmod +x ubuntu-auto-network-switch.sh install-service.sh
   ```

3. Install as a systemd service (Optional):
   ```bash
   sudo ./install-service.sh
   ```
   This will:
   - Create a systemd service file at `/etc/systemd/system/net-switcher.service`
   - Copy the script to `/usr/local/bin/net-switcher.sh`
   - Enable and start the service automatically at boot

   You can manage the service using standard systemd commands:
   ```bash
   sudo systemctl status net-switcher    # Check service status
   sudo systemctl stop net-switcher     # Stop the service
   sudo systemctl start net-switcher    # Start the service
   sudo systemctl restart net-switcher  # Restart the service
   sudo systemctl disable net-switcher  # Disable autostart at boot
   ```

## Configuration

Edit the script to customize these variables at the beginning:

```bash
DEFAULT_IF=""       # Default interface to prioritize (usb0 or eth0, defaults to USB if not set)
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
1. Prioritize and maintain the default interface connection (USB if not specified)
2. Continuously monitor the primary interface connectivity
3. Automatically switch to the secondary interface when primary connectivity fails
4. Switch back to primary and disable secondary when primary connectivity is restored
5. Keep monitoring if neither interface has connectivity
6. Log all network switching events to the specified log file

You can set the default interface when running the script:

```bash
# Use USB as default (default behavior)
sudo ./ubuntu-auto-network-switch.sh

# Or explicitly set USB as default
DEFAULT_IF=usb0 sudo ./ubuntu-auto-network-switch.sh

# Use Ethernet as default
DEFAULT_IF=eth0 sudo ./ubuntu-auto-network-switch.sh
```

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