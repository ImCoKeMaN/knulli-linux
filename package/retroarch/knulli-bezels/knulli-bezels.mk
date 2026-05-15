################################################################################
#
# knulli bezels
#
################################################################################
# Version.: Committed on May 10, 2026
KNULLI_BEZELS_VERSION = 9fea3a2e0827cfadf13de65b6a36b742fdab2ef0
KNULLI_BEZELS_SITE = $(call github,chrizzo-hb,knulli-bezels,$(KNULLI_BEZELS_VERSION))

define KNULLI_BEZELS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/share/knulli/datainit/decorations
	cp -rf $(@D)/default-knulli		      $(TARGET_DIR)/usr/share/knulli/datainit/decorations
	cp -rf $(@D)/default-knulli-sp	      $(TARGET_DIR)/usr/share/knulli/datainit/decorations
	cp -rf $(@D)/generic-4-by-3	          $(TARGET_DIR)/usr/share/knulli/datainit/decorations
	cp -rf $(@D)/generic-16-by-9	      $(TARGET_DIR)/usr/share/knulli/datainit/decorations
	(cd $(TARGET_DIR)/usr/share/knulli/datainit/decorations && ln -sf default-knulli default)

endef

$(eval $(generic-package))
