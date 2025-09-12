#!/bin/bash

# HOST_DIR = host dir
# BOARD_DIR = board specific dir
# BUILD_DIR = base dir/build
# BINARIES_DIR = images dir
# TARGET_DIR = target dir
# KNULLI_BINARIES_DIR = knulli binaries sub directory

HOST_DIR=$1
BOARD_DIR=$2
BUILD_DIR=$3
BINARIES_DIR=$4
TARGET_DIR=$5
KNULLI_BINARIES_DIR=$6

mkdir -p "${KNULLI_BINARIES_DIR}/boot/boot"     || exit 1

cp "${BOARD_DIR}/uImage"             	"${KNULLI_BINARIES_DIR}/boot/uImage"               || exit 1
cp "${BOARD_DIR}/ramdisk.img"           "${KNULLI_BINARIES_DIR}/boot/ramdisk.img"          || exit 1
cp "${BOARD_DIR}/kernel.dtb" 		"${KNULLI_BINARIES_DIR}/boot/kernel.dtb"           || exit 1
cp "${BOARD_DIR}/2600mAh-gpu.dtb"    	"${KNULLI_BINARIES_DIR}/boot/2600mAh-gpu.dtb"      || exit 1
cp "${BOARD_DIR}/2100mAh-gpu.dtb"    	"${KNULLI_BINARIES_DIR}/boot/2100mAh-gpu.dtb"      || exit 1
cp "${BINARIES_DIR}/rootfs.ext2"        "${KNULLI_BINARIES_DIR}/boot/boot/knulli.update" || exit 1
cp "${BINARIES_DIR}/knulli-boot.conf" "${KNULLI_BINARIES_DIR}/boot/knulli-boot.conf"   || exit 1

cp "${BOARD_DIR}/boot_logo.bmp.gz"      "${KNULLI_BINARIES_DIR}/boot/boot_logo.bmp.gz"     || exit 1
cp "${BOARD_DIR}/uEnv.txt"              "${KNULLI_BINARIES_DIR}/boot/uEnv.txt"             || exit 1
cp "${BOARD_DIR}/bootloader.img"        "${KNULLI_BINARIES_DIR}/bootloader.img"            || exit 1
cp "${BOARD_DIR}/u-boot-dtb.img"        "${KNULLI_BINARIES_DIR}/u-boot-dtb.img"            || exit 1

touch "${KNULLI_BINARIES_DIR}/boot/boot/reboot"
touch "${KNULLI_BINARIES_DIR}/boot/boot/autoresize"

# Create empty swap partition
truncate -s 512M "${KNULLI_BINARIES_DIR}/swap.img"
chmod 0600 "${KNULLI_BINARIES_DIR}/swap.img"
mkswap "${KNULLI_BINARIES_DIR}/swap.img"

exit 0
