#!/bin/sh

BATTERY_STATE="$(/usr/bin/knulli-battery-check status)"

[ -n "$BATTERY_STATE" ] || exit 0

/usr/bin/batteryplus-state "$BATTERY_STATE" -f

exit 0
