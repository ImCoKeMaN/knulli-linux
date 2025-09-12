################################################################################
#
# weston-legacy
#
################################################################################

WESTON-LEGACY_VERSION = 10.0.0
WESTON-LEGACY_SITE = https://wayland.freedesktop.org/releases
WESTON-LEGACY_SOURCE = weston-$(WESTON-LEGACY_VERSION).tar.xz
WESTON-LEGACY_LICENSE = MIT
WESTON-LEGACY_LICENSE_FILES = COPYING
WESTON-LEGACY_CPE_ID_VENDOR = wayland

WESTON-LEGACY_DEPENDENCIES = host-pkgconf wayland wayland-protocols \
	libxkbcommon pixman libpng udev cairo libinput 

WESTON-LEGACY_CONF_OPTS = \
	-Dbackend-headless=false \
	-Dcolor-management-colord=false \
	-Ddoc=false \
	-Dremoting=false \
	-Dtools=calibrator,debug,info,terminal,touch-calibrator

# Uses VIDIOC_EXPBUF, only available from 3.8+
ifeq ($(BR2_TOOLCHAIN_HEADERS_AT_LEAST_3_8),y)
WESTON-LEGACY_CONF_OPTS += -Dsimple-clients=dmabuf-v4l
else
WESTON-LEGACY_CONF_OPTS += -Dsimple-clients=
endif

ifeq ($(BR2_PACKAGE_DBUS)$(BR2_PACKAGE_SYSTEMD),yy)
WESTON-LEGACY_CONF_OPTS += -Dlauncher-logind=true
WESTON-LEGACY_DEPENDENCIES += dbus systemd
else
WESTON-LEGACY_CONF_OPTS += -Dlauncher-logind=false
endif

ifeq ($(BR2_PACKAGE_JPEG),y)
WESTON-LEGACY_CONF_OPTS += -Dimage-jpeg=true
WESTON-LEGACY_DEPENDENCIES += jpeg
else
WESTON-LEGACY_CONF_OPTS += -Dimage-jpeg=false
endif

ifeq ($(BR2_PACKAGE_WEBP),y)
WESTON-LEGACY_CONF_OPTS += -Dimage-webp=true
WESTON-LEGACY_DEPENDENCIES += webp
else
WESTON-LEGACY_CONF_OPTS += -Dimage-webp=false
endif

# weston-launch must be u+s root in order to work properly
ifeq ($(BR2_PACKAGE_LINUX_PAM),y)
define WESTON-LEGACY_PERMISSIONS
	/usr/bin/weston-launch f 4755 0 0 - - - - -
endef
define WESTON-LEGACY_USERS
	- - weston-launch -1 - - - - Weston launcher group
endef
WESTON-LEGACY_CONF_OPTS += -Ddeprecated-weston-launch=true
WESTON-LEGACY_DEPENDENCIES += linux-pam
else
WESTON-LEGACY_CONF_OPTS += -Ddeprecated-weston-launch=false
endif

ifeq ($(BR2_PACKAGE_HAS_LIBEGL_WAYLAND)$(BR2_PACKAGE_HAS_LIBGLES),yy)
WESTON-LEGACY_CONF_OPTS += -Drenderer-gl=true
WESTON-LEGACY_DEPENDENCIES += libegl libgles
ifeq ($(BR2_PACKAGE_PIPEWIRE)$(BR2_PACKAGE_WESTON-LEGACY_DRM),yy)
WESTON-LEGACY_CONF_OPTS += -Dpipewire=true
WESTON-LEGACY_DEPENDENCIES += pipewire
else
WESTON-LEGACY_CONF_OPTS += -Dpipewire=false
endif
else
WESTON-LEGACY_CONF_OPTS += \
	-Drenderer-gl=false \
	-Dpipewire=false
endif

ifeq ($(BR2_PACKAGE_WESTON-LEGACY_RDP),y)
WESTON-LEGACY_DEPENDENCIES += freerdp
WESTON-LEGACY_CONF_OPTS += -Dbackend-rdp=true
else
WESTON-LEGACY_CONF_OPTS += -Dbackend-rdp=false
endif

ifeq ($(BR2_PACKAGE_WESTON-LEGACY_FBDEV),y)
WESTON-LEGACY_CONF_OPTS += -Ddeprecated-backend-fbdev=true
else
WESTON-LEGACY_CONF_OPTS += -Ddeprecated-backend-fbdev=false
endif

