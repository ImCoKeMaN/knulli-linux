from __future__ import annotations

import logging
import json
from pathlib import Path
from typing import TYPE_CHECKING, Final, Dict, Any

from ... import Command
from ...batoceraPaths import BIOS, HOME, SAVES, ensure_parents_and_open
from ...controller import generate_sdl_game_controller_config
from ..Generator import Generator

if TYPE_CHECKING:
    from ...types import HotkeysContext
    from ...controller import ControllerMapping

eslog = logging.getLogger(__name__)

YABA_KEYMAP: Final = HOME / ".yabasanshiro" / "keymapv2.json"
YABA_SAVES: Final = SAVES / "saturn" / "yabasanshiro-sa"
YABA_BIOS: Final = BIOS / "saturn_bios.bin"

UNBOUND = {"id": -1, "type": "", "value": -999}
HAT_VAL = {"up": 1, "right": 2, "down": 4, "left": 8}

ES_TO_YABA = {
    "a": "b",
    "b": "a",
    "x": "y",
    "y": "x",
    "pageup": "z",
    "pagedown": "c",
    "l2": "l",
    "r2": "r",
    "start": "start",
    "select": "select",
    "up": "up", "down": "down", "left": "left", "right": "right",
    "joystick1left": "analogx",
    "joystick1up": "analogy",
}

# Temp fix for rk3566
def ensure_libmali_symlink() -> bool:
    libdir = Path("/usr/lib")
    link = libdir / "libmali.so.0"

    def _target_exists(p: Path) -> bool:
        try:
            p.resolve(strict=True)
            return True
        except Exception:
            return False

    # If it exists and isn't a symlink, leave it alone.
    if link.exists() and not link.is_symlink():
        return True

    # If it is a symlink, ensure target exists.
    if link.is_symlink():
        if _target_exists(link):
            return True
        # remove broken link if needed so we can recreate
        try:
            link.unlink()
        except Exception as e:
            eslog.warning("libmali: failed to remove broken symlink %s: %s", link, e)
            return False

    # Prefer "libMali.so*" then "libmali.so*".
    candidates: list[Path] = []

    for pattern in ("libMali.so*", "libmali.so*"):
        for p in libdir.glob(pattern):
            # we want a real file.
            if p.name == link.name:
                continue
            try:
                if p.is_file() and not p.is_symlink():
                    candidates.append(p)
            except Exception:
                continue

    if not candidates:
        eslog.warning("libmali: no Mali library candidates found in %s", libdir)
        return False

    # Prefer the latest version
    candidates.sort(key=lambda p: p.name)
    target = candidates[-1]

    try:
        link.symlink_to(target)
        eslog.info("libmali: created symlink %s -> %s", link, target)
    except Exception as e:
        eslog.warning("libmali: failed to create symlink %s -> %s: %s", link, target, e)
        return False

    return _target_exists(link)

def generateYabaKeymap(playersControllers: ControllerMapping):
    store = {}

    for player_index in (1, 2):
        if player_index not in playersControllers:
            continue

        controller = playersControllers[player_index]
        name = controller.name
        guid = controller.guid
        device_id = controller.index
        dev_key = f"{device_id}_{name}_{guid}"

        actions = ["a","b","c","x","y","z","l","r","start","select",
                "up","down","left","right","analogx","analogy","analogleft","analogright"]
        block = {k: dict(UNBOUND) for k in actions}

        for idx in controller.inputs:
            inp = controller.inputs[idx]
            src = inp.name
            if src not in ES_TO_YABA:
                continue
            action = ES_TO_YABA[src]

            if inp.type == "button":
                block[action] = {"id": int(inp.id), "type": "button", "value": 1}

            elif inp.type == "hat" and action in ("up","down","left","right"):
                block[action] = {"id": int(inp.id), "type": "hat", "value": HAT_VAL[action]}

            elif inp.type == "axis":
                v = -1 if int(inp.value) < 0 else (1 if int(inp.value) > 0 else 0)

                if src == "joystick1left":
                    block["analogx"] = {"id": int(inp.id), "type": "axis", "value": v}

                elif src == "joystick1up":
                    block["analogy"] = {"id": int(inp.id), "type": "axis", "value": v}
                else:
                    block[action] = {"id": int(inp.id), "type": "axis", "value": v}

        if block["analogx"]["id"] == -1:
            block["analogx"] = {"id": 0, "type": "axis", "value": 0}
        if block["analogy"]["id"] == -1:
            block["analogy"] = {"id": 1, "type": "axis", "value": 0}

        store[dev_key] = block
        store[f"player{player_index}"] = {
            "DeviceID": device_id,
            "deviceGUID": guid,
            "deviceName": name,
            "padmode": 0
        }

    with ensure_parents_and_open(YABA_KEYMAP, "w") as f:
        json.dump(store, f, indent=2, ensure_ascii=False)
    return YABA_KEYMAP

class YabasanshiroGenerator(Generator):

    def supportsExternalBezels(self) -> bool:
        return False

    def getHotkeysContext(self) -> HotkeysContext:
        return {
            "name": "yabasanshiro",
            "keys": { "exit": ["KEY_LEFTALT", "KEY_F4"] }
        }

    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        # temp fix for rk3566
        ensure_libmali_symlink()

        YABA_SAVES.mkdir(parents=True, exist_ok=True)

        generateYabaKeymap(playersControllers)

        commandArray = ["yabasanshiro", "-r", "3", "-a", "-i", rom]

        if not (system.isOptSet('yaba_bios_hle') and system.config['yaba_bios_hle'] == '1'):
            if YABA_BIOS.exists():
                commandArray[1:1] = ["-b", str(YABA_BIOS)]

        return Command.Command(array=commandArray,env={
            "SDL_GAMECONTROLLERCONFIG": generate_sdl_game_controller_config(playersControllers)
        })
