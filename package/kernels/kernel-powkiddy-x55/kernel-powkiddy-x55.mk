################################################################################
#
# kernel-powkiddy-x55
#
################################################################################

KERNEL_POWKIDDY_X55_VERSION = 9e8f3703fe49d5d12bbb951e233248f5f3eb9efd
KERNEL_POWKIDDY_X55_SITE = https://github.com/RetroGFX/rk3566-x55-kernel.git
KERNEL_POWKIDDY_X55_SITE_METHOD = git
KERNEL_POWKIDDY_X55_GIT_SUBMODULES = NO

KERNEL_POWKIDDY_X55_LICENSE = GPL-2.0
KERNEL_POWKIDDY_X55_DEPENDENCIES = host-python3
KERNEL_POWKIDDY_X55_SUPPORTS_IN_SOURCE_BUILD = NO

# rk3566 is arm64
KERNEL_POWKIDDY_X55_ARCH = arm64
KERNEL_POWKIDDY_X55_DEFCONFIG = rockchip_linux_defconfig
KERNEL_POWKIDDY_X55_DTB = rk3566-evb2-lp4x-v10-linux.dtb

define KERNEL_POWKIDDY_X55_CONFIGURE_CMDS
    $(MAKE1) -C $(@D) mrproper
    $(MAKE1) -C $(@D) ARCH=$(KERNEL_POWKIDDY_X55_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        $(KERNEL_POWKIDDY_X55_DEFCONFIG)
endef

define KERNEL_POWKIDDY_X55_BUILD_CMDS
    $(MAKE) -C $(@D) ARCH=$(KERNEL_POWKIDDY_X55_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        $(if $(BR2_LINUX_KERNEL_NEEDS_MODULES),modules) \
        Image rockchip/$(KERNEL_POWKIDDY_X55_DTB)
endef

define KERNEL_POWKIDDY_X55_INSTALL_TARGET_CMDS
    # Install kernel Image
    mkdir -p $(BINARIES_DIR)/kernel-powkiddy-x55
    $(INSTALL) -D -m 0644 $(@D)/arch/$(KERNEL_POWKIDDY_X55_ARCH)/boot/Image \
        $(BINARIES_DIR)/kernel-powkiddy-x55/Image
    # Install device tree
    $(INSTALL) -D -m 0644 $(@D)/arch/$(KERNEL_POWKIDDY_X55_ARCH)/boot/dts/rockchip/$(KERNEL_POWKIDDY_X55_DTB) \
        $(BINARIES_DIR)/kernel-powkiddy-x55/$(KERNEL_POWKIDDY_X55_DTB)
endef

$(eval $(generic-package))