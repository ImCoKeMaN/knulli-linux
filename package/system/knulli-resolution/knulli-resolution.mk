################################################################################
#
# knulli resolution
#
################################################################################

KNULLI_RESOLUTION_VERSION = 1.3
KNULLI_RESOLUTION_LICENSE = GPL
KNULLI_RESOLUTION_DEPENDENCIES = pciutils
KNULLI_RESOLUTION_SOURCE=
KNULLI_RESOLUTION_PATH = $(BR2_EXTERNAL_KNULLI_PATH)/package/system/knulli-resolution/scripts

KNULLI_SCRIPT_TYPE=basic

ifeq ($(BR2_PACKAGE_RPI_USERLAND),y)
KNULLI_SCRIPT_TYPE=tvservice
endif

ifeq ($(BR2_PACKAGE_LIBDRM),y)
KNULLI_SCRIPT_TYPE=drm
endif

ifeq ($(BR2_PACKAGE_XSERVER_XORG_SERVER),y)
KNULLI_SCRIPT_TYPE=xorg
endif

ifeq ($(BR2_PACKAGE_BATOCERA_WAYLAND_SWAY),y)
KNULLI_SCRIPT_TYPE=wayland-sway
KNULLI_RESOLUTION_DEPENDENCIES += grim wf-recorder
endif

ifeq ($(BR2_PACKAGE_BATOCERA_WAYLAND_LABWC),y)
KNULLI_SCRIPT_TYPE=wayland-labwc
KNULLI_RESOLUTION_DEPENDENCIES += grim wf-recorder
endif

define KNULLI_RESOLUTION_INSTALL_TARGET_CMDS
	install -m 0755 $(KNULLI_RESOLUTION_PATH)/resolution/knulli-resolution.$(KNULLI_SCRIPT_TYPE) $(TARGET_DIR)/usr/bin/knulli-resolution
	install -m 0755 $(KNULLI_RESOLUTION_PATH)/screenshot/knulli-screenshot.$(KNULLI_SCRIPT_TYPE) $(TARGET_DIR)/usr/bin/knulli-screenshot
endef

define KNULLI_RESOLUTION_INSTALL_RK3128
	install -m 0755 $(KNULLI_RESOLUTION_PATH)/resolution/knulli-resolution-post-rk3128 $(TARGET_DIR)/usr/bin/knulli-resolution-post
endef

define KNULLI_RESOLUTION_INSTALL_XORG
	mkdir -p $(TARGET_DIR)/etc/X11/xorg.conf.d
	cp -prn $(BR2_EXTERNAL_KNULLI_PATH)/board/x86/fsoverlay/etc/X11/xorg.conf.d/20-amdgpu.conf $(TARGET_DIR)/etc/X11/xorg.conf.d/20-amdgpu.conf
endef

define KNULLI_RESOLUTION_INSTALL_RECORDER
	install -m 0755 $(KNULLI_RESOLUTION_PATH)/recorder/knulli-record.$(KNULLI_SCRIPT_TYPE) $(TARGET_DIR)/usr/bin/knulli-record
endef

ifeq ($(BR2_PACKAGE_BATOCERA_TARGET_RK3128),y)
	KNULLI_RESOLUTION_POST_INSTALL_TARGET_HOOKS += KNULLI_RESOLUTION_INSTALL_RK3128
endif

ifeq ($(BR2_PACKAGE_XSERVER_XORG_SERVER),y)
	KNULLI_RESOLUTION_POST_INSTALL_TARGET_HOOKS += KNULLI_RESOLUTION_INSTALL_XORG
endif

ifeq ($(BR2_PACKAGE_XSERVER_XORG_SERVER)$(BR2_PACKAGE_BATOCERA_WAYLAND_SWAY)$(BR2_PACKAGE_BATOCERA_WAYLAND_LABWC),y)
	KNULLI_RESOLUTION_POST_INSTALL_TARGET_HOOKS += KNULLI_RESOLUTION_INSTALL_RECORDER
endif

$(eval $(generic-package))
