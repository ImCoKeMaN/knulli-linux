################################################################################
#
# kernel-gammaos
#
################################################################################

KERNEL_GAMMAOS_VERSION = GammaOS
KERNEL_GAMMAOS_SITE = https://github.com/TheGammaSqueeze/5.10-linux-rockchip.git
KERNEL_GAMMAOS_SITE_METHOD = git
KERNEL_GAMMAOS_GIT_SUBMODULES = NO

KERNEL_GAMMAOS_LICENSE = GPL-2.0
KERNEL_GAMMAOS_DEPENDENCIES = host-python3 host-kmod
KERNEL_GAMMAOS_SUPPORTS_IN_SOURCE_BUILD = NO

# rk3566 is arm64
KERNEL_GAMMAOS_ARCH = arm64
KERNEL_GAMMAOS_DEFCONFIG = linux-gammaos-defconfig.config
KERNEL_GAMMAOS_DTB = rk3566-miyoo-355-v10-linux.dtb

define KERNEL_GAMMAOS_CONFIGURE_CMDS
    $(MAKE1) -C $(@D) mrproper
    # Copy our custom defconfig to the kernel build directory
    cp $(KERNEL_GAMMAOS_PKGDIR)/$(KERNEL_GAMMAOS_DEFCONFIG) $(@D)/.config
    # Run oldconfig to handle any missing/new config options
    $(MAKE1) -C $(@D) ARCH=$(KERNEL_GAMMAOS_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        oldconfig
endef

define KERNEL_GAMMAOS_BUILD_CMDS
    $(MAKE) -C $(@D) ARCH=$(KERNEL_GAMMAOS_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        Image rockchip/$(KERNEL_GAMMAOS_DTB) modules
endef

define KERNEL_GAMMAOS_INSTALL_TARGET_CMDS
    # Install kernel Image
    # Note: Using dd instead of cp to avoid sparse file corruption issues
    # when copying across Docker volume mounts (Ubuntu 24.04+ with newer coreutils)
    mkdir -p $(BINARIES_DIR)/kernel-gammaos
    dd if=$(@D)/arch/$(KERNEL_GAMMAOS_ARCH)/boot/Image \
        of=$(BINARIES_DIR)/kernel-gammaos/Image \
        bs=1M conv=fsync
    chmod 0644 $(BINARIES_DIR)/kernel-gammaos/Image
    # Install device tree
    $(INSTALL) -D -m 0644 $(@D)/arch/$(KERNEL_GAMMAOS_ARCH)/boot/dts/rockchip/$(KERNEL_GAMMAOS_DTB) \
        $(BINARIES_DIR)/kernel-gammaos/$(KERNEL_GAMMAOS_DTB)

    # Extract kernel version from Makefile variables
    kernel_version=$$(grep '^VERSION' $(@D)/Makefile | head -1 | cut -d' ' -f3).$$(grep '^PATCHLEVEL' $(@D)/Makefile | head -1 | cut -d' ' -f3).$$(grep '^SUBLEVEL' $(@D)/Makefile | head -1 | cut -d' ' -f3); \
    echo "Installing modules for kernel version: $$kernel_version"; \
    $(MAKE) -C $(@D) ARCH=$(KERNEL_GAMMAOS_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
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