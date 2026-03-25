from __future__ import annotations

import logging
import subprocess
from os import environ
from pathlib import Path
from typing import TYPE_CHECKING, Final

from ... import Command
from ...batoceraPaths import CACHE, CONFIGS, SAVES, ensure_parents_and_open
from ...controller import Controller, generate_sdl_game_controller_config
from ...utils.configparser import CaseSensitiveRawConfigParser
from ..Generator import Generator

if TYPE_CHECKING:
    from ...controller import Controllers
    from ...Emulator import Emulator
    from ...input import InputMapping
    from ...types import HotkeysContext


_logger = logging.getLogger(__name__)

def has_vulkan(feature: str) -> bool:
    try:
        return subprocess.check_output(
            ["/usr/bin/knulli-vulkan", feature],
            text=True
        ).strip() == "true"
    except Exception as e:
        _logger.debug("knulli-vulkan %s failed: %s", feature, e)
        return False

class AzaharGenerator(Generator):

    def getHotkeysContext(self) -> HotkeysContext:
        return {
            "name": "azahar",
            "keys": { "exit": ["KEY_LEFTALT", "KEY_F4"], "menu": "KEY_F4", "reset": "KEY_F6", "screen_layout": "KEY_F10", "swap_screen": "KEY_F9" }
        }

    # Main entry of the module
    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        AzaharGenerator.writeAZAHARConfig(CONFIGS / "azahar-emu" / "sdl2-config.ini", system, playersControllers)

        commandArray = ['/usr/bin/azahar', '--fullscreen', rom]

        return Command.Command(array=commandArray, env={
            "XDG_CONFIG_HOME": CONFIGS,
            "XDG_DATA_HOME": SAVES / "3ds",
            "XDG_CACHE_HOME": CACHE,
            "HOME": SAVES / "3ds" / "azahar-emu",
            "QT_QPA_PLATFORM":"wayland",
            "QT_QPA_PLATFORM_PLUGINS_PATH": "/usr/lib/qt6/plugins/platforms",
            "SDL_GAMECONTROLLERCONFIG": generate_sdl_game_controller_config(playersControllers),
            "SDL_JOYSTICK_HIDAPI": "0",
            }
        )

    # Show mouse on screen
    def getMouseMode(self, config, rom):
        if "azahar_screen_layout" in config and config["azahar_screen_layout"] == "1-false":
            return False
        else:
            return True

    @staticmethod
    def writeAZAHARConfig(
        azaharConfigFile: Path,
        system: Emulator,
        playersControllers: Controllers
    ) -> None:
        # Pads
        azaharButtons = {
            "button_a":      "a",
            "button_b":      "b",
            "button_x":      "x",
            "button_y":      "y",
            "button_up":     "up",
            "button_down":   "down",
            "button_left":   "left",
            "button_right":  "right",
            "button_l":      "pageup",
            "button_r":      "pagedown",
            "button_start":  "start",
            "button_select": "select",
            "button_zl":     "l2",
            "button_zr":     "r2",
            "button_home":   "hotkey"
        }

        azaharAxis = {
            "circle_pad":    "joystick1",
            "c_stick":       "joystick2"
        }

        # ini file
        azaharConfig = CaseSensitiveRawConfigParser(strict=False)
        if azaharConfigFile.exists():
            azaharConfig.read(azaharConfigFile)

        ## [LAYOUT]
        if not azaharConfig.has_section("Layout"):
            azaharConfig.add_section("Layout")
        # Screen Layout
        azaharConfig.set("Layout", "custom_layout", "false")
        layout_option, swap_screen = system.config.get("azahar_screen_layout", "0-false").split('-')
        azaharConfig.set("Layout", "swap_screen",   swap_screen)
        azaharConfig.set("Layout", "layout_option", layout_option)

        if system.isOptSet('azahar_large_screen_proportion'):
            azaharConfig.set("Layout", "large_screen_proportion", system.config["azahar_large_screen_proportion"])
        else:
            azaharConfig.set("Layout", "large_screen_proportion", 4)

        ## [SYSTEM]
        if not azaharConfig.has_section("System"):
            azaharConfig.add_section("System")
        # New 3DS Version
        if system.isOptSet('azahar_is_new_3ds') and system.config["azahar_is_new_3ds"] == '1':
            azaharConfig.set("System", "is_new_3ds", "true")
        else:
            azaharConfig.set("System", "is_new_3ds", "false")
        # Language
        azaharConfig.set("System", "region_value", str(getAzaharLangFromEnvironment()))

        ## [UI]
        if not azaharConfig.has_section("UI"):
            azaharConfig.add_section("UI")

        azaharConfig.set("UI", "saveStateWarning", "false")

        # Hotkeys
        azaharConfig.set("UI", r"Shortcuts\Main%20Window\Quick%20Save\KeySeq", "Ctrl+1")

        azaharConfig.set("UI", r"Shortcuts\Main%20Window\Quick%20Load\KeySeq", "Ctrl+2")

        # Start Fullscreen
        azaharConfig.set("UI", "fullscreen", "true")

        # Knulli - Defaults
        azaharConfig.set("UI", "displayTitleBars", "false")
        azaharConfig.set("UI", "firstStart", "false")
        azaharConfig.set("UI", "hideInactiveMouse", "true")
        azaharConfig.set("UI", "enable_discord_presence", "false")

        # Remove pop-up prompt on start
        azaharConfig.set("UI", "calloutFlags", "1")
        # Close without confirmation
        azaharConfig.set("UI", "confirmClose", "false")

        # screenshots
        azaharConfig.set("UI", r"Paths\screenshotPath", "/userdata/screenshots")

        ## [MISCELLANEOUS]
        if not azaharConfig.has_section("Miscellaneous"):
            azaharConfig.add_section("Miscellaneous")
        # Don't check for update at start
        azaharConfig.set("Miscellaneous", "check_for_update_on_start", "false")

        ## [RENDERER]
        if not azaharConfig.has_section("Renderer"):
            azaharConfig.add_section("Renderer")
        # Use Hardware Shader by default; give user choice to disable it for some games
        if system.isOptSet('azahar_use_hw_shader') and not system.getOptBoolean("azahar_use_hw_shader"):
            azaharConfig.set("Renderer", "use_hw_shader", "0")
        else:
            azaharConfig.set("Renderer", "use_hw_shader", "1")
        azaharConfig.set("Renderer", "use_shader_jit", "1")

        # Software, OpenGL (default) or Vulkan
        if system.isOptSet('azahar_graphics_api'):
            azaharConfig.set("Renderer", "graphics_api", system.config["azahar_graphics_api"])
        else:
            azaharConfig.set("Renderer", "graphics_api", "2") # Default to Vulkan, but it will be set to OpenGL if Vulkan is not available

        # Set Vulkan as necessary
        if system.isOptSet("azahar_graphics_api") and system.config["azahar_graphics_api"] == "2" and has_vulkan("hasVulkan"):
            _logger.debug("Vulkan driver is available on the system.")

        # Use VSYNC
        if system.isOptSet('azahar_use_vsync_new') and system.config["azahar_use_vsync_new"] == '0':
            azaharConfig.set("Renderer", "use_vsync", "0")
        else:
            azaharConfig.set("Renderer", "use_vsync", "1")

        # Resolution Factor
        if system.isOptSet('azahar_resolution_factor'):
            azaharConfig.set("Renderer", "resolution_factor", system.config["azahar_resolution_factor"])
        else:
            azaharConfig.set("Renderer", "resolution_factor", "1")

        # Frame Limit (0 = unlimited, 100 = default)
        if system.isOptSet('azahar_use_frame_limit') and system.config["azahar_use_frame_limit"] == '0':
            azaharConfig.set("Renderer", "frame_limit", "0")
        else:
            azaharConfig.set("Renderer", "frame_limit", "100")

        # Disk Shader Cache (in Renderer for SDL2)
        if system.isOptSet('azahar_use_disk_shader_cache') and system.config["azahar_use_disk_shader_cache"] == '1':
            azaharConfig.set("Renderer", "use_disk_shader_cache", "1")
        else:
            azaharConfig.set("Renderer", "use_disk_shader_cache", "0")

        ## [WEB SERVICE]
        if not azaharConfig.has_section("WebService"):
            azaharConfig.add_section("WebService")
        azaharConfig.set("WebService", "enable_telemetry",  "false")

        # Custom Textures (in Layout for SDL2)
        if system.isOptSet('azahar_custom_textures') and system.config["azahar_custom_textures"] != '0':
            tab = system.config["azahar_custom_textures"].split('-')
            azaharConfig.set("Layout", "custom_textures",  "1")
            if tab[1] == 'normal':
                azaharConfig.set("Layout", "async_custom_loading", "1")
                azaharConfig.set("Layout", "preload_textures", "0")
            else:
                azaharConfig.set("Layout", "async_custom_loading", "0")
                azaharConfig.set("Layout", "preload_textures", "1")
        else:
            azaharConfig.set("Layout", "custom_textures",  "0")
            azaharConfig.set("Layout", "preload_textures", "0")

        ## [CONTROLS]
        if not azaharConfig.has_section("Controls"):
            azaharConfig.add_section("Controls")

        # Options required to load the functions when the configuration file is created
        if not azaharConfig.has_option("Controls", r"profiles\size"):
            azaharConfig.set("Controls", "profile", "0")
            azaharConfig.set("Controls", r"profiles\1\name", "default")
            azaharConfig.set("Controls", r"profiles\size", "1")

        controller = playersControllers.get(1)
        if controller is not None:
            for x in azaharButtons:
                azaharConfig.set("Controls", f"{x}", AzaharGenerator.setButton(azaharButtons[x], controller.guid, controller.inputs))
            for x in azaharAxis:
                azaharConfig.set("Controls", f"{x}", AzaharGenerator.setAxis(azaharAxis[x], controller.guid, controller.inputs))

        ## Update the configuration file
        with ensure_parents_and_open(azaharConfigFile, 'w') as configfile:
            azaharConfig.write(configfile)

    @staticmethod
    def setButton(key: str, padGuid: str, padInputs: InputMapping) -> str | None:
        # It would be better to pass the joystick num instead of the guid because 2 joysticks may have the same guid
        if key in padInputs:
            input = padInputs[key]

            if input.type == "button":
                return f"engine:sdl,guid:{padGuid},button:{input.id}"
            if input.type == "hat":
                return f"engine:sdl,guid:{padGuid},hat:{input.id},direction:{AzaharGenerator.hatdirectionvalue(input.value)}"
            if input.type == "axis":
                # Untested, need to configure an axis as button / triggers buttons to be tested too
                return f"engine:sdl,guid:{padGuid},axis:{input.id},direction:+,threshold:0.5"

    @staticmethod
    def setAxis(key: str, padGuid: str, padInputs: InputMapping) -> str:
        inputx = None
        inputy = None

        if key == "joystick1" and "joystick1left" in padInputs:
            inputx = padInputs["joystick1left"]
        elif key == "joystick2" and "joystick2left" in padInputs:
            inputx = padInputs["joystick2left"]

        if key == "joystick1" and "joystick1up" in padInputs:
            inputy = padInputs["joystick1up"]
        elif key == "joystick2" and "joystick2up" in padInputs:
            inputy = padInputs["joystick2up"]

        if inputx is None or inputy is None:
            return ""

        return f"engine:sdl,guid:{padGuid},axis_x:{inputx.id},axis_y:{inputy.id}"

    @staticmethod
    def hatdirectionvalue(value: str) -> str:
        if int(value) == 1:
            return "up"
        if int(value) == 4:
            return "down"
        if int(value) == 2:
            return "right"
        if int(value) == 8:
            return "left"
        return "unknown"

# Language auto setting
def getAzaharLangFromEnvironment():
    region = { "AUTO": -1, "JPN": 0, "USA": 1, "EUR": 2, "AUS": 3, "CHN": 4, "KOR": 5, "TWN": 6 }
    availableLanguages = {
        "ja_JP": "JPN",
        "en_US": "USA",
        "de_DE": "EUR",
        "es_ES": "EUR",
        "fr_FR": "EUR",
        "it_IT": "EUR",
        "hu_HU": "EUR",
        "pt_PT": "EUR",
        "ru_RU": "EUR",
        "en_AU": "AUS",
        "zh_CN": "CHN",
        "ko_KR": "KOR",
        "zh_TW": "TWN"
    }
    lang = environ['LANG'][:5]
    if lang in availableLanguages:
        return region[availableLanguages[lang]]

    return region["AUTO"]
