;; draw pixels to the screen

draw:
  jsr   $ff10 ; call BGNDRW
  pshb  $0a   ; x=10
  pshb  $14   ; y=20
  pshb  $2    ; red
  jsr   $ff12 ; call PIXOUT
  pshb  $14   ; x=20
  pshb  $14   ; y=20
  pshb  $3    ; cyan
  jsr   $ff12 ; call PIXOUT
  pshb  $0a   ; x=10
  pshb  $1e   ; y=30
  pshb  $1    ; white 
  jsr   $ff12 ; call PIXOUT
  pshb  $14   ; x=20
  pshb  $1e   ; y=30
  pshb  $1    ; white 
  jsr   $ff12 ; call PIXOUT
  jsr   $ff11 ; call ENDDRW
  jmp   draw
  brk
