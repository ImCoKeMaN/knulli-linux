################################################################################
#
# knulli-bluetooth
#
################################################################################

KNULLI_BLUETOOTH_VERSION = 2.2
KNULLI_BLUETOOTH_LICENSE = GPL
KNULLI_BLUETOOTH_SOURCE=

KNULLI_BLUETOOTH_STACK=

ifeq ($(BR2_PACKAGE_KNULLI_TARGET_BCM2835)$(BR2_PACKAGE_KNULLI_TARGET_BCM2835),y)
    KNULLI_BLUETOOTH_STACK=bcm921 piscan
else ifeq ($(BR2_PACKAGE_KNULLI_TARGET_RK3288),y) # tinkerboard only ??
    KNULLI_BLUETOOTH_STACK=rfkreset rtk115
else ifeq ($(BR2_PACKAGE_KNULLI_TARGET_RK3399),y)
    KNULLI_BLUETOOTH_STACK=rfkreset bcm150
else ifeq ($(BR2_PACKAGE_KNULLI_TARGET_H6)$(BR2_PACKAGE_KNULLI_TARGET_H616),y)
    KNULLI_BLUETOOTH_STACK=rfkreset sprd
else ifeq ($(BR2_PACKAGE_KNULLI_TARGET_A3GEN2),y)
    KNULLI_BLUETOOTH_STACK=kvim4
endif

define KNULLI_BLUETOOTH_INSTALL_TARGET_CMDS
    mkdir -p $(TARGET_DIR)/etc/init.d/
    cp $(BR2_EXTERNAL_KNULLI_PATH)/package/system/knulli-bluetooth/S29namebluetooth \
        $(TARGET_DIR)/etc/init.d/S29namebluetooth
    cp $(BR2_EXTERNAL_KNULLI_PATH)/package/system/knulli-bluetooth/S32bluetooth.template \
        $(TARGET_DIR)/etc/init.d/S32bluetooth
    sed -i -e s+"@INTERNAL_BLUETOOTH_STACK@"+"$(KNULLI_BLUETOOTH_STACK)"+ \
        $(TARGET_DIR)/etc/init.d/S32bluetooth
endef

$(eval $(generic-package))
