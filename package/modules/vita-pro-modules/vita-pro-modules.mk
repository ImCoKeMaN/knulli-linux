################################################################################
#
# vita-pro-modules
#
################################################################################

VITA_PRO_MODULES_VERSION = 1.0
VITA_PRO_MODULES_SITE = $(VITA_PRO_MODULES_PKGDIR)
VITA_PRO_MODULES_SITE_METHOD = local

# The kernel module install path
VITA_PRO_MODULES_INSTALL_DIR = /lib/modules/$(LINUX_VERSION_PROBED)/extra

define VITA_PRO_MODULES_INSTALL_TARGET_CMDS
    $(INSTALL) -d $(TARGET_DIR)/$(VITA_PRO_MODULES_INSTALL_DIR)
    $(INSTALL) -m 0644 $(@D)/*.ko \
        $(TARGET_DIR)/$(VITA_PRO_MODULES_INSTALL_DIR)/
endef

# Run depmod after installing — same thing kernel-module macro does
define VITA_PRO_MODULES_LINUX_CONFIG_FIXUPS
endef

$(eval $(generic-package))
