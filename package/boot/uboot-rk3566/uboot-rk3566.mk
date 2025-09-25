################################################################################
#
# uboot files for Rockchip RK3566 
#
################################################################################

UBOOT_RK3566_VERSION = 1.0
UBOOT_RK3566_SOURCE =

define UBOOT_RK3566_BUILD_CMDS
endef

#
# The RK3566 BSP uboot works on most models except the Powkiddy X55 that requires a different version
#
define UBOOT_RK3566_INSTALL_TARGET_CMDS
	mkdir -p $(BINARIES_DIR)/uboot-rk3566
	cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/boot/uboot-rk3566/u-boot-rk3566.bin $(BINARIES_DIR)/uboot-rk3566/u-boot-rk3566.bin
    cp $(BR2_EXTERNAL_BATOCERA_PATH)/package/boot/uboot-rk3566/u-boot-rk3566-x55.bin $(BINARIES_DIR)/uboot-rk3566/u-boot-rk3566-x55.bin
endef

$(eval $(generic-package))
