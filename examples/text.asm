;; print hello to stdout

draw:
  jsr   $ff10 ; call BGNDRW
  pshb  $68   ; push 'h' to stack
  pshb  8     ; x=8
  pshb  8     ; y=8
  pshb  3     ; cyan
  jsr   $ff14 ; call TXTOUT
  pshb  $65   ; push 'e' to stack
  pshb  20    ; x=20
  pshb  8     ; y=8
  pshb  3     ; cyan
  jsr   $ff14 ; call TXTOUT
  pshb  $6c   ; push 'l' to stack
  pshb  32    ; x=32
  pshb  8     ; y=8
  pshb  3     ; cyan
  jsr   $ff14 ; call TXTOUT
  pshb  $6c   ; push 'l' to stack
  pshb  44    ; x=44
  pshb  8     ; y=8
  pshb  3     ; cyan
  jsr   $ff14 ; call TXTOUT
  pshb  $6f   ; push 'o' to stack
  pshb  56    ; x=56
  pshb  8     ; y=8
  pshb  3     ; cyan
  jsr   $ff14 ; call TXTOUT
  jsr   $ff11 ; call ENDDRW
  jmp   draw
  brk
