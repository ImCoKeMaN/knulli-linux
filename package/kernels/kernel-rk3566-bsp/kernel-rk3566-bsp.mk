################################################################################
#
# kernel-powkiddy-x55
#
################################################################################

KERNEL_RK3566_BSP_VERSION = 3e709e40909016fdf4394d56544ab86a3bd5603d
KERNEL_RK3566_BSP_SITE = https://github.com/RetroGFX/rk356x-kernel.git
KERNEL_RK3566_BSP_SITE_METHOD = git
KERNEL_RK3566_BSP_GIT_SUBMODULES = NO

KERNEL_RK3566_BSP_LICENSE = GPL-2.0
KERNEL_RK3566_BSP_DEPENDENCIES = host-python3 host-kmod extra-firmwares
KERNEL_RK3566_BSP_SUPPORTS_IN_SOURCE_BUILD = NO

# rk3566 is arm64
KERNEL_RK3566_BSP_ARCH = arm64
KERNEL_RK3566_BSP_DEFCONFIG = linux-rk3566-defconfig.config
KERNEL_RK3566_BSP_TARGET_DIR = kernel-rk3566-bsp

KERNEL_RK3566_BSP_DTBS = \
    rk3566-rg353m-linux.dtb \
    rk3566-rg353p-linux.dtb \
    rk3566-rg353v-linux.dtb \
    rk3566-rg503-linux.dtb \
    rk3566-rg-arc-linux.dtb \
    rk3566-rgb20pro-linux.dtb \
    rk3566-rgb30-linux.dtb \
    rk3566-rgb30-v2-linux.dtb \
    rk3566-rk2023-linux.dtb \
    rk3566-max3pro-linux.dtb

define KERNEL_RK3566_BSP_CONFIGURE_CMDS
    $(MAKE1) -C $(@D) mrproper
    # Copy our custom defconfig to the kernel build directory
    cp $(KERNEL_RK3566_BSP_PKGDIR)/$(KERNEL_RK3566_BSP_DEFCONFIG) $(@D)/.config
    # Run oldconfig to handle any missing/new config options
    $(MAKE1) -C $(@D) ARCH=$(KERNEL_RK3566_BSP_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        oldconfig
endef

define KERNEL_RK3566_BSP_BUILD_CMDS
    $(MAKE) -C $(@D) ARCH=$(KERNEL_RK3566_BSP_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        Image $(addprefix rockchip/,$(KERNEL_RK3566_BSP_DTBS)) modules
endef

define KERNEL_RK3566_BSP_INSTALL_TARGET_CMDS
    # Install kernel Image
    # Note: Using dd instead of cp to avoid sparse file corruption issues
    # when copying across Docker volume mounts (Ubuntu 24.04+ with newer coreutils)
    mkdir -p $(BINARIES_DIR)/$(KERNEL_RK3566_BSP_TARGET_DIR)
    dd if=$(@D)/arch/$(KERNEL_RK3566_BSP_ARCH)/boot/Image \
        of=$(BINARIES_DIR)/$(KERNEL_RK3566_BSP_TARGET_DIR)/Image \
        bs=1M conv=fsync
    chmod 0644 $(BINARIES_DIR)/$(KERNEL_RK3566_BSP_TARGET_DIR)/Image
    # Install all specified device trees
    $(foreach dtb,$(KERNEL_RK3566_BSP_DTBS), \
        $(INSTALL) -D -m 0644 $(@D)/arch/$(KERNEL_RK3566_BSP_ARCH)/boot/dts/rockchip/$(dtb) \
            $(BINARIES_DIR)/$(KERNEL_RK3566_BSP_TARGET_DIR)/$(dtb);)

    # Extract kernel version from Makefile variables
    kernel_version=$$(grep '^VERSION' $(@D)/Makefile | head -1 | cut -d' ' -f3).$$(grep '^PATCHLEVEL' $(@D)/Makefile | head -1 | cut -d' ' -f3).$$(grep '^SUBLEVEL' $(@D)/Makefile | head -1 | cut -d' ' -f3); \
    echo "Installing modules for kernel version: $$kernel_version"; \
    $(MAKE) -C $(@D) ARCH=$(KERNEL_RK3566_BSP_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
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
