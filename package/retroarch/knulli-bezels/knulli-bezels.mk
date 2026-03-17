################################################################################
#
# knulli bezels
#
################################################################################
# Version.: Committed on March 17, 2026
KNULLI_BEZELS_VERSION = 88dd1ae4a73fac1a8657003246ecfc9d75d99094
KNULLI_BEZELS_SITE = $(call github,chrizzo-hb,knulli-bezels,$(KNULLI_BEZELS_VERSION))

define KNULLI_BEZELS_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/share/knulli/datainit/decorations
	cp -rf $(@D)/default-knulli		      $(TARGET_DIR)/usr/share/knulli/datainit/decorations
	cp -rf $(@D)/default-knulli-sp	      $(TARGET_DIR)/usr/share/knulli/datainit/decorations
	(cd $(TARGET_DIR)/usr/share/knulli/datainit/decorations && ln -sf default-knulli default)

endef

$(eval $(generic-package))
