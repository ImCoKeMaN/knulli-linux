################################################################################
#
# EmulationStation theme "Knulli"
#
################################################################################
# Version: Commits on Feb 09, 2026
ES_THEME_KNULLI_VERSION = 935cd953df0aa4e42d9562847b854f01806b8063
ES_THEME_KNULLI_SITE = $(call github,symbuzzer,es-theme-knulli,$(ES_THEME_KNULLI_VERSION))

define ES_THEME_KNULLI_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
    cp -r $(@D)/* $(TARGET_DIR)/usr/share/emulationstation/themes/es-theme-knulli
endef

$(eval $(generic-package))
