;; draw pixels to the screen

draw:
  jsr $ff01 ; call BGNDRW
  lit $0a   ; x=10
  lit $14   ; y=20
  lit $2    ; red
  jsr $ff03 ; call PIXOUT
  lit $14   ; x=20
  lit $14   ; y=20
  lit $3    ; cyan
  jsr $ff03 ; call PIXOUT
  lit $0a   ; x=10
  lit $1e   ; y=30
  lit $1    ; white 
  jsr $ff03 ; call PIXOUT
  lit $14   ; x=20
  lit $1e   ; y=30
  lit $1    ; white 
  jsr $ff03 ; call PIXOUT
  jsr $ff02 ; call ENDDRW
  jmp draw
  brk
