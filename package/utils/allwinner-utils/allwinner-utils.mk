################################################################################
#
# allwinner-utils
#
################################################################################

ALLWINNER_UTILS_VERSION = 66703c7b12278857dad3483e9c9080758dca819d
ALLWINNER_UTILS_SITE = https://github.com/knulli-cfw/hdzero-goggle-tools.git
ALLWINNER_UTILS_SITE_METHOD = git
ALLWINNER_UTILS_GIT_SUBMODULES = NO
ALLWINNER_UTILS_LICENSE = GPL-2.0
ALLWINNER_UTILS_LICENSE_FILES = LICENSE

# This is a host-only package for build tools
define HOST_ALLWINNER_UTILS_BUILD_CMDS
    $(MAKE) -C $(@D) CC="$(HOSTCC)" CFLAGS="$(HOST_CFLAGS)"
endef

define HOST_ALLWINNER_UTILS_INSTALL_CMDS
    $(INSTALL) -D -m 0755 $(@D)/dragonsecboot $(HOST_DIR)/bin/dragonsecboot
    $(INSTALL) -D -m 0755 $(@D)/u_boot_env_gen $(HOST_DIR)/bin/u_boot_env_gen
endef

# Only build host version since these are build tools
$(eval $(host-generic-package))