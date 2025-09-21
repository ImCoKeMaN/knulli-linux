################################################################################
#
# drminfo
#
################################################################################
# Version.: Commits on May 27, 2020
KNULLI_DRMINFO_VERSION = 1
KNULLI_DRMINFO_SOURCE =
KNULLI_DRMINFO_LICENSE = GPLv3+
KNULLI_DRMINFO_DEPENDENCIES = libdrm

KNULLI_DRMINFO_FLAGS=

# too old kernel
ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RK3128),y)
	KNULLI_DRMINFO_FLAGS += -DHAVE_NOT_DRM_MODE_CONNECTOR_DPI
endif

KNULLI_DRMINFO_MAIN=knulli-drminfo.c

# this resolution seems to cause issues on the rpi4 (dmanlfc)
ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_BCM2711),y)
BATOCERA_DRMINFO_MAIN=knulli-drminfo-no-1360x768.c
endif

define KNULLI_DRMINFO_BUILD_CMDS
	$(TARGET_CONFIGURE_OPTS) $(TARGET_CC) -I$(STAGING_DIR)/usr/include/drm -ldrm $(BR2_EXTERNAL_KNULLI_PATH)/package/system/knulli-drminfo/$(KNULLI_DRMINFO_MAIN) -o $(@D)/knulli-drminfo $(KNULLI_DRMINFO_FLAGS)
endef

define KNULLI_DRMINFO_INSTALL_TARGET_CMDS
	$(INSTALL) -m 0755 -D $(@D)/knulli-drminfo $(TARGET_DIR)/usr/bin/knulli-drminfo
endef

$(eval $(generic-package))
