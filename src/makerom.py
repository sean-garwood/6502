# fill EEPROM with nop

NOP_OPCODE = 0xEA
SIZE = 0x8000 # EEPROM capacity = 32KiB

rom = bytearray([NOP_OPCODE] * SIZE)

with open("../bin/rom.bin", "wb") as f:
    f.write(rom)
