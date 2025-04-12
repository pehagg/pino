;; print hello to stdout

  psh $68   ; push 'h' to stack
  jsr $ff00 ; call CHROUT
  psh $65   ; push 'e' to stack
  jsr $ff00 ; call CHROUT
  psh $6c   ; push 'l' to stack 
  jsr $ff00 ; call CHROUT
  psh $6cS  ; push 'l' to stack
  jsr $ff00 ; call CHROUT
  psh $6f   ; push 'o' to stack
  jsr $ff00 ; call CHROUT
  brk
