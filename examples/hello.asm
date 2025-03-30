;; print hello to stdout

  lit $68   ; push 'h' to stack
  jsr $ff00 ; call STDOUT
  lit $65   ; push 'e' to stack
  jsr $ff00 ; call STDOUT
  lit $6c   ; push 'l' to stack 
  jsr $ff00 ; call STDOUT
  lit $6cS  ; push 'l' to stack
  jsr $ff00 ; call STDOUT
  lit $6f   ; push 'o' to stack
  jsr $ff00 ; call STDOUT
  brk
