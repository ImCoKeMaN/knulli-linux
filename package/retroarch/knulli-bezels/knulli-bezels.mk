################################################################################
#
# knulli bezels
#
################################################################################
# Version.: Committed on May 10, 2026
KNULLI_BEZELS_VERSION = 586608237a17fbaa1140207a47b3b82c5c5b926c
KNULLI_BEZELS_SITE = $(call github,chrizzo-hb,knulli-bezels,$(KNULLI_BEZELS_VERSION))

define KNULLI_BEZELS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/share/knulli/datainit/decorations
	cp -rf $(@D)/default-knulli		      $(TARGET_DIR)/usr/share/knulli/datainit/decorations
	cp -rf $(@D)/default-knulli-sp	      $(TARGET_DIR)/usr/share/knulli/datainit/decorations
	(cd $(TARGET_DIR)/usr/share/knulli/datainit/decorations && ln -sf default-knulli default)

endef

$(eval $(generic-package))
