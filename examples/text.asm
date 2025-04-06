;; print hello to stdout

draw:
  jsr $ff10 ; call BGNDRW
  lit $68   ; push 'h' to stack
  lit 8     ; x=8
  lit 8     ; y=8
  lit 3     ; cyan
  jsr $ff14 ; call TXTOUT
  lit $65   ; push 'e' to stack
  lit 20    ; x=20
  lit 8     ; y=8
  lit 3     ; cyan
  jsr $ff14 ; call TXTOUT
  lit $6c   ; push 'l' to stack
  lit 32    ; x=32
  lit 8     ; y=8
  lit 3     ; cyan
  jsr $ff14 ; call TXTOUT
  lit $6c   ; push 'l' to stack
  lit 44    ; x=44
  lit 8     ; y=8
  lit 3     ; cyan
  jsr $ff14 ; call TXTOUT
  lit $6f   ; push 'o' to stack
  lit 56    ; x=56
  lit 8     ; y=8
  lit 3     ; cyan
  jsr $ff14 ; call TXTOUT
  jsr $ff11 ; call ENDDRW
  jmp draw  
  brk
