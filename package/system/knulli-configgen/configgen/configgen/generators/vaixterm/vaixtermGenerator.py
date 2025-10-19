from __future__ import annotations

import xml.etree.ElementTree as ET

from typing import TYPE_CHECKING

from ... import Command
from ...controller import generate_sdl_game_controller_config
from ..Generator import Generator
from ...batoceraPaths import ES_SETTINGS

if TYPE_CHECKING:
    from ...types import HotkeysContext

class VaixtermGenerator(Generator):

    # Return value for es invertedbuttons
    def getInvertButtonsValue(self) -> bool:
        try:
            tree = ET.parse(ES_SETTINGS)
            root = tree.getroot()
            # Find the InvertButtons element and return value
            elem = root.find(".//bool[@name='InvertButtons']")
            if elem is not None:
                return elem.get('value') == 'true'
            return False  # Return False if not found
        except:
            return False # when file is not yet here or malformed

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        commandArray = ["vaixterm"]

        return Command.Command(array=commandArray,env={
            "SDL_GAMECONTROLLERCONFIG": generate_sdl_game_controller_config(playersControllers, self.getInvertButtonsValue())
        })

    def getHotkeysContext(self) -> HotkeysContext:
        return {
            "name": "vaixterm",
            "keys": { "exit": ["KEY_LEFTALT", "KEY_F4"] }
        }
