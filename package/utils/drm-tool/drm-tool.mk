################################################################################
#
# drm_tool
#
################################################################################

DRM_TOOL_VERSION = 1cb5b10b7d529105e33f27388519671ee7ce46f3
DRM_TOOL_SITE = https://github.com/NickCis/drm_tool.git
DRM_TOOL_SITE_METHOD = git
DRM_TOOL_LICENSE = GPL-3.0
DRM_TOOL_LICENSE_FILES = LICENSE

DRM_TOOL_DEPENDENCIES = libdrm

# Set compilation flags for libdrm
DRM_TOOL_CFLAGS = $(TARGET_CFLAGS) -D_FILE_OFFSET_BITS=64 $(shell $(PKG_CONFIG_HOST_BINARY) --cflags libdrm)
DRM_TOOL_LDFLAGS = $(TARGET_LDFLAGS) $(shell $(PKG_CONFIG_HOST_BINARY) --libs libdrm)

define DRM_TOOL_BUILD_CMDS
    $(MAKE) $(TARGET_CONFIGURE_OPTS) \
        CFLAGS="$(DRM_TOOL_CFLAGS)" \
        LDFLAGS="$(DRM_TOOL_LDFLAGS)" \
        -C $(@D)
endef

define DRM_TOOL_INSTALL_TARGET_CMDS
    $(INSTALL) -D -m 0755 $(@D)/drm_tool $(TARGET_DIR)/usr/bin/drm_tool
endef

$(eval $(generic-package))