#!/bin/bash

# تنظیمات
USB_IF="usb0"
ETH_IF="eth0"
PING_TARGET="8.8.8.8"
INTERVAL=10
LOGFILE="/var/log/net-switcher.log"
LAST_ACTIVE=""

# تابع لاگ‌نویسی
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOGFILE"
}

# بررسی اتصال اینترنت از طریق یک رابط مشخص
check_internet() {
    local IF=$1
    ip link show "$IF" 2>/dev/null | grep -q "state UP" || return 1
    ping -I "$IF" -c 2 -W 2 "$PING_TARGET" > /dev/null 2>&1
    return $?
}

# تغییر دیفالت روت و فعال/غیرفعال‌سازی رابط‌ها
switch_to_interface() {
    local NEW_IF=$1
    local OLD_IF=$2

    if [[ "$LAST_ACTIVE" == "$NEW_IF" ]]; then
        return 0
    fi

    log "Switching to $NEW_IF, disabling $OLD_IF"

    # فعال‌سازی رابط جدید
    ip link set "$NEW_IF" up
    dhclient "$NEW_IF" -v 2>/dev/null

    # غیرفعال‌سازی رابط قبلی (در صورتی که موجود باشه)
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

# حلقه اصلی
while true; do
    if check_internet "$USB_IF"; then
        switch_to_interface "$USB_IF" "$ETH_IF"
    elif check_internet "$ETH_IF"; then
        switch_to_interface "$ETH_IF" "$USB_IF"
    else
        log "❌ No internet on either interface"
        # هر دو رابط رو بالا نگه داریم تا شاید یکی وصل شه
        ip link set "$USB_IF" up 2>/dev/null
        ip link set "$ETH_IF" up 2>/dev/null
        dhclient "$USB_IF" -v 2>/dev/null
        dhclient "$ETH_IF" -v 2>/dev/null
        LAST_ACTIVE=""
    fi

    sleep "$INTERVAL"
done
