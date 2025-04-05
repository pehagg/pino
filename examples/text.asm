;; print hello to stdout

draw:
  jsr $ff01 ; call BGNDRW
  lit $68   ; push 'h' to stack
  lit 8     ; x=8
  lit 8     ; y=8
  jsr $ff05 ; call TXTOUT
  lit $65   ; push 'e' to stack
  lit 14    ; x=14
  lit 8     ; y=8
  jsr $ff05 ; call TXTOUT
  lit $6c   ; push 'l' to stack
  lit 20    ; x=20
  lit 8     ; y=8
  jsr $ff05 ; call TXTOUT
  lit $6c   ; push 'l' to stack
  lit 26    ; x=26
  lit 8     ; y=8
  jsr $ff05 ; call TXTOUT
  lit $6f   ; push 'o' to stack
  lit 32    ; x=32
  lit 8     ; y=8
  jsr $ff05 ; call TXTOUT
  jsr $ff02 ; call ENDDRW
  jmp draw  
  brk
