;; print hello to stdout

draw:
  jsr $ff10 ; call BGNDRW
  psh $68   ; push 'h' to stack
  psh 8     ; x=8
  psh 8     ; y=8
  psh 3     ; cyan
  jsr $ff14 ; call TXTOUT
  psh $65   ; push 'e' to stack
  psh 20    ; x=20
  psh 8     ; y=8
  psh 3     ; cyan
  jsr $ff14 ; call TXTOUT
  psh $6c   ; push 'l' to stack
  psh 32    ; x=32
  psh 8     ; y=8
  psh 3     ; cyan
  jsr $ff14 ; call TXTOUT
  psh $6c   ; push 'l' to stack
  psh 44    ; x=44
  psh 8     ; y=8
  psh 3     ; cyan
  jsr $ff14 ; call TXTOUT
  psh $6f   ; push 'o' to stack
  psh 56    ; x=56
  psh 8     ; y=8
  psh 3     ; cyan
  jsr $ff14 ; call TXTOUT
  jsr $ff11 ; call ENDDRW
  jmp draw  
  brk
