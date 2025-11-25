#!/bin/sh

POWER_LED_BIN="/usr/bin/knulli-power-led"

[ -f "$POWER_LED_BIN" ] || exit 0

led="$(/usr/bin/knulli-settings-get system.power.led 2>/dev/null)"

case "$led" in
    0)
        "$POWER_LED_BIN" power off
        ;;
    1)
        "$POWER_LED_BIN" power on
        ;;
    *)
        exit 0
        ;;
esac

exit 0
