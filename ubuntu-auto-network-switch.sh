#!/bin/bash

# Configuration
# Set default interface (usb0 or eth0). If not set, defaults to USB
DEFAULT_IF=${DEFAULT_IF:-"$USB_IF"}
USB_IF="usb0"
ETH_IF="eth0"
PING_TARGET="8.8.8.8"
INTERVAL=10
LOGFILE="/var/log/net-switcher.log"
LAST_ACTIVE=""

# Validate and set primary/secondary interfaces
if [ "$DEFAULT_IF" = "$ETH_IF" ]; then
    PRIMARY_IF="$ETH_IF"
    SECONDARY_IF="$USB_IF"
else
    PRIMARY_IF="$USB_IF"
    SECONDARY_IF="$ETH_IF"
fi

# Logging function
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}

# Check internet connectivity through a specific interface
check_internet() {
    local IF=$1
    ip link show "$IF" 2>/dev/null | grep -q "state UP" || return 1
    ping -I "$IF" -c 2 -W 2 "$PING_TARGET" > /dev/null 2>&1
    return $?
}

# Switch default route and enable/disable interfaces
switch_to_interface() {
    local NEW_IF=$1
    local OLD_IF=$2

    if [[ "$LAST_ACTIVE" == "$NEW_IF" ]]; then
        return 0
    fi

    log "Switching to $NEW_IF, disabling $OLD_IF"

    # Enable new interface
    ip link set "$NEW_IF" up
    dhclient "$NEW_IF" -v 2>/dev/null

    # Disable old interface (if exists)
    if [[ -n "$OLD_IF" ]]; then
        ip link set "$OLD_IF" down 2>/dev/null
    fi

    # تنظیم روت دیفالت از طریق رابط جدید
    ip route del default 2>/dev/null
    GATEWAY=$(ip route show dev "$NEW_IF" | grep default | awk '{print $3}')
    if [[ -n "$GATEWAY" ]]; then
        ip route add default via "$GATEWAY" dev "$NEW_IF"
        log "Default route set via $NEW_IF ($GATEWAY)"
    else
        log "⚠️ Couldn't find gateway for $NEW_IF"
    fi

    LAST_ACTIVE="$NEW_IF"
}

# Main loop
while true; do
    if check_internet "$PRIMARY_IF"; then
        switch_to_interface "$PRIMARY_IF" "$SECONDARY_IF"
    elif check_internet "$SECONDARY_IF"; then
        switch_to_interface "$SECONDARY_IF" "$PRIMARY_IF"
    else
        log "❌ No internet on either interface"
        # Keep both interfaces up to catch connectivity
        ip link set "$PRIMARY_IF" up 2>/dev/null
        ip link set "$SECONDARY_IF" up 2>/dev/null
        dhclient "$PRIMARY_IF" -v 2>/dev/null
        dhclient "$SECONDARY_IF" -v 2>/dev/null
        LAST_ACTIVE=""
    fi

    sleep "$INTERVAL"
done
