#!/bin/bash

source /etc/profile.d/xdg.sh

/etc/init.d/S31emulationstation stop

export QT_QPA_PLATFORM=wayland
export QT_QPA_PLATFORM_PLUGINS_PATH=/usr/lib/qt6/plugins/platforms/

test_rom=$(ls /userdata/roms/ps2/* | head -n 1)

/usr/share/aethersx2/aethersx2 $test_rom &

sleep 4

killall -9 aethersx2

/etc/init.d/S31emulationstation start
