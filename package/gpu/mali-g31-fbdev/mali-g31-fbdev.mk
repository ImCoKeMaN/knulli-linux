################################################################################
#
# mali g31 fbdev
#
################################################################################
# Version.: Commits on Apr 11, 2024
MALI_G31_FBDEV_VERSION = e992dcf03183862410dcb26ab3d596b7b207ce34
MALI_G31_FBDEV_SITE = $(call github,ben-willmore,t507_gpu_drivers,$(MALI_G31_FBDEV_VERSION))
MALI_G31_FBDEV_LICENSE = Proprietary
MALI_G31_FBDEV_LICENSE_FILES = END_USER_LICENCE_AGREEMENT.txt

MALI_G31_FBDEV_INSTALL_STAGING = YES
MALI_G31_FBDEV_PROVIDES = libegl libgles libmali

ifeq ($(BR2_aarch64),y)
LIB_SRC_DIR = aarch64-linux-gnu-7.4.1/lib64
endif

ifeq ($(BR2_arm),y)
LIB_SRC_DIR = armhf-linux-gnu/lib32
endif

define MALI_G31_FBDEV_INSTALL_STAGING_CMDS
	mkdir -p $(STAGING_DIR)/usr/lib/pkgconfig

	cp -rf $(@D)/include/* $(STAGING_DIR)/usr/include/
	cp -rf $(@D)/fbdev/include/EGL/* $(STAGING_DIR)/usr/include/EGL/

	cp -rf $(@D)/fbdev/mali-g31/$(LIB_SRC_DIR)/* $(STAGING_DIR)/usr/lib/

        $(INSTALL) -D -m 0644  $(BR2_EXTERNAL_KNULLI_PATH)/package/gpu/mali-g31-fbdev/egl.pc \
                $(STAGING_DIR)/usr/lib/pkgconfig/egl.pc
        $(INSTALL) -D -m 0644  $(BR2_EXTERNAL_KNULLI_PATH)/package/gpu/mali-g31-fbdev/glesv2.pc \
                $(STAGING_DIR)/usr/lib/pkgconfig/glesv2.pc

endef

define MALI_G31_FBDEV_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/lib

        cp -rf $(@D)/fbdev/mali-g31/$(LIB_SRC_DIR)/* $(TARGET_DIR)/usr/lib/
endef

$(eval $(generic-package))
