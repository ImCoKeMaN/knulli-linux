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
KERNEL_RK3566_BSP_DEPENDENCIES = host-python3
KERNEL_RK3566_BSP_SUPPORTS_IN_SOURCE_BUILD = NO

# rk3566 is arm64
KERNEL_RK3566_BSP_ARCH = arm64
KERNEL_RK3566_BSP_DEFCONFIG = rk3566_linux_defconfig
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
    $(MAKE1) -C $(@D) ARCH=$(KERNEL_RK3566_BSP_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        $(KERNEL_RK3566_BSP_DEFCONFIG)
endef

define KERNEL_RK3566_BSP_BUILD_CMDS
    $(MAKE) -C $(@D) ARCH=$(KERNEL_RK3566_BSP_ARCH) CROSS_COMPILE=$(TARGET_CROSS) \
        $(if $(BR2_LINUX_KERNEL_NEEDS_MODULES),modules) \
        Image $(addprefix rockchip/,$(KERNEL_RK3566_BSP_DTBS))
endef

define KERNEL_RK3566_BSP_INSTALL_TARGET_CMDS
    # Install kernel Image
    mkdir -p $(BINARIES_DIR)/$(KERNEL_RK3566_BSP_TARGET_DIR)
    $(INSTALL) -D -m 0644 $(@D)/arch/$(KERNEL_RK3566_BSP_ARCH)/boot/Image \
        $(BINARIES_DIR)/$(KERNEL_RK3566_BSP_TARGET_DIR)/Image
    # Install all specified device trees
    $(foreach dtb,$(KERNEL_RK3566_BSP_DTBS), \
        $(INSTALL) -D -m 0644 $(@D)/arch/$(KERNEL_RK3566_BSP_ARCH)/boot/dts/rockchip/$(dtb) \
            $(BINARIES_DIR)/$(KERNEL_RK3566_BSP_TARGET_DIR)/$(dtb);)
endef

$(eval $(generic-package))