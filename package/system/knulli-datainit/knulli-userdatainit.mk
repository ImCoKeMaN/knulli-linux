################################################################################
#
# knulli userdata init
#
################################################################################

KNULLI_USERDATAINIT_VERSION = 1.0
KNULLI_USERDATAINIT_LICENSE = GPL
KNULLI_USERDATAINIT_SOURCE=

define KNULLI_USERDATAINIT_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/share/knulli/datainit
	rsync -arv $(BR2_EXTERNAL_KNULLI_PATH)/package/knulli/core/knulli-userdatainit/datainit/ $(TARGET_DIR)/usr/share/knulli/datainit/
endef

$(eval $(generic-package))
