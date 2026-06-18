# W65C02S Instructions — Flag Effects

Source: Table 5-1 & Table 6-4 from the W65C02S datasheet (WDC, Oct 2018 revision hosted at eater.net)

## Instructions That Set Flags

| Instruction | Flags Modified |
|---|---|
| ADC (Add with Carry) | N, V, Z, C |
| AND | N, Z |
| ASL (Arithmetic Shift Left) | N, Z, C |
| BIT (Bit Test) | N¹, V¹, Z |
| BRK (Break) | B=1, D=0, I=1 |
| CLC (Clear Carry) | C=0 |
| CLD (Clear Decimal) | D=0 |
| CLI (Clear Interrupt Disable) | I=0 |
| CLV (Clear Overflow) | V=0 |
| CMP (Compare A) | N, Z, C |
| CPX (Compare X) | N, Z, C |
| CPY (Compare Y) | N, Z, C |
| DEC (Decrement Memory/A) | N, Z |
| DEX (Decrement X) | N, Z |
| DEY (Decrement Y) | N, Z |
| EOR (Exclusive OR) | N, Z |
| INC (Increment Memory/A) | N, Z |
| INX (Increment X) | N, Z |
| INY (Increment Y) | N, Z |
| LDA (Load A) | N, Z |
| LDX (Load X) | N, Z |
| LDY (Load Y) | N, Z |
| LSR (Logical Shift Right) | N=0², Z, C |
| ORA (OR with A) | N, Z |
| PLA (Pull A from Stack) | N, Z |
| PLP (Pull P from Stack) | N, V, D, I, Z, C (all) |
| PLX (Pull X from Stack) | N, Z |
| PLY (Pull Y from Stack) | N, Z |
| ROL (Rotate Left) | N, Z, C |
| ROR (Rotate Right) | N, Z, C |
| RTI (Return from Interrupt) | N, V, D, I, Z, C (all) |
| SBC (Subtract with Carry) | N, V, Z, C |
| SEC (Set Carry) | C=1 |
| SED (Set Decimal) | D=1 |
| SEI (Set Interrupt Disable) | I=1 |
| TAX (Transfer A → X) | N, Z |
| TAY (Transfer A → Y) | N, Z |
| TRB (Test and Reset Bits) | Z |
| TSB (Test and Set Bits) | Z |
| TSX (Transfer S → X) | N, Z |
| TXA (Transfer X → A) | N, Z |
| TYA (Transfer Y → A) | N, Z |

¹ BIT copies memory bit 7 → N and bit 6 → V (except in immediate mode, where only Z is affected).
² LSR always clears N because a 0 is shifted into bit 7.

## Instructions That Do NOT Set Any Flags

BBR0–BBR7 (Branch on Bit Reset), BBS0–BBS7 (Branch on Bit Set), BCC, BCS, BEQ, BMI, BNE, BPL, BRA, BVC, BVS, JMP, JSR, NOP, PHA, PHP, PHX, PHY, RMB0–RMB7, RTS, STA, STP, STX, STY, STZ, SMB0–SMB7, TXS, WAI

Note that TXS is the odd one out among the transfer instructions — every other transfer (TAX, TAY, TXA, TYA, TSX) sets N and Z, but TXS does not.
