#!/bin/bash

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
}

# Create systemd service file
cat > /etc/systemd/system/net-switcher.service << 'EOL'
[Unit]
Description=Network Auto-Switcher
After=network.target

[Service]
ExecStart=/usr/local/bin/net-switcher.sh
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Copy the script to /usr/local/bin
cp ubuntu-auto-network-switch.sh /usr/local/bin/net-switcher.sh
chmod +x /usr/local/bin/net-switcher.sh

# Reload systemd daemon and enable service
systemctl daemon-reload
systemctl enable net-switcher.service
systemctl start net-switcher.service

echo "Service installed and started successfully!"