
; new locations
; via 8000
; acia 8400
; rom c000
; ram 0

;Add Libraries
.include "keyboard_lib.asm"
.include "acia_lib.asm"
.include "lcd_lib.asm"
;.include "xmodem_lib.asm"

; VIA mem locations
PORTB = $8000
PORTA = $8001
DDRB = $8002
DDRA = $8003
PCR = $800c
IFR = $800d
IER = $800e

; Serial mem locations
ACIA_RX = $8400
ACIA_TX = $8400
ACIA_STATUS = $8401
ACIA_COMMAND = $8402
ACIA_CONTROL = $8403

; Special keys
RELEASE = %00000001
SHIFT   = %00000010

E  = %01000000
RW = %00100000
RS = %00010000


  .code
reset:
  ldx #$ff
  txs

  ; ACIA setup
  lda #$00
  sta ACIA_STATUS
  lda #$0b
  sta ACIA_COMMAND
  lda #$1f
  sta ACIA_CONTROL

  ; VIA Setup
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

  lda #$00
  sta kb_flags
  sta kb_wptr
  sta kb_rptr

;Print out Serial stuff
  ldx #0
nextchar:
  lda message, x
  beq loop
  jsr print_char
  ; just in case it was clobbered?
  lda message, x
  jsr print_char_acia
  inx
  jmp nextchar

message: .asciiz "ST:"

loop:
  jsr recv_char_acia
  sta $00
  jsr print_char
  lda $00
  jsr print_char_acia
  ; sei
  ; lda kb_rptr
  ; cmp kb_wptr
  ; cli
  ; bne key_pressed
  jmp loop

nmi:
  rti
; Reset/IRQ vectors
  .segment "VECTORS"
  .word nmi
  .word reset
  .word keyboard_interrupt