################################################################################
#
# silkyrgb
#
################################################################################

SILKYRGB_VERSION = main
SILKYRGB_SITE = https://github.com/chrizzo-hb/silky-rgb.git
SILKYRGB_SITE_METHOD = git
SILKYRGB_LICENSE = MIT
SILKYRGB_LICENSE_FILES = LICENSE

# Install resource files if they exist
define SILKYRGB_INSTALL_TARGET_CMDS
	if [ ! -d $(TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/silkyrgb ]; then \
		mkdir -p $(TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/silkyrgb; \
	fi && \
	cp -r $(@D)/* $(TARGET_DIR)/usr/lib/python$(PYTHON3_VERSION_MAJOR)/site-packages/silkyrgb/; \
	if [ -d $(@D)/installer-knulli ]; then \
		cp -r $(@D)/installer-knulli/S98rgbled $(TARGET_DIR)/etc/init.d/ && \
		cp -r $(@D)/installer-knulli/knulli-rgb $(TARGET_DIR)/usr/bin/ && \
		cp -r $(@D)/installer-knulli/rgb.sh $(TARGET_DIR)/usr/bin/; \
	fi
endef

$(eval $(generic-package))