;; draw pixels to the screen

draw:
  jsr $ff10 ; call BGNDRW
  lit $0a   ; x=10
  lit $14   ; y=20
  lit $2    ; red
  jsr $ff12 ; call PIXOUT
  lit $14   ; x=20
  lit $14   ; y=20
  lit $3    ; cyan
  jsr $ff12 ; call PIXOUT
  lit $0a   ; x=10
  lit $1e   ; y=30
  lit $1    ; white 
  jsr $ff12 ; call PIXOUT
  lit $14   ; x=20
  lit $1e   ; y=30
  lit $1    ; white 
  jsr $ff12 ; call PIXOUT
  jsr $ff11 ; call ENDDRW
  jmp draw
  brk
