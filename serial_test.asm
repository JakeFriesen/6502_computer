ACIA_RX = $4000
ACIA_TX = $4000
ACIA_STATUS = $4001
ACIA_COMMAND = $4002
ACIA_CONTROL = $4003
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
PCR = $600c
IFR = $600d
IER = $600e

kb_wptr = $0000
kb_rptr = $0001
kb_flags = $0002

RELEASE = %00000001
SHIFT   = %00000010

kb_buffer = $0200  ; 256-byte kb buffer 0200-02ff

E  = %01000000
RW = %00100000
RS = %00010000

  .org $8000

reset:
    ldx #$ff
    txs

    lda #$01
    sta PCR
    lda #$82
    sta IER
    cli

    lda #%11111111 ; Set all pins on port B to output
    sta DDRB
    lda #%00000000 ; Set all pins on port A to input
    sta DDRA

    jsr lcd_init
    lda #%00101000 ; Set 4-bit mode; 2-line display; 5x8 font
    jsr lcd_instruction
    lda #%00001110 ; Display on; cursor on; blink off
    jsr lcd_instruction
    lda #%00000110 ; Increment and shift cursor; don't shift display
    jsr lcd_instruction
    lda #%00000001 ; Clear display
    jsr lcd_instruction
    ; ACIA setup
    lda #$00
    sta ACIA_STATUS
    lda #$0b
    sta ACIA_COMMAND
    lda #$1f
    sta ACIA_CONTROL


  ldx #0
  ; Print "Hello" to ACIA and LCD
nextchar:
  lda message, X
  beq loop
  jsr print_char
  ; just in case it was clobbered?
  lda message, X
  jsr print_char_acia
  inx
  jmp nextchar
; Accept characters from user, print to both ACIA and LCD
loop:
  jsr recv_char_acia
  sta $00
  jsr print_char
  lda $00
  jsr print_char_acia
  jmp loop

message: .asciiz "Hello, world!"

lcd_wait:
  pha
  lda #%11110000  ; LCD data is input
  sta DDRB
lcdbusy:
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read high nibble
  pha             ; and put on stack since it has the busy flag
  lda #RW
  sta PORTB
  lda #(RW | E)
  sta PORTB
  lda PORTB       ; Read low nibble
  pla             ; Get high nibble off stack
  and #%00001000
  bne lcdbusy

  lda #RW
  sta PORTB
  lda #%11111111  ; LCD data is output
  sta DDRB
  pla
  rts

lcd_init:
  lda #%00000010 ; Set 4-bit mode
  sta PORTB
  ora #E
  sta PORTB
  and #%00001111
  sta PORTB
  rts

lcd_instruction:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr            ; Send high 4 bits
  sta PORTB
  ora #E         ; Set E bit to send instruction
  sta PORTB
  eor #E         ; Clear E bit
  sta PORTB
  pla
  and #%00001111 ; Send low 4 bits
  sta PORTB
  ora #E         ; Set E bit to send instruction
  sta PORTB
  eor #E         ; Clear E bit
  sta PORTB
  rts

print_char:
  jsr lcd_wait
  pha
  lsr
  lsr
  lsr
  lsr             ; Send high 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  pla
  and #%00001111  ; Send low 4 bits
  ora #RS         ; Set RS
  sta PORTB
  ora #E          ; Set E bit to send instruction
  sta PORTB
  eor #E          ; Clear E bit
  sta PORTB
  rts

; print A register to ACIA
; Based on http://forum.6502.org/viewtopic.php?f=4&t=2543&start=30#p29795
print_char_acia:
  pha
  lda ACIA_STATUS
  pla
  sta ACIA_TX
  jsr delay_6551
  rts

delay_6551:
    ; phy
    ; phx
delay_loop:
  ldy #6 ; inflated from numbers in original code.
minidly:
  ldx #$68
delay_1:
  dex
  bne delay_1
  dey
  bne minidly
;   plx
;   ply
delay_done:
  rts

  ; hang until we have a character, return it via A register.
recv_char_acia:
  lda ACIA_STATUS
  and #$08
  beq recv_char_acia
  lda ACIA_RX
  rts