Platform-specific build configuration.

The `fsoverlay` folders contain the files copied over to the boot partition, there is one for each platform and [one for global files](https://github.com/knulli-cfw/knulli-linux/tree/master/board/fsoverlay). Try to keep this as small as possible, only the minimum required to boot the device, and handle the rest with [packages](https://github.com/knulli-cfw/knulli-linux/tree/master/package).
