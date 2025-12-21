# Trimui (A527)

monitor.alsa.rules = [
  {
    matches = [
      {
        device.name = "alsa_card._sys_devices_platform_soc_3000000_soc_3000000_codec_mach_sound_card0"
      }
    ]
    actions = {
      update-props = {
        api.alsa.use-acp = false
        api.alsa.use-ucm = false
        api.acp.auto-profile = false
        api.acp.auto-port = false
      }
    }
  }
  {
    matches = [
      {
        node.name = "alsa_output._sys_devices_platform_soc_3000000_soc_3000000_codec_mach_sound_card0.playback.0.0"
      }
    ]
    actions = {
      update-props = {
        api.alsa.disable-mmap = true
        api.alsa.soft-mixer = true

        audio.format = "S16LE"
        audio.rate = 48000
        audio.channels = 2
      }
    }
  }
]