WESTON-LEGACY_CONF_OPTS += -Dbackend-drm=false

ifeq ($(BR2_PACKAGE_WESTON-LEGACY_HEADLESS),y)
WESTON-LEGACY_CONF_OPTS += -Dbackend-headless=true
else
WESTON-LEGACY_CONF_OPTS += -Dbackend-headless=false
endif

ifeq ($(BR2_PACKAGE_WESTON-LEGACY_WAYLAND),y)
WESTON-LEGACY_CONF_OPTS += -Dbackend-wayland=true
else
WESTON-LEGACY_CONF_OPTS += -Dbackend-wayland=false
endif

ifeq ($(BR2_PACKAGE_WESTON-LEGACY_X11),y)
WESTON-LEGACY_CONF_OPTS += -Dbackend-x11=true
WESTON-LEGACY_DEPENDENCIES += libxcb xlib_libX11
else
WESTON-LEGACY_CONF_OPTS += -Dbackend-x11=false
endif

# We're guaranteed to have at least one backend
WESTON-LEGACY_CONF_OPTS += -Dbackend-default=$(call qstrip,$(BR2_PACKAGE_WESTON-LEGACY_DEFAULT_COMPOSITOR))

ifeq ($(BR2_PACKAGE_WESTON-LEGACY_XWAYLAND),y)
WESTON-LEGACY_CONF_OPTS += -Dxwayland=true
WESTON-LEGACY_DEPENDENCIES += cairo libepoxy libxcb xlib_libX11 xlib_libXcursor
else
WESTON-LEGACY_CONF_OPTS += -Dxwayland=false
endif

WESTON-LEGACY_CONF_OPTS += -Dbackend-drm-screencast-vaapi=false

ifeq ($(BR2_PACKAGE_LCMS2),y)
WESTON-LEGACY_CONF_OPTS += -Dcolor-management-lcms=true
WESTON-LEGACY_DEPENDENCIES += lcms2
else
WESTON-LEGACY_CONF_OPTS += -Dcolor-management-lcms=false
endif

ifeq ($(BR2_PACKAGE_SYSTEMD),y)
WESTON-LEGACY_CONF_OPTS += -Dsystemd=true
WESTON-LEGACY_DEPENDENCIES += systemd
else
WESTON-LEGACY_CONF_OPTS += -Dsystemd=false
endif

ifeq ($(BR2_PACKAGE_LIBXML2),y)
WESTON-LEGACY_CONF_OPTS += -Dtest-junit-xml=true
WESTON-LEGACY_DEPENDENCIES += libxml2
else
WESTON-LEGACY_CONF_OPTS += -Dtest-junit-xml=false
endif

ifeq ($(BR2_PACKAGE_WESTON-LEGACY_SHELL_DESKTOP),y)
WESTON-LEGACY_CONF_OPTS += -Dshell-desktop=true
else
WESTON-LEGACY_CONF_OPTS += -Dshell-desktop=false
endif

ifeq ($(BR2_PACKAGE_WESTON-LEGACY_SHELL_FULLSCREEN),y)
WESTON-LEGACY_CONF_OPTS += -Dshell-fullscreen=true
else
WESTON-LEGACY_CONF_OPTS += -Dshell-fullscreen=false
endif

ifeq ($(BR2_PACKAGE_WESTON-LEGACY_SHELL_IVI),y)
WESTON-LEGACY_CONF_OPTS += -Dshell-ivi=true
else
WESTON-LEGACY_CONF_OPTS += -Dshell-ivi=false
endif

ifeq ($(BR2_PACKAGE_WESTON-LEGACY_SHELL_KIOSK),y)
WESTON-LEGACY_CONF_OPTS += -Dshell-kiosk=true
else
WESTON-LEGACY_CONF_OPTS += -Dshell-kiosk=false
endif

ifeq ($(BR2_PACKAGE_WESTON-LEGACY_DEMO_CLIENTS),y)
WESTON-LEGACY_CONF_OPTS += -Ddemo-clients=true
WESTON-LEGACY_DEPENDENCIES += pango
else
WESTON-LEGACY_CONF_OPTS += -Ddemo-clients=false
endif

$(eval $(meson-package))
