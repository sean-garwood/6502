    .org $8000  ; entrypoint

reset:
    lda #$ff    ; load 0b11111111 into A register
    sta $6002   ; store contents of A register in $0x6002

    lda #$50    ; load 0b01010000 into A register
    sta $6000   ; store contents of A register in $0x6000

loop:
    ror         ; shift bytes in A register right one
    sta $6000   ; store result in $0x6000

    jmp loop

    .org $fffc
    .word reset
    .word $0000
