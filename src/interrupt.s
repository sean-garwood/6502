PORTB   = $6000
PORTA   = $6001
DDRB    = $6002
DDRA    = $6003
PCR     = $600c         ; Peripheral control register
IFR     = $600d         ; Interrupt flag register
IER     = $600e         ; Interrupt enable register

E       = $80
RW      = $40
RS      = $20

value   = $0200         ; 2 bytes
mod10   = $0202         ; 2 bytes
message = $0204         ; 6 bytes
counter = $020a         ; 2 bytes

    .org $8000

reset:
    ldx #$ff
    txs
    cli

    lda #$82             ; Enable interrupt on CA1 (table 2-12 65c22 datasheet)
    sta IER
    lda #$82
    sta IFR
    lda #$00
    sta PCR

    lda #$ff            ; Set all pins on port B to output
    sta DDRB
    lda #$d0            ; Set top 3 pins on port A to output
    sta DDRA

    lda #$38            ; Set 8-bit mode; 2-line display; 5x8 font
    jsr lcd_instruction
    lda #$0d            ; Display on; cursor on; blink off
    jsr lcd_instruction
    lda #$06            ; Increment and shift cursor; don't shift display
    jsr lcd_instruction
    lda #$01            ; Clear display
    jsr lcd_instruction

    lda #$00
    sta counter
    sta counter + 1

loop:
    lda #$02            ; Home
    jsr lcd_instruction

    lda #$00
    sta message

    ; Init value in RAM
    sei                 ; set interrupt disable status
    lda counter
    sta value
    lda counter +1
    sta value + 1

divide:
    ; init rem to zero
    lda #0
    sta mod10
    sta mod10 + 1
    clc
    ldx #16             ; index
divloop:
    ; Rotate quotient and remainder
    rol value
    rol value + 1
    rol mod10
    rol mod10 + 1

    ; a,y = dividend - divisor
    sec
    lda mod10           ; load low-order byte of remainder into A
    sbc #10
    tay                 ; save low byte in Y
    lda mod10 + 1       ; load high-order byte of remainder into A
    sbc #0              ; subtract carry from high byte
    bcc ignore_result   ; if clear, ignore: dividend - divisor negative
    ; else... store a,y => mod10
    sty mod10           ; little-endian: y is low-order
    sta mod10 + 1
ignore_result:
    dex                 ; decrement counter
    bne divloop         ; keep going if counter > 0
    rol value           ; shift in last bit of quotient
    rol value + 1

    lda mod10
    clc
    adc #"0"            ; convert to ASCII
    jsr push_char

    ; if value != 0, then continue dividing
    lda value
    ora value + 1
    bne divide          ; branch if value not zero

    ldx #0
print_message:
    lda message, x
    beq loop
    jsr print_char
    inx
    jmp print_message

number: .word $6c1  ; 1729

; Add the char in A to the beginning of msg
push_char:
    pha                 ; push new char onto stack
    ldy #0              ; index

char_loop:
    lda message,y       ; Get char on string => X
    tax
    pla
    sta message,y       ; Pull char off stack => message
    iny                 ; incr index
    txa
    pha                 ; Push char from string onto stack
    bne char_loop       ; Go until nul terminator

    pla                 ; Pull null
    sta message,y       ; Append null to end of message

    rts

lcd_wait:
    pha
    lda #%00000000      ; Port B is input
    sta DDRB
lcdbusy:
    lda #RW
    sta PORTA
    lda #(RW | E)
    sta PORTA
    lda PORTB
    and #$80
    bne lcdbusy

    lda #RW
    sta PORTA
    lda #$ff      ; Port B is output
    sta DDRB
    pla
    rts

lcd_instruction:
    jsr lcd_wait
    sta PORTB
    lda #0              ; Clear RS/RW/E bits
    sta PORTA
    lda #E              ; Set E bit to send instruction
    sta PORTA
    lda #0              ; Clear RS/RW/E bits
    sta PORTA
    rts

print_char:
    jsr lcd_wait
    sta PORTB
    lda #RS             ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)       ; Set E bit to send instruction
    sta PORTA
    lda #RS             ; Clear E bits
    sta PORTA
    rts

nmi:
irq:                    ; TODO: debounce
    inc counter
    bne exit_irq
    inc counter + 1
exit_irq:
    rti

    .org $fffa
    .word nmi
    .word reset
    .word irq
