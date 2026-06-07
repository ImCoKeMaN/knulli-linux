################################################################################
#
# knulli bezels
#
################################################################################
# Version.: Committed on June 07, 2026
KNULLI_BEZELS_VERSION = d062469f128cd56581a9d4a45a3a8d6b6032b0f9
KNULLI_BEZELS_SITE = $(call github,chrizzo-hb,knulli-bezels,$(KNULLI_BEZELS_VERSION))

define KNULLI_BEZELS_INSTALL_TARGET_CMDS
  mkdir -p $(TARGET_DIR)/usr/share/knulli/datainit/decorations
  # Default Knulli bezels
  cp -rf $(@D)/default-knulli                           $(TARGET_DIR)/usr/share/knulli/datainit/decorations
  cp -rf $(@D)/default-knulli-sp                        $(TARGET_DIR)/usr/share/knulli/datainit/decorations
  # Generic bezels (4:3 and 16:9) (e.g., for Ports)
  cp -rf $(@D)/generic-4-by-3                           $(TARGET_DIR)/usr/share/knulli/datainit/decorations
  cp -rf $(@D)/generic-16-by-9                          $(TARGET_DIR)/usr/share/knulli/datainit/decorations
  # Mugwomp93 bezels
  cp -rf $(@D)/mugwomp93-integer-grids                  $(TARGET_DIR)/usr/share/knulli/datainit/decorations
  cp -rf $(@D)/mugwomp93-integer-grids-gb-noshader      $(TARGET_DIR)/usr/share/knulli/datainit/decorations
  cp -rf $(@D)/mugwomp93-integer-nogrids                $(TARGET_DIR)/usr/share/knulli/datainit/decorations
  cp -rf $(@D)/mugwomp93-noninteger-grids               $(TARGET_DIR)/usr/share/knulli/datainit/decorations
  cp -rf $(@D)/mugwomp93-noninteger-grids-sp            $(TARGET_DIR)/usr/share/knulli/datainit/decorations
  (cd $(TARGET_DIR)/usr/share/knulli/datainit/decorations && ln -sf default-knulli default)

endef

$(eval $(generic-package))
