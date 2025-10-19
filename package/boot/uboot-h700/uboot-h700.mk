################################################################################
#
# uboot-h700
#
################################################################################

UBOOT_H700_VERSION = 1.0
UBOOT_H700_SOURCE = 
UBOOT_H700_SITE = 
UBOOT_H700_LICENSE = GPL-2.0
UBOOT_H700_DEPENDENCIES = host-dtc host-allwinner-utils

# List of supported H700 devices
UBOOT_H700_DEVICES = rg-cubexx rg28xx rg34xx rg34xx-sp rg35xx-h rg35xx-plus rg35xx-pro rg35xx-sp rg40xx-h rg40xx-v

define UBOOT_H700_EXTRACT_CMDS
    # Copy all device configurations to build directory
    cp -r $(UBOOT_H700_PKGDIR)/* $(@D)/
endef

define UBOOT_H700_BUILD_CMDS
    # Build DTB and boot_package.fex for each device
    $(foreach device,$(UBOOT_H700_DEVICES), \
        if [ -d "$(@D)/$(device)" ]; then \
            echo "Building DTB for $(device)..."; \
            $(HOST_DIR)/bin/dtc -I dts -O dtb \
                -o $(@D)/$(device)/boot_package/dtb.bin \
                $(@D)/$(device)/boot_package/$(device).dts || exit 1; \
            echo "Building boot_package.fex for $(device)..."; \
            cd $(@D)/$(device)/boot_package/ && \
            $(HOST_DIR)/bin/dragonsecboot -pack boot_package.cfg || exit 1; \
        fi; \
    )
endef

define UBOOT_H700_INSTALL_IMAGES_CMDS
    # Create H700 boot packages directory
    mkdir -p $(BINARIES_DIR)/h700-boot-packages
    
    # Install boot_package.fex files for each device
    $(foreach device,$(UBOOT_H700_DEVICES), \
        if [ -f "$(@D)/$(device)/boot_package/boot_package.fex" ]; then \
            echo "Installing $(device) boot package..."; \
            cp $(@D)/$(device)/boot_package/boot_package.fex \
                $(BINARIES_DIR)/h700-boot-packages/$(device)_boot_package.fex; \
        fi; \
    )
    
    # Create a summary file
    echo "H700 Boot Packages:" > $(BINARIES_DIR)/h700-boot-packages/README.txt
    echo "==================" >> $(BINARIES_DIR)/h700-boot-packages/README.txt
    echo "" >> $(BINARIES_DIR)/h700-boot-packages/README.txt
    $(foreach device,$(UBOOT_H700_DEVICES), \
        if [ -f "$(BINARIES_DIR)/h700-boot-packages/$(device)_boot_package.fex" ]; then \
            echo "- $(device)_boot_package.fex" >> $(BINARIES_DIR)/h700-boot-packages/README.txt; \
        fi; \
    )
    
    echo "" >> $(BINARIES_DIR)/h700-boot-packages/README.txt
    echo "Generated on: $$(date)" >> $(BINARIES_DIR)/h700-boot-packages/README.txt
endef

# This package installs to images directory, not target
UBOOT_H700_INSTALL_TARGET = NO
UBOOT_H700_INSTALL_STAGING = NO
UBOOT_H700_INSTALL_IMAGES = YES

$(eval $(generic-package))
