; an attempt
val = $0200

    .org $8000
reset:
loop:
    lda #$55
    sta val
    lda #$aa
    sta val
    jmp loop

    .org $fffc
    .word reset
    .word $0000     ;fffe, ffff
