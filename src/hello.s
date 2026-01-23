PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003

E  = %10000000
RW = %01000000
RS = %00100000

    .org $8000     ; entrypoint

reset:
    lda #%11111111 ; Set all pins on port B to output
    sta DDRB

    lda #%11100000 ; Set top 3 pins (D5-D7) of port A to output
    sta DDRA

    lda #%00111000 ; Set 8-bit mode; 2-line display; 5x8 font
    sta PORTB
    lda #0         ; Clear RS/RW/E bits
    sta PORTA
    lda #E         ; Set Enable pin to send instruction
    sta PORTA
    lda #0         ; Clear RS/RW/E bits
    sta PORTA

    lda #%00001110 ; Display/cursor on; blink off
    sta PORTB
    lda #0         ; Clear RS/RW/E bits
    sta PORTA
    lda #E         ; Set Enable pin to send instruction
    sta PORTA
    lda #0         ; Clear RS/RW/E bits
    sta PORTA

    lda #%00000110 ; Increment and shift cursor; don't shift display
    sta PORTB
    lda #0         ; Clear RS/RW/E bits
    sta PORTA
    lda #E         ; Set Enable pin to send instruction
    sta PORTA
    lda #0         ; Clear RS/RW/E bits
    sta PORTA

    lda #"H"
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA

    lda #"e"
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA
    lda #"l"
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA
    lda #"l"
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA
    lda #"o"
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA
    lda #","
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA
    lda #" "
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA
    lda #"w"
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA
    lda #"o"
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA
    lda #"r"
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA
    lda #"l"
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA

    lda #"d"
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA

    lda #"!"
    sta PORTB
    lda #RS        ; Set RS; Clear RW/E bits
    sta PORTA
    lda #(RS | E)
    sta PORTA
    lda #RS        ; Clear E bits
    sta PORTA
loop:
    jmp loop

    .org $fffc
    .word reset
    .word $0000
