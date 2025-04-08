;; draw lines

draw:
  jsr $ff10 ; call BGNDRW
  lit 10    ; startX=10
  lit 10    ; startY=10
  lit 100   ; endX=100
  lit 100   ; endY=100
  lit 3     ; cyan
  jsr $ff13 ; call LINOUT
  lit 100   ; startX=100
  lit 100   ; startY=100
  lit 200   ; endX=200
  lit 100   ; endY=100
  lit 2     ; red
  jsr $ff13 ; call LINOUT
  jsr $ff11 ; call ENDDRW
  jmp draw
  brk
