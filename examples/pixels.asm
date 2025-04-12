;; draw pixels to the screen

draw:
  jsr $ff10 ; call BGNDRW
  psh $0a   ; x=10
  psh $14   ; y=20
  psh $2    ; red
  jsr $ff12 ; call PIXOUT
  psh $14   ; x=20
  psh $14   ; y=20
  psh $3    ; cyan
  jsr $ff12 ; call PIXOUT
  psh $0a   ; x=10
  psh $1e   ; y=30
  psh $1    ; white 
  jsr $ff12 ; call PIXOUT
  psh $14   ; x=20
  psh $1e   ; y=30
  psh $1    ; white 
  jsr $ff12 ; call PIXOUT
  jsr $ff11 ; call ENDDRW
  jmp draw
  brk
