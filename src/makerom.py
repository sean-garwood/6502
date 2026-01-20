SIZE = 0x8000 # EEPROM capacity = 32KiB
OUTFILE = "/home/ssg/courses/6502/bin/rom.bin"
LDA = 0xA9  # LDA Immediate opcode
STA = 0x8D  # STA Absolute opcode

rom = bytearray([0xEA] * SIZE)

rom[0] = LDA
rom[1] = 0x42
rom[2] = STA
rom[3] = 0x00
rom[4] = 0x60  # Store value 0x42 at address 0x6000

rom[0x7FFC] = 0x00  # Reset vector low byte
rom[0x7FFD] = 0x80  # Reset vector high byte

with open(OUTFILE, "wb") as f:
    f.write(rom)
