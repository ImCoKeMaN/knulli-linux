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
KERNEL_POWKIDDY_X55_DEPENDENCIES = host-python3 host-kmod extra-firmwares
KERNEL_POWKIDDY_X55_SUPPORTS_IN_SOURCE_BUILD = NO

# rk3566 is arm64
KERNEL_POWKIDDY_X55_ARCH = arm64
KERNEL_POWKIDDY_X55_DEFCONFIG = linux-x55-defconfig.config
KERNEL_POWKIDDY_X55_DTB = rk3566-evb2-lp4x-v10-linux.dtb

define KERNEL_POWKIDDY_X55_CONFIGURE_CMDS
    $(MAKE1) -C $(@D) mrproper
    # Copy our custom defconfig to the kernel build directory
    cp $(KERNEL_POWKIDDY_X55_PKGDIR)/$(KERNEL_POWKIDDY_X55_DEFCONFIG) $(@D)/.config
    # Run oldconfig to handle any missing/new config options
    $(MAKE1) -C $(@D) ARCH=$(KERNEL_POWKIDDY_X55_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        oldconfig
endef

define KERNEL_POWKIDDY_X55_BUILD_CMDS
    $(MAKE) -C $(@D) ARCH=$(KERNEL_POWKIDDY_X55_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        Image rockchip/$(KERNEL_POWKIDDY_X55_DTB) modules
endef

define KERNEL_POWKIDDY_X55_INSTALL_TARGET_CMDS
    # Install kernel Image
    # Note: Using dd instead of cp to avoid sparse file corruption issues
    # when copying across Docker volume mounts (Ubuntu 24.04+ with newer coreutils)
    mkdir -p $(BINARIES_DIR)/kernel-powkiddy-x55
    dd if=$(@D)/arch/$(KERNEL_POWKIDDY_X55_ARCH)/boot/Image \
        of=$(BINARIES_DIR)/kernel-powkiddy-x55/Image \
        bs=1M conv=fsync
    chmod 0644 $(BINARIES_DIR)/kernel-powkiddy-x55/Image
    # Install device tree
    $(INSTALL) -D -m 0644 $(@D)/arch/$(KERNEL_POWKIDDY_X55_ARCH)/boot/dts/rockchip/$(KERNEL_POWKIDDY_X55_DTB) \
        $(BINARIES_DIR)/kernel-powkiddy-x55/$(KERNEL_POWKIDDY_X55_DTB)
   
    # Extract kernel version from Makefile variables
    kernel_version=$$(grep '^VERSION' $(@D)/Makefile | head -1 | cut -d' ' -f3).$$(grep '^PATCHLEVEL' $(@D)/Makefile | head -1 | cut -d' ' -f3).$$(grep '^SUBLEVEL' $(@D)/Makefile | head -1 | cut -d' ' -f3); \
    echo "Installing modules for kernel version: $$kernel_version"; \
    $(MAKE) -C $(@D) ARCH=$(KERNEL_POWKIDDY_X55_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        INSTALL_MOD_PATH=$(TARGET_DIR) \
        INSTALL_MOD_STRIP=1 \
        DEPMOD=/bin/true \
        modules_install; \
    rm -f $(TARGET_DIR)/lib/modules/$$kernel_version/build; \
    rm -f $(TARGET_DIR)/lib/modules/$$kernel_version/source; \
    if [ -f $(@D)/System.map ]; then \
        $(HOST_DIR)/sbin/depmod -ae -F $(@D)/System.map \
            -b $(TARGET_DIR) $$kernel_version; \
    else \
        echo "Warning: System.map not found, running depmod without it"; \
        $(HOST_DIR)/sbin/depmod -ae -b $(TARGET_DIR) $$kernel_version; \
    fi
endef

$(eval $(generic-package))
