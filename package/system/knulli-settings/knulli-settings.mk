################################################################################
#
# knulli-settings
#
################################################################################

KNULLI_SETTINGS_VERSION = b9822f8f8aaafbc46cf9123f3b3e10d9b0d523ac
KNULLI_SETTINGS_SITE = $(call github,knulli-cfw,mini_settings,$(KNULLI_SETTINGS_VERSION))
KNULLI_SETTINGS_LICENSE = MIT

KNULLI_SETTINGS_CONF_OPTS = \
  -Ddefault_config_path=/userdata/system/knulli.conf \
  -Dget_exe_name=knulli-settings-get \
  -Dset_exe_name=knulli-settings-set

define KNULLI_SETTINGS_MASTER_BIN
    install -m 0755 $(BR2_EXTERNAL_KNULLI_PATH)/package/system/knulli-settings/knulli-settings-get-master $(TARGET_DIR)/usr/bin/knulli-settings-get-master
endef

KNULLI_SETTINGS_POST_INSTALL_TARGET_HOOKS += KNULLI_SETTINGS_MASTER_BIN

$(eval $(meson-package))
