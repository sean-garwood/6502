; map VIA to address space 0x6000-?
; see 65c22 datasheet, table 2-1 memory map of internal registers, p. 8
PORTB   = $6000
PORTA   = $6001
DDRB    = $6002
DDRA    = $6003

value   = $0200     ; 2 bytes
mod10   = $0202     ; 2 bytes
message = $0204     ; 6 bytes
counter = $020a     ; 2 bytes

E       = $80
RW      = $40
RS      = $20

    .org $8000

reset:
    ldx #$ff
    txs

    lda #$ff        ; Set all pins on port B to output
    sta DDRB
    lda #$d0        ; Set top 3 pins on port A to output
    sta DDRA

    lda #$38        ; Set 8-bit mode; 2-line display; 5x8 font
    jsr lcd_instr
    lda #$0d        ; Display on; cursor on; blink off
    jsr lcd_instr
    lda #$06        ; Increment and shift cursor; don't shift display
    jsr lcd_instr
    lda #$01        ; Clear display
    jsr lcd_instr

    lda #0
    sta counter
    sta counter + 1 ; Initialize counter


loop:
    lda #$02        ; cursor index = 0
    jsr lcd_instr
    lda #0
    sta message     ; initialize message buffer

    lda counter
    sta value
    lda counter + 1
    sta value + 1   ; Initialize counter

divide:
    lda #0
    sta mod10
    sta mod10 + 1
    clc             ; Initialize remainder

    ldx #16         ; index
; Rotate quotient and remainder
divloop:
    rol value
    rol value + 1
    rol mod10
    rol mod10 + 1

    ; a,y = dividend - divisor
    sec
    lda mod10       ; load low-order byte of remainder into A
    sbc #10         ; al = a - 10 - carry
    tay             ; save low byte in Y
    lda mod10 + 1   ; load high-order byte of remainder into A
    sbc #0          ; ah = carry from high byte
    bcc ignore      ; clear ? ignore (dividend - divisor negative)
                    ;       : store a,y => mod10
    sty mod10       ; little-endian: y is low-order
    sta mod10 + 1

ignore:
    dex             ; decrement counter
    bne divloop     ; keep going if counter > 0
    rol value       ; shift in last bit of quotient
    rol value + 1

    lda mod10
    clc
    adc #"0"        ; convert to ASCII
    jsr push_char

    ; if value != 0, then continue dividing
    lda value
    ora value + 1
    bne divide      ; branch if value not zero

    ldx #0

print:
    lda message, x
    beq loop
    jsr print_char
    inx
    jmp print

number: .word $6c1  ; 1729

; Add the char in A to the beginning of msg
push_char:
    pha             ; push new char onto stack
    ldy #0          ; index

char_loop:
    lda message,y   ; Get char on string => X
    tax
    pla
    sta message,y   ; Pull char off stack => message
    iny             ; incr index
    txa
    pha             ; Push char from string onto stack
    bne char_loop   ; Go until nul terminator

    pla             ; Pull null
    sta message,y   ; Append null to end of message

    rts

lcd_wait:
    pha
    lda #0          ; Port B is input
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
    lda #$ff        ; Port B is output
    sta DDRB
    pla
    rts

lcd_instr:
    jsr lcd_wait
    sta PORTB       ; $38 in a
    lda #0          ; Clear RS/RW/E bits
    sta PORTA
    lda #E          ; Set E bit to send instruction
    sta PORTA
    lda #0          ; Clear RS/RW/E bits
    sta PORTA
    rts

print_char:
    jsr lcd_wait
    sta PORTB
    lda #RS         ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)   ; Set E bit to send instruction
    sta PORTA
    lda #RS         ; Clear E bits
    sta PORTA
    rts

nmi:
    rti             ; return from interrupt
irq:
    inc counter
    bne exit_irq
    inc counter + 1
exit_irq:
    rti             ; return from interrupt

    ; reset vectors
    .org $fffa
    .word nmi       ; non-maskable
    .word reset
    .word irq       ; request
