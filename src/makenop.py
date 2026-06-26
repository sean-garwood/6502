from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
BINPATH = ROOT / "bin" / "rom.bin"
(BINPATH.parent
 .mkdir(parents=True, exist_ok=True))
SIZE = 0x8000                           # EEPROM capacity = 32KiB
NOP = 0xea
rom = bytearray([
    NOP
] * SIZE)

rom[0x7FFC] = 0x00  # Reset vector low byte
rom[0x7FFD] = 0x80  # Reset vector high byte

with open(BINPATH, "wb") as f:
    f.write(rom)
