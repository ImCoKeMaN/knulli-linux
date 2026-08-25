from __future__ import annotations

from pathlib import Path
from typing import TYPE_CHECKING

from ... import Command
from ...batoceraPaths import CONFIGS
from ..Generator import Generator

if TYPE_CHECKING:
    from ...types import HotkeysContext


# DOS game folders come with whatever casing the original archive had, so the
# support files are matched case-insensitively rather than by exact name.
def _find_iname(directory: Path, filename: str) -> Path | None:
    if not directory.is_dir():
        return None

    lower_filename = filename.lower()
    return next((f for f in directory.iterdir()
                 if f.is_file() and f.name.lower() == lower_filename), None)


class DosBoxStagingGenerator(Generator):

    # Main entry of the module
    # Return command
    def generate(self, system, rom, playersControllers, metadata, guns, wheels, gameResolution):
        # Find rom path, handling a rom that is a single file rather than a folder
        gameDir = Path(rom)
        if not gameDir.is_dir():
            gameDir = gameDir.parent
        batFile = _find_iname(gameDir, "dosbox.bat") or gameDir / "dosbox.bat"
        gameConfFile = _find_iname(gameDir, "dosbox.cfg")

        commandArray: list[str | Path] = [
            '/usr/bin/dosbox-staging',
            "-fullscreen",
            "-userconf",
            "-exit",
            batFile,
            "-c", f"""set ROOT={gameDir!s}"""
        ]
        if gameConfFile:
            commandArray.append("-conf")
            commandArray.append(gameConfFile)
        else:
            commandArray.append("-conf")
            commandArray.append(CONFIGS / 'dosbox' / 'dosbox.conf')

        return Command.Command(array=commandArray)

    def writesToRom(self, config) -> bool:
        return True

    def getHotkeysContext(self) -> HotkeysContext:
        return {
            "name": "dosboxstaging",
            "keys": { "exit": ["KEY_LEFTCTRL", "KEY_F9"] }
        }
