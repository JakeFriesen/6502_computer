.setcpu "6502"
.psc02
;Add Libraries
.include "keyboard_lib.asm"
.include "acia_lib.asm"
.include "lcd_lib.asm"
.include "xmodem_lib.asm"

.import XModemRcv


; VIA mem locations
PORTB = $6000
PORTA = $6001
DDRB = $6002
DDRA = $6003
PCR = $600c
IFR = $600d
IER = $600e

; Serial mem locations
ACIA_RX = $4000
ACIA_TX = $4000
ACIA_STATUS = $4001
ACIA_COMMAND = $4002
ACIA_CONTROL = $4003

; Keyboard pointers
kb_wptr = $0000
kb_rptr = $0001
kb_flags = $0002

; Special keys
RELEASE = %00000001
SHIFT   = %00000010

; 256-byte kb buffer 0200-02ff
kb_buffer = $0200  

E  = %01000000
RW = %00100000
RS = %00010000


  .org $8000

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

message: .asciiz "START"

; Go into XModem Recieve 
  JSR XModemRcv

loop: ; program ended, halt
    jmp loop


nmi:
  rti
; Reset/IRQ vectors
  .org $fffa
  .word nmi
  .word reset
  .word keyboard_interrupt