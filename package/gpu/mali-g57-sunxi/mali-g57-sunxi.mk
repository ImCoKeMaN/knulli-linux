################################################################################
#
# MALI G57 SUNXI GPU driver
#
################################################################################
# Version.: Commits on Dec 8, 2025
MALI_G57_SUNXI_VERSION = main
MALI_G57_SUNXI_SITE = https://github.com/knulli-cfw/mali-g57-sunxis.git
MALI_G57_SUNXI_SITE_METHOD = git

MALI_G57_SUNXI_LICENSE = Propietary

MALI_G57_SUNXI_INSTALL_STAGING = YES
MALI_G57_SUNXI_PROVIDES = libegl libgles libopencl libmali

define MALI_G57_SUNXI_INSTALL_STAGING_CMDS
        mkdir -p $(STAGING_DIR)/usr/lib/pkgconfig

        cp -rf $(@D)/include/* $(STAGING_DIR)/usr/include/

        cp -rf $(@D)/fbdev/arm64/* $(STAGING_DIR)/usr/lib/

        $(INSTALL) -D -m 0644  $(BR2_EXTERNAL_KNULLI_PATH)/package/gpu/mali-g57-sunxi/egl.pc \
                $(STAGING_DIR)/usr/lib/pkgconfig/egl.pc
        $(INSTALL) -D -m 0644  $(BR2_EXTERNAL_KNULLI_PATH)/package/gpu/mali-g57-sunxi/glesv2.pc \
                $(STAGING_DIR)/usr/lib/pkgconfig/glesv2.pc
        $(INSTALL) -D -m 0644  $(BR2_EXTERNAL_KNULLI_PATH)/package/gpu/mali-g57-sunxi/gbm.pc \
                $(STAGING_DIR)/usr/lib/pkgconfig/gbm.pc
        $(INSTALL) -D -m 0644  $(BR2_EXTERNAL_KNULLI_PATH)/package/gpu/mali-g57-sunxi/mali.pc \
                $(STAGING_DIR)/usr/lib/pkgconfig/mali.pc
        $(INSTALL) -D -m 0644  $(BR2_EXTERNAL_KNULLI_PATH)/package/gpu/mali-g57-sunxi/wayland-egl.pc \
                $(STAGING_DIR)/usr/lib/pkgconfig/wayland-egl.pc
endef

define MALI_G57_SUNXI_INSTALL_TARGET_CMDS
        mkdir -p $(TARGET_DIR)/usr/lib

        cp -rf $(@D)/fbdev/arm64/* $(TARGET_DIR)/usr/lib/
endef

$(eval $(generic-package))

