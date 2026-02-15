################################################################################
#
# kernel-rg-ds
#
################################################################################

KERNEL_RG_DS_VERSION = 1629d4d841456f20b8b4736e9815d4539b0dd0ae
KERNEL_RG_DS_SITE = https://github.com/unifreq/linux-6.1.y-rockchip.git
KERNEL_RG_DS_SITE_METHOD = git
KERNEL_RG_DS_GIT_SUBMODULES = NO

KERNEL_RG_DS_LICENSE = GPL-2.0
KERNEL_RG_DS_DEPENDENCIES = host-python3 host-kmod extra-firmwares
KERNEL_RG_DS_SUPPORTS_IN_SOURCE_BUILD = NO

# rk3566 is arm64
KERNEL_RG_DS_ARCH = arm64
KERNEL_RG_DS_DEFCONFIG = linux-rk3566-defconfig.config
KERNEL_RG_DS_TARGET_DIR = kernel-rg-ds

KERNEL_RG_DS_DTBS = rk3568-evb1-ddr4-v10-linux.dtb

define KERNEL_RG_DS_CONFIGURE_CMDS
    $(MAKE1) -C $(@D) mrproper
    # Copy our custom defconfig to the kernel build directory
    cp $(KERNEL_RG_DS_PKGDIR)/$(KERNEL_RG_DS_DEFCONFIG) $(@D)/.config
    # Run oldconfig to handle any missing/new config options
    $(MAKE1) -C $(@D) ARCH=$(KERNEL_RG_DS_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        oldconfig
endef

define KERNEL_RG_DS_BUILD_CMDS
    $(MAKE) -C $(@D) ARCH=$(KERNEL_RG_DS_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        Image $(addprefix rockchip/,$(KERNEL_RG_DS_DTBS)) modules
endef

define KERNEL_RG_DS_INSTALL_TARGET_CMDS
    # Install kernel Image
    # Note: Using dd instead of cp to avoid sparse file corruption issues
    # when copying across Docker volume mounts (Ubuntu 24.04+ with newer coreutils)
    mkdir -p $(BINARIES_DIR)/$(KERNEL_RG_DS_TARGET_DIR)
    dd if=$(@D)/arch/$(KERNEL_RG_DS_ARCH)/boot/Image \
        of=$(BINARIES_DIR)/$(KERNEL_RG_DS_TARGET_DIR)/Image \
        bs=1M conv=fsync
    chmod 0644 $(BINARIES_DIR)/$(KERNEL_RG_DS_TARGET_DIR)/Image
    # Install all specified device trees
    $(foreach dtb,$(KERNEL_RG_DS_DTBS), \
        $(INSTALL) -D -m 0644 $(@D)/arch/$(KERNEL_RG_DS_ARCH)/boot/dts/rockchip/$(dtb) \
            $(BINARIES_DIR)/$(KERNEL_RG_DS_TARGET_DIR)/$(dtb);)

    # Extract kernel version from Makefile variables
    kernel_version=$$(grep '^VERSION' $(@D)/Makefile | head -1 | cut -d' ' -f3).$$(grep '^PATCHLEVEL' $(@D)/Makefile | head -1 | cut -d' ' -f3).$$(grep '^SUBLEVEL' $(@D)/Makefile | head -1 | cut -d' ' -f3); \
    echo "Installing modules for kernel version: $$kernel_version"; \
    $(MAKE) -C $(@D) ARCH=$(KERNEL_RG_DS_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
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
