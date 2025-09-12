#!/bin/sh

ROTATE=$1

if [[ ${ROTATE} == "1" ]]; then
	knulli-settings-set display.rotate 0
        knulli-settings-set global.retroarch.aspect_ratio_index 8
        curl http://localhost:1234/quit
else
	knulli-settings-set display.rotate 1
        knulli-settings-set global.retroarch.aspect_ratio_index 0
        curl http://localhost:1234/quit
fi

