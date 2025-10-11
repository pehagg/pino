;; print hello to stdout

  pshb $68   ; push 'h' byte to stack (becomes Cell)
  jsr $ff00  ; call CHROUT
  pshb $65   ; push 'e' byte to stack
  jsr $ff00  ; call CHROUT
  pshb $6c   ; push 'l' byte to stack 
  jsr $ff00  ; call CHROUT
  pshb $6c   ; push 'l' byte to stack (fixed typo)
  jsr $ff00  ; call CHROUT
  pshb $6f   ; push 'o' byte to stack
  jsr $ff00  ; call CHROUT
  brk
