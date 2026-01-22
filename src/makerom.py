SIZE = 0x8000 # EEPROM capacity = 32KiB
OUTFILE = "/home/ssg/courses/6502/bin/rom.bin"
LDA = 0xa9  # LDA Immediate opcode
STA = 0x8d  # STA Absolute opcode
BOB = 0x42  # Example value to load
ONES = 0xff
JMP = 0x4c  # JMP Absolute opcode

code = bytearray([
    LDA, ONES,         # Load value 0xFF into accumulator
    STA, 0x02, 0x60,  # Store value 0x42 at address 0x6002

    LDA, 0x55,         # Load value 0x55 into accumulator
    STA, 0x00, 0x60,  # Store value 0x42 at address 0x6000

    LDA, 0xaa,         # Load value 0xAA into accumulator
    STA, 0x00, 0x60,  # Store value 0x42 at address 0x6000

    JMP, 0x05, 0x80,  # Jump to address 0x8005
])
rom = code + bytearray([0xEA] * (SIZE-len(code)))  # Fill with NOPs

rom[0x7FFC] = 0x00  # Reset vector low byte
rom[0x7FFD] = 0x80  # Reset vector high byte

with open(OUTFILE, "wb") as f:
    f.write(rom)
