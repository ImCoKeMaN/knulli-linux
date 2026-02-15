#!/bin/bash

# Check if Syncthing service is enabled, abort if not.
ENABLED_SERVICES="$(/usr/bin/knulli-settings-get system.services)"
if [[ ${ENABLED_SERVICES} != *"syncthing"* ]];then
  echo "Syncthing not running. Aborting."
  exit 0
fi

# Check if auto-scan is enabled.
SYNCTHING_AUTOSCAN="$(/usr/bin/knulli-settings-get syncthing.autoscan)"
if [[ ${SYNCTHING_AUTOSCAN} != *"1"* ]];then
  echo "Syncthing auto-scan disabled. Aborting."
  exit 0
fi

# Launch syncthing scan script in background
knulli-syncthing-scan & disown

exit 0
