################################################################################
#
# KNULLI AUDIO ALSA
#
################################################################################

KNULLI_AUDIO_ALSA_VERSION = 1.0
KNULLI_AUDIO_ALSA_LICENSE = GPL
KNULLI_AUDIO_ALSA_DEPENDENCIES = alsa-lib
KNULLI_AUDIO_ALSA_SOURCE=
KNULLI_AUDIO_ALSA_DEPENDENCIES += alsa-plugins

ifeq ($(BR2_PACKAGE_KNULLI_TARGET_RPI_ANY),y)
ALSA_SUFFIX = "-bcm"
else
ALSA_SUFFIX =
endif

define KNULLI_AUDIO_ALSA_INSTALL_TARGET_CMDS
	mkdir -p $(TARGET_DIR)/usr/bin $(TARGET_DIR)/usr/share/sounds $(TARGET_DIR)/usr/share/knulli/alsa
	# default alsa configurations
	cp $(BR2_EXTERNAL_KNULLI_PATH)/package/system/knulli-audio-alsa/alsa/asoundrc-* \
		$(TARGET_DIR)/usr/share/batocera/alsa/
	# sample audio files
	cp $(BR2_EXTERNAL_KNULLI_PATH)/package/system/knulli-audio-alsa/*.wav $(TARGET_DIR)/usr/share/sounds
	# init script
	install -m 0755 $(BR2_EXTERNAL_KNULLI_PATH)/package/system/knulli-audio-alsa/S01audio \
		$(TARGET_DIR)/etc/init.d/S01audio
	# udev script to unmute audio devices
	install -m 0644 $(BR2_EXTERNAL_KNULLI_PATH)/package/system/knulli-audio-alsa/90-alsa-setup.rules \
		$(TARGET_DIR)/etc/udev/rules.d/90-alsa-setup.rules
	install -m 0755 $(BR2_EXTERNAL_KNULLI_PATH)/package/system/knulli-audio-alsa/soundconfig \
		$(TARGET_DIR)/usr/bin/soundconfig
	install -m 0755 $(BR2_EXTERNAL_KNULLI_PATH)/package/system/knulli-audio-alsa/alsa/knulli-audio$(ALSA_SUFFIX) \
		$(TARGET_DIR)/usr/bin/knulli-audio
endef

$(eval $(generic-package))
