################################################################################
#
# uboot-rk3566
#
################################################################################

UBOOT_RK3566_VERSION = 5f70fda83e894a101dbb5cf612df0b79949464be
UBOOT_RK3566_SITE = https://github.com/JustEnoughLinuxOS/rk3566-x55-uboot.git
UBOOT_RK3566_SITE_METHOD = git
UBOOT_RK3566_LICENSE = GPL-2.0+
UBOOT_RK3566_DEPENDENICES = rockchip-rkbin

UBOOT_RK3566_CONFIG = rk3566_x55_defconfig

# Set up the build options.
# - ARCH is set to 'arm' for the RK3566 SoC.
# - CROSS_COMPILE is provided by Buildroot as $(TARGET_CROSS).
#UBOOT_RK3566_MAKE_OPTS += ARCH=arm CROSS_COMPILE=$(TARGET_CROSS)

#UBOOT_RK3566_TARGET = all
#UBOOT_RK3566_BUILD_CMDS = $(MAKE) $(UBOOT_MAKE_OPTS) $(UBOOT_TARGET)

# Installation: copy the built U-Boot images into the target’s boot directory.
# Adjust the filenames below if your build produces differently named binaries.
#define UBOOT_RK3566_INSTALL_CMDS
#	$(INSTALL) -d $(TARGET_DIR)/boot
#	$(INSTALL) -m 0644 $(PKG_BUILD_DIR)/u-boot-spl.bin $(TARGET_DIR)/boot/
#	$(INSTALL) -m 0644 $(PKG_BUILD_DIR)/u-boot.itb $(TARGET_DIR)/boot/
#endef

define UBOOT_RK3566_BUILD_CMDS
        cd $(@D) && $(@D)/make.sh rk3566
endef

define UBOOT_RK3566_INSTALL_TARGET_CMDS
	cp $(@D)/sd_fuse/idbloader.img $(BINARIES_DIR)/idbloader.img
	cp $(@D)/sd_fuse/uboot.img     $(BINARIES_DIR)/uboot.img
	cp $(@D)/sd_fuse/trust.img     $(BINARIES_DIR)/trust.img
endef

$(eval $(generic-package))
