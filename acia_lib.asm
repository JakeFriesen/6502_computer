;-----------------------------------------------;
;                ACIA Library                   ;
;-----------------------------------------------;
;ACIA char sending functions
print_char_acia:
  pha
acia_loop:
  ; lda ACIA_STATUS
  ; and #$10
  ; beq acia_loop
  pla
  sta ACIA_TX
  jsr delay_6551
  rts

delay_6551:
  txa
  pha
  tya
  pha
delay_loop:
  ldy #6 ; inflated from numbers in original code.
minidly:
  ldx #$68
delay_1:
  dex
  bne delay_1
  dey
  bne minidly
  pla
  tay
  pla
  tax
delay_done:
  rts

; hang until we have a character, return it via A register.
recv_char_acia:
  lda ACIA_STATUS
  and #$08
  beq recv_char_acia
  lda ACIA_RX
  rts
