;; draw lines

draw:
  jsr $ff01 ; call BGNDRW
  lit 10    ; startX=10
  lit 10    ; startY=10
  lit 100   ; endX=100
  lit 100   ; endY=100
  lit 3     ; cyan
  jsr $ff04 ; call LINOUT
  lit 100   ; startX=100
  lit 100   ; startY=100
  lit 200   ; endX=200
  lit 100   ; endY=100
  lit 2     ; red
  jsr $ff04 ; call LINOUT
  jsr $ff02 ; call ENDDRW
  jmp draw
  brk
