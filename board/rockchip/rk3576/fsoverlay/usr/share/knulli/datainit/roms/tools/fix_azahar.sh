#!/bin/bash

cd /userdata/system


/etc/init.d/S31emulationstation stop

test_rom=$(ls /userdata/roms/3ds/* | head -n 1)
azahar $test_rom &

sleep 4

killall -9 azahar

/etc/init.d/S31emulationstation start
