################################################################################
#
# knulli-overlay
#
################################################################################

KNULLI_OVERLAY_VERSION = f1b5673d5a34af82ce0ea97554b614ec1700d7b0
KNULLI_OVERLAY_SITE = https://github.com/knulli-cfw/knulli-overlay.git
KNULLI_OVERLAY_SITE_METHOD = git
KNULLI_OVERLAY_LICENSE = GPL-3.0
KNULLI_OVERLAY_LICENSE_FILES = LICENSE

# CC has to be passed on the command line: the project's Makefile derives it
# from CROSS_COMPILE, which would win over the environment.  CFLAGS/LDFLAGS
# must stay in the environment, so the Makefile can still append to them.
define KNULLI_OVERLAY_BUILD_CMDS
	$(TARGET_MAKE_ENV) $(TARGET_CONFIGURE_OPTS) $(MAKE) -C $(@D) \
		CC="$(TARGET_CC)" OUTDIR=build
endef

define KNULLI_OVERLAY_INSTALL_TARGET_CMDS
	$(INSTALL) -D -m 0755 $(@D)/build/libknulli-overlay.so \
		$(TARGET_DIR)/usr/lib/libknulli-overlay.so
	$(INSTALL) -D -m 0755 $(@D)/build/knulli-overlay \
		$(TARGET_DIR)/usr/bin/knulli-overlay
	$(INSTALL) -D -m 0755 $(@D)/scripts/knulli-overlay-watch \
		$(TARGET_DIR)/usr/bin/knulli-overlay-watch
endef

$(eval $(generic-package))
