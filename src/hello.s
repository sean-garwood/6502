PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000

    .org $8000     ; entrypoint

reset:
    ldx #$ff       ; Initialize stack pointer
    txs
    lda #%11111111 ; Set all pins on port B to output
    sta DDRB

    lda #%11100000 ; Set top 3 pins (D5-D7) of port A to output
    sta DDRA

    lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
    jsr lcd_instruction

    lda #%00001110 ; Display/cursor on; blink off
    jsr lcd_instruction

    lda #%00000110 ; Increment and shift cursor; don't shift display
    jsr lcd_instruction

    lda #%00000001 ; Clear display
    jsr lcd_instruction

    ldx #0
    jmp print_message

loop:
    jmp loop

message: .asciiz "**Bruce*Holly**"

print_message:
    lda message, x
    beq loop
    jsr print_char
    inx
    jmp print_message

lcd_wait:
    pha
    lda #$00 ; set portb to input
    sta DDRB
lcdbusy:
    lda #RW
    sta PORTA ; put 0x60 on first 8 bits on VIA
    lda #(RW | E)
    sta PORTA
    lda PORTB ; read data bits

    ; given solution
    ; and #$80
    ; bne lcdbusy

    ; optimized: N flag = bit 7 after lda
    bmi lcdbusy

    lda #RW
    sta PORTA
    lda #$ff ; set portb to output
    sta DDRB

    pla
    rts

lcd_instruction:
    jsr lcd_wait
    sta PORTB
    lda #0         ; Clear RS/RW/E bits
    sta PORTA
    lda #E         ; Set Enable pin to send instruction
    sta PORTA
    lda #0         ; Clear RS/RW/E bits
    sta PORTA
    rts

print_char:
    jsr lcd_wait
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA
    rts

    .org $fffc
    .word reset
    .word $0000
