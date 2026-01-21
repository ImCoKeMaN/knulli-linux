#!/bin/sh

# Restart idlewatcher daemon
/etc/init.d/S96idlewatcher-daemon restart

if [ -f /etc/init.d/S06fan-control-daemon ]; then
    # Restart fan daemon
    /etc/init.d/S06fan-control-daemon restart
fi

exit 0
